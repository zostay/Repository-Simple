package Content::Repository::PropertyType;

use strict;
use warnings;

use Carp;

our $VERSION = '0.01';

=head1 NAME

Content::Repository::PropertyType - Types for content repository properties

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

=item $type = Content::Repository::PropertyType-E<gt>new(%args)

Creates a new property type with the given arguments, C<%args>. 

The following arguments are used:

=over

=item name (required)

This is a short identifying name for the type.

=item default

This is the default value that should be assigned to the property upon creation. If none is given, then the value must be set explicitly.

=item options

This is a hash of additional options to pass to the type. This can be used to provide modifiers used by the check, inflate, and deflate methods.

=item auto_created

This property should be set to true if the creation of a node containing a property of this type triggers the creation of a property of this type. If this is true, then the "default" property must be set.

By default, this value is false.

=item mutable

This is a property for all property types stating whether or not the value may be set. A false value is assumed by default, so values are read-only unless this is set to true.

=item required

When this property is set to a true value, this property may not be set to C<undef> or deleted. By default this is false, so values are not required unless this is set to true.

=item check

This is a reference to a subroutine responsible for validating the data stored into a property value. This subroutine should expect two arguments. The first argument will be the type object returned by this constructor. The second argument will be the value to check. 

The subroutine should throw an exception describing the problem if there is a problem with the value. Any other action by the subroutine is ignored. The subroutine MUST NOT change the value passed or the state of the type object.

If no routine is provided, then all values will be considered valid.

=item inflate

This is a reference to a subroutine responsible for converting a value from a scalar to its Perl form. This subroutine should expect two arguments. The first argument will be the type object returned by this constructor. The second argument will be the value to convert.

The subroutine should return a scalar object, reference, or other scalar representing the Perl version.

If no routine is provided, then all values will be left as-is.

=item deflate

This is a reference to a subroutine responsible for converting a value from its Perl form to a plain scalar value. This subroutine should expect two arguments. The first argument will be the type object returned by this constructor. The second argument will be the value to convert.

The subroutine should return a plain scalar representing the object, i.e., a string or a number.

If no routine is provided, then all values will be left as-is.

=back

=cut

sub new {
    my $class = shift;
    my %args  = @_;

    if (!defined $args{name}) {
        croak 'The "name" argument must be given.';
    }

    if (defined $args{auto_created} && !defined $args{default}) {
        croak 'The "default" argument must be given if "auto_created" is true.';
    }

    $args{mutable}      ||= 0;
    $args{required}     ||= 0;
    $args{auto_created} ||= 0;

    return bless \%args, $class;
}

=item $name = $type-E<gt>name

This method returns the name of the type.

=cut

sub name {
    my $self = shift;
    return $self->{name};
}

=item $value = $type-E<gt>default

This method returns the default value for the type.

=cut

sub default {
    my $self = shift;
    return $self->{default};
}

=item %options = $type-E<gt>options

This method returns the entire options hash.

=cut

sub options {
    my $self = shift;
    return %{ $self->{options} };
}

=item $option_value = $type-E<gt>option($option_name)

This method returns the value for the named C<$option_name>. 

=item @option_values = $type-E<gt>option(@option_names)

This method returns the values for the named C<@option_names>. This works just like a hash slice.

=cut

sub option {
    my $self = shift;

    if (wantarray) {
        return @{ $self->{options} }{ @_ };
    }

    else {
        return $self->{options}{ $_[0] };
    }
}

=item $mutable = $type-E<gt>mutable

Returns a true value if the value may be changed.

=cut

sub mutable {
    my $self = shift;
    return $self->{mutable};
}

=item $required = $type-E<gt>required

Returns a true value if the value is required.

=cut

sub required {
    my $self = shift;
    return $self->{required};
}

=item $type-E<gt>check($value)

Given an inflated value, this method will check to see that the value is valid. If the type is immutable, i.e., C<mutable()> returns false, then this method will always croak with the message:

  Cannot change immutable property.

If the type is required, i.e., C<required()> returns true, then this method will croak when C<$value> is set to C<undef> with this message:

  This property is required and may not be unset or deleted.

In any other case, this method will throw the exceptions thrown by the check subroutine given during construction. If no check subroutine was given, no exception will be thrown.

=cut

sub check {
    my ($self, $value) = @_;

    if (!$self->{mutable}) {
        croak 'Cannot change immutable property.';
    }

    if ($self->{required} && !defined $value) {
        croak 'This property is required and may not be unset or deleted.';
    }

    if (defined $self->{check}) {
        $self->{check}->($self, $value);
    }

    return 1;
}

=item $inflated_value = $type-E<gt>inflate($deflated_value)

This method uses the C<inflate> subroutine given during construction to inflate the C<$deflated_value> given. If no subroutine was given, then the C<$inflated_value> will be identical to the C<$deflated_value>.

=cut

sub inflate {
    my ($self, $value) = @_;

    if (defined $self->{inflate}) {
        return $self->{inflate}->($self, $value);
    }

    else {
        return $value;
    }
}

=item $deflated_value = $type-E<gt>deflate($inflated_value)

This method uses the C<deflate> subroutine given during construction to deflate the C<$inflated_value> given. If no subroutine was given, then the C<$deflated_value> will be identical to the C<$inflated_value>.

=cut

sub deflate {
    my ($self, $value) = @_;

    if (defined $self->{deflate}) {
        return $self->{deflate}->($self, $value);
    }

    else {
        return $value;
    }
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
