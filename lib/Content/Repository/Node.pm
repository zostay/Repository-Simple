package Content::Repository::Node;

use strict;
use warnings;

use Content::Repository::Property;
use Content::Repository::Util qw( dirname normalize_path );

our $VERSION = '0.01';

=head1 NAME

Content::Repository::Node - Content repository node information

=head1 SYNOPSIS

  use Content::Repository;

  my $repository = Content::Repository::Factory->connect(
      FileSystem => { root => '/var/db/cr' }
  );

  my $node = $repository->root_node;
  print_node($node, 0);

  sub print_node {
      my ($node, $depth) = @_;
      
      print "\t" x $depth, " * ", $node->name, "\n";

      for my $child ($node->nodes) {
          print_node($child, $depth + 1);
      }

      for my $p ($node->properties) {
          print "\t" x $depth, "\t * ", $p->name, " = ", $p->value, "\n";
      }
  }

=head1 DESCRIPTION

Each instance of this class describes a node in a repository. A node is basically a unit of information described by a path, which may have zero or more additional properties assigned to it.

To retrieve an instance of this type, you never construct this object directly. Instead, use one of the node access methods in L<Content::Repository>.

=cut

# $node = Content::Repository::Node->new($repository, $path)
#
# Create a new node object.
#
sub new {
    my ($class, $repository, $path) = @_;

    return bless {
        repository => $repository,
        path       => $path,
    }, $class;
}

=head2 METHODS

=over

=item $repository = $node-E<gt>repository

Returns the L<Content::Repository> object to which this node belongs.

=cut

sub repository {
    my $self = shift;
    return $self->{repository};
}

=item $node = $type-E<gt>parent

Fetch the node that is the parent of this node. This will always return a node, even for the root node. The root node is the parent of itself. 

If you consider time travel, you may wish to stop yourself before you think too hard on the implications and gross yourself out.

=cut

sub parent {
    my $self = shift;
    return Content::Repository::Node->new(
        $self->repository, 
        dirname($self->path),
    );
}

=item $name = $node-E<gt>name

Fetch the name of the node. This will always be the last element of the node's path. That is, if the path of the node is:

  /foo/bar/baz

then the name of the node is:

  baz

In this API it has been decided that the root node will be represented by the string "/" to match with the normal Unix practice of naming the root tree object. The root node must have this name and no other node may have this name.

=cut

sub name {
    my ($self) = @_;
    return $self->{name} if $self->{name};

    # The name of the root node is '/'
    my $path = $self->{path};
    if ($path eq '/') {
        return $self->{name} = '/';
    } 
    
    else {
        my @components = split m{/}, $path;
        return $self->{name} = pop @components;
    }
}

=item $path = $node-E<gt>path

This returns the full path from the root of the tree to this node.

=cut

sub path {
    my ($self) = @_;
    return $self->{path};
}

=item @nodes = $node-E<gt>nodes

Returns all the child nodes of this node.

=cut

sub nodes {
    my ($self) = @_;
    return 
        map { 
            Content::Repository::Node->new(
                $self->{repository}, 
                normalize_path($self->{path}, $_),
            ) 
        } $self->{repository}->engine->nodes_in($self->{path});
}

=item @properties = $node-E<gt>properties

Returns all the proeprties of this node.

=cut

sub properties {
    my ($self) = @_;
    return 
        map { Content::Repository::Property->new($self, $_) } 
            $self->{repository}->engine->properties_in($self->{path});
}

=item $type = $node-E<gt>type

Returns the L<Content::Repository::Type::Node> object describing the node.

=cut

sub type {
    my ($self) = @_;
    return $self->{repository}->engine->node_type_of($self->{path});
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
