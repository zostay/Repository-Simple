package Content::Repository::Type::Property;

use strict;
use warnings;

use Carp;

our $VERSION = '0.01';

use Content::Repository::Type::Value::Scalar;
use Scalar::Util qw( weaken );

=head1 NAME

Content::Repository::Type::Property - Types for content repository properties

=head1 SYNOPSIS

  sub print_property_type {
      my $property = shift;

      my $type = $property->type;

      print " * ", $property->name, " : ", $type->name, " {";
      my %options = $type->options;
      while (my ($k,$v) = each %options) { print " $k=>$v" }
      print " }";
      print " [RO]"  if !$type->mutable;
      print " [REQ]" if  $type->required;
      print "\n";
      
  }

=head1 DESCRIPTION

Property types are used to determine information about what kind of information is acceptable for a property value. This class provides a flexible way of describing the possible values, a method for marshalling and unmarshalling those values to and from a scalar for storage, and other metadata about possible values.

=head2 METHODS

=over

=item $type = Content::Repository::Type::Property-E<gt>new(%args)

Creates a new property type with the given arguments, C<%args>. 

The following arguments are used:

=over

=item engine (required)

This is a reference to the storage engine owning this property type.

=item name (required)

This is a short identifying name for the type.

=item auto_created

This property should be set to true if the creation of a node containing a property of this type triggers the creation of a property of this type.

By default, this value is false.

=item updatable

This property should be set to true if the value stored in the property cannot be changed.

By default, this value is false.

=item removable

When this property is set to a true value, this property may not be set to C<undef> or deleted. 

By default, this value is false.

=item value_type

This property should be set to an instance of L<Content::Repository::Type::Value> for the type of value that is stored in it.

By default, this is set to an instance of L<Content::Repository::Type::Value::Scalar>.

=back

=cut

sub new {
    my $class = shift;
    my %args  = @_;

    if (!defined $args{engine}) {
        croak 'The "engine" argument must be given.';
    }

    weaken $args{engine};

    if (!defined $args{name}) {
        croak 'The "name" argument must be given.';
    }

    $args{auto_created} ||= 0;
    $args{updatable}    ||= 0;
    $args{removable}    ||= 0;
    $args{value_type}   ||= Content::Repository::Type::Value::Scalar->new;

    return bless \%args, $class;
}

=item $name = $type-E<gt>name

This method returns the name of the type.

=cut

sub name {
    my $self = shift;
    return $self->{name};
}

=item $auto_created = $type-E<gt>auto_created

Returns a true value if the property is automatically created with the parent.

=cut

sub auto_created {
    my $self = shift;
    return $self->{auto_created};
}

=item $updatable = $type-E<gt>updatable

Returns a true value if the value may be changed.

=cut

sub updatable {
    my $self = shift;
    return $self->{updatable};
}

=item $removable = $type-E<gt>removable

Returns a true value if the value may be removed from it's parent node.

=cut

sub removable {
    my $self = shift;
    return $self->{removable};
}

=item $value_type = $type-E<gt>value_type

Returns the value type of the properties value.

=cut

sub value_type {
    my $self = shift;
    return $self->{value_type};
}

# =item $type-E<gt>check($value)
# 
# Given an inflated value, this method will check to see that the value is valid. If the type is immutable, i.e., C<mutable()> returns false, then this method will always croak with the message:
# 
#   Cannot change immutable property.
# 
# If the type is required, i.e., C<required()> returns true, then this method will croak when C<$value> is set to C<undef> with this message:
# 
#   This property is required and may not be unset or deleted.
# 
# In any other case, this method will throw the exceptions thrown by the check subroutine given during construction. If no check subroutine was given, no exception will be thrown.
# 
# =cut
# 
# sub check {
#     my ($self, $value) = @_;
# 
#     if (!$self->{mutable}) {
#         croak 'Cannot change immutable property.';
#     }
# 
#     if ($self->{required} && !defined $value) {
#         croak 'This property is required and may not be unset or deleted.';
#     }
# 
#     if (defined $self->{check}) {
#         $self->{check}->($self, $value);
#     }
# 
#     return 1;
# }
# 
# =item $inflated_value = $type-E<gt>inflate($deflated_value)
# 
# This method uses the C<inflate> subroutine given during construction to inflate the C<$deflated_value> given. If no subroutine was given, then the C<$inflated_value> will be identical to the C<$deflated_value>.
# 
# =cut
# 
# sub inflate {
#     my ($self, $value) = @_;
# 
#     if (defined $self->{inflate}) {
#         return $self->{inflate}->($self, $value);
#     }
# 
#     else {
#         return $value;
#     }
# }
# 
# =item $deflated_value = $type-E<gt>deflate($inflated_value)
# 
# This method uses the C<deflate> subroutine given during construction to deflate the C<$inflated_value> given. If no subroutine was given, then the C<$deflated_value> will be identical to the C<$inflated_value>.
# 
# =cut
# 
# sub deflate {
#     my ($self, $value) = @_;
# 
#     if (defined $self->{deflate}) {
#         return $self->{deflate}->($self, $value);
#     }
# 
#     else {
#         return $value;
#     }
# }

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
