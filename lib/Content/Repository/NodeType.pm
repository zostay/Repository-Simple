package Content::Repository::NodeType;

use strict;
use warnings;

our $VERSION = '0.01';

=head1 NAME

Content::Repository::NodeType - Types for content repository nodes

=head1 SYNOPSIS

  sub print_node_types {
      my $node = shift;

      my $type = $node->type;

      print $node->name, " : ", $type->name, "\n";

      my %properties = $type->properties;
      while (my ($name, $ptype) = each %properties) {
          print " * ", $name, " : ", $ptype->name, " {";
          my %options = $ptype->options;
          while (my ($k,$v) = each %options) { print " $k=>$v" }
          print " }";
          print " [RO]"  if !$ptype->mutable;
          print " [REQ]" if  $ptype->required;
          print "\n";
      }
  }

=head1 DESCRIPTION

Node types are used to determine information about what kind of information is expected and required to be part of a node instance. A node type may inherit features from another node type through inheritance.

=head2 METHODS

=over

=item $type = Content::Repository::NodeType-E<gt>new(%args)

Create as a new node type with the given arguments, C<%args>.

The following arguments are used:

=over

=item name (required)

This is the a short identifying name for the type.

=item abstract

This option states that this node type is abstract and may not be implemented by any node. It is only meant to be inherited from.

If this option is not given, the default is false, i.e., not abstract, but concrete.

=item supertypes

This option may be set to an array of node type names representing the node types that this node type inherits from. Only the possible/required child node types and property types are inheritable

If this option is not given, then the node type inherits nothing.

=item child_nodes

This option is set to a hash where the keys are node names and the values are either node type names or arrays of node type names. The string "*" is special for the keys, it means that a node of any name may be contained with the given type.

For example,

  child_node_types => {
      foo => 'my:typeX',
      bar => [ 'my:typeY', 'my:typeZ' ],
      '*' => [ 'my:typeX', 'my:typeZ' ],
  },

allows the nodes of the defined node type to have a node named "foo" with type "my:typeX", a node named "bar" with either the type "my:typeY" or the type "my:typeZ", and any number of other nodes named anything with type "my:typeX" or "my:typeZ".

=item child_properties

This option is set to a hash where the keys are property names and the values are either property type names or arrays of property type names.

=item auto_created

This option should be set to true if the creation of a parent node triggers the creation of any node having this type.

By default, this value is false.

=item mutable

This is a property for all node types stating whether or not the node may be modified. This only affects the node itself and does not affect any of its properties or child nodes.

By default, this value is false.

=item required

When this property is set to a true value, this node may not be removed from its parent node.

By default, this value is false.

=item ordered

When this property is set to a true value, the order of child nodes of this node is significant. If false, the nodes may appear in any order.

By default, this value is false.

=back

=cut

sub new {
    my $class = shift;
    my %args  = @_;

    if (!defined $args{name}) {
        croak 'The "name" argument must be given.';
    }

    $args{supertypes} ||= [];

    $args{child_nodes}      ||= {};
    $args{child_properties} ||= {};

    $args{mutable}      ||= 0;
    $args{required}     ||= 0;
    $args{auto_created} ||= 0;
    $args{ordered}      ||= 0;

    return bless \%args, $class;
}

=item $name = $type-E<gt>name

This method returns the name of the type.

=cut

sub name {
    my $self = shift;
    return $self->{name};
}

=item $abstract = $type-E<gt>abstract

This method returns true if the type is abstract or false if it is not.

=cut

sub abstract {
    my $self = shift;
    return $self->{abstract};
}

=item @supertypes = $type-E<gt>supertypes

This method returns the direct supertypes of the type.

=cut

sub supertypes {
    my $self = shift;
    return @{ $self->{supertypes} };
}

=item %child_nodes = $type-E<gt>child_nodes

Returns all the child nodes of this node type, including all nodes inherited from supertypes. The keys of the returned nodes will be the node names. The values will be the names of the node type that node is expected to have.

=cut

sub child_nodes {
    my $self = shift;
    
    my %child_nodes;
    for my $supertype (@{ $self->{supertypes} }) {
        %child_nodes = (
            %child_nodes, 
            $self->{repository}->node_type($supertype)->child_nodes
        );
    }

    %child_nodes = (%child_nodes, %{ $self->{child_nodes} });

    return %child_nodes;
}

=item %child_properties = $type-E<gt>child_properties

This method returns all properties that may be added to this node, including those inherited from supertypes. The keys of the returned hash represent the names of those properties and the values represent the property types of those nodes.

=cut

sub child_properties {
    my $self = shift;
    
    my %child_properties;
    for my $supertype (@{ $self->{supertypes} }) {
        %child_nodes = (
            %child_nodes, 
            $self->{repository}->node_type($supertype)->child_properties
        );
    }

    %child_nodes = (%child_nodes, %{ $self->{child_properties} });

    return %child_nodes;
}

=item $auto_created = $type-E<gt>auto_created

This method returns true if nodes of this type should be automatically created with their parent.

=cut

sub auto_created {
    my $self = shift;
    return $self->{auto_created};
}

=item $mutable = $type-E<gt>mutable

This method returns true if nodes of this type may be changed. A nodes mutability or immutability doesn't have any bearing on the mutability of child nodes or child properties.

=cut

sub mutable {
    my $self = shift;
    return $self->{mutable};
}

=item $required = $type-E<gt>required

This method returns true if nodes named this type are required by their parent.

=cut

sub required {
    my $self = shift;
    return $self->{required};
}

=item $ordered = $type-E<gt>ordered

This method returns true if the child nodes of this node have a significant order and can be reordered with respect to one another. If this method returns false than the order is not significant.

=cut

sub ordered {
    my $self = shift;
    return $self->{ordered};
}

=back

=head1 AUTHOR

Andrew Sterling Hanenkamp, E<lt>hanenkamp@cpan.orgE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright 2005 Andrew Sterling Hanenkamp E<lt>hanenkamp@cpan.orgE<gt>.  All 
Rights Reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.

=cut

1
