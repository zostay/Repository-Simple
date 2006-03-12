package Content::Repository::Property;

use strict;
use warnings;

our $VERSION = '0.01';

=head1 NAME

Content::Repository::Property - Content repository property information

=head1 SYNOPSIS

See L<Content::Repository::Node>.

=head1 DESCRIPTION

Each instance of this class represents a single property of a node.

To retrieve a property instance, do not construct the object directly. Rather, use the methods associated with a node to retrieve the properties associated with that node.

Each property has a parent (node), a name, a value, and a type. The key is non-empty string identifying the property. The value is a valid value according to the property type. The type is an instance of L<Content::Repository::PropertyType>. If a property value is set to C<undef>, this is the same as deleting the property from the parent node.

=cut

# $property = Content::Repository::Property->new($node, $name, $value)
#
# Create a new property object.
sub new {
    my ($class, $node, $name, $value) = @_;
    return bless {
        node  => $node,
        name  => $name,
        value => $value,
    }, $class;
}

=item $node = $self-E<gt>parent

Get the node to which this property belongs.

=cut

sub parent {
    my $self = shift;
    return $self->{node};
}

=item $name = $self-E<gt>name

Get the name of the property.

=cut

sub name {
    my $self = shift;
    return $self->{name};
}

=item $path = $self-E<gt>path

Get the full path to the property.

=cut

sub path {
    my $self = shift;
    return $self->{node}.'/'.$self->{name};
}

=item $value = $self-E<gt>value

Retrieve the value stored in the property.

=cut

sub value {
    my $self = shift;
    return $self->{value};
}

=item $type = $self-E<gt>type

Retrieve the L<Content::Repository::PropertyType> used to validate and store values for this property.

=cut

sub type {
    my $self = shift;
    my %property_types = $self->{node}->type->child_properties;
    my $type_name = $property_types{ $self->{name} };
    return $self->{node}->repository->property_type($type_name);
}

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
