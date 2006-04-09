package Content::Repository::Type::Value;

use strict;
use warnings;

use Readonly;

require Exporter;

our @ISA = qw( Exporter );

our $VERSION = '0.01';

our @EXPORT_OK = qw(
    $SCALAR_TYPE
    $HANDLE_TYPE
);

our %EXPORT_TAGS = ( type_constants => \@EXPORT_OK );

# Type constants
Readonly our $SCALAR_TYPE  => 'STRING';
Readonly our $HANDLE_TYPE  => 'HANDLE';

=head1 NAME

Content::Repository::Type::Value - Abstract base class for value types

=head1 SYNOPSIS

  package Content::Repository::Type::Value::MyValueType;

  use Content::Repository::Type::Value qw( $STRING_TYPE );
  use base qw( Content::Repository::Type::Value );

  sub name { 
      return 'my:valueType'; 
  }

  sub storage_type {
      return $SCALAR_TYPE;
  }

  # Only strings starting with "Foo" are accepted
  sub check {
      my ($self, $value) = @_;
      $value =~ /^Foo/
          or die qq(Value "$value" does not start with "Foo".);
  }

  # Since they all start with foo, deflate() strips it and inflate() adds it
  # back in
  sub inflate {
      my ($self, $value) = @_;
      $value =~ s/^/Foo/;
      return $value;
  }

  sub deflate {
      my ($self, $value) = @_;
      $value =~ s/^Foo// or die qq(Bad value "$value" stored!);
      return $value;
  }

=head1 DESCRIPTION

If you are just a casual user of L<Content::Repository>, then the nature of this class isn't a concern. However, if you want to extend the functionality of L<Content::Repository>, then you may be interested in this class.

To create a value type, subclass this class and implement the various methods as appropriate. Below are listed the expected inputs/outputs for each method and the nature of the default implementation, if one is provided.

=head2 METHODS

=over

=item $value_type = Content::Repository::Type::Value-E<gt>new(@args)

Your type should provide a well-documented constructor.

=item $name = $value_type-E<gt>name

This method MUST be implemented by the subclass. It should return a short string naming the class. This name should be in "ns:name" form as namespaces are an intended feature for implementation in the future.

=cut

sub name { die "Subclasses must implement this method." }

=item $type = $value_type-E<gt>storage_type

The value returned, C<$type>, represents the underlying storage mechanism required to store a value of this type.

Each of the following constants can be imported from this package:

  use Content::Repository::Type::Value qw( $SCALAR_TYPE );

  # OR, to get all of them:
  use Content::Repository::Type::Value qw( :type_constants );

The constants have the following meanings:

=over

=item C<$SCALAR_TYPE>

This holds a scalar value of arbitrary length. A scalar is a string or number.

=item C<$HANDLE_TYPE>

These values are stored as file handles. The file handle will be returned as a reference to a GLOB. The fact that it is a handle does not specify whether the file handle is for input, output, bidirectional, or seekable. 

=back

=item $value_type-E<gt>check($value)

Given a scalar value, this method SHOULD throw an exception if the value is not acceptable for some reason. If the value is acceptable, the method MUST NOT throw an exception.

The default implementation never throws an exception;

=cut

sub check {}

=item $inflated_value = $value_type-E<gt>inflate($deflated_value)

Given a flat scalar string value, this method MUST transform the value into the representation to be accessed by the end-user, and return that as a scalar (possibly a reference to a complex type). 

For example, if this type represents a L<DateTime> object, then the method will translate some string formatted date and parse it into a L<DateTime> object.

The default implementation doesn't modify the flat string representation.

=cut

sub inflate {}

=item $deflated_value = $value_type-E<gt>deflate($inflated_value)

Given the end-user representation of this type (possibly a reference to a complex type), this method MUST transform the value into a flat scalar string value for storage and return it.

For example, if this type represents a L<DateTime> object, then the method should return a string representation of the L<DateTime> object.

The default implementation doesn't modify the C<$inflated_value> at all.

=cut

sub deflate {}

=head1 AUTHOR

Andrew Sterling Hanenkamp, E<lt>hanenkamp@cpan.orgE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright 2006 Andrew Sterling Hanenkamp E<lt>hanenkamp@cpan.orgE<gt>.  All 
Rights Reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself. See L<perlartistic>.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE.

=cut

1
