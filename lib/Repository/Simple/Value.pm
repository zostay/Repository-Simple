package Repository::Simple::Value;

use strict;
use warnings;

our $VERSION = '0.01';

=head1 NAME

Repository::Simple::Value - Tie interface to property values

=head1 DESCRIPTION

This class is used for access a property value. This class is never instantiated directly, but retrieved from a property via the C<value()> method:

  my $value = $property->value;
  my $scalar = $value->get_scalar;
  my $handle = $handle->get_handle('<');

=head2 METHODS

=over

=cut

# $value = Repository::Simple::Value->new($engine, $path)
#
# Create a value object.
#
sub new {
    my ($class, $engine, $path) = @_;

    return bless { 
        engine => $engine,
        path => $path,
    }, $class;
}

=item $scalar = $value-E<gt>get_scalar

Retrieve the value of the property as a scalar value.

=cut

sub get_scalar {
    my $self = shift;

    return $self->{engine}->get_scalar($self->{path});
}

=item $handle = $value-E<gt>get_handle

=item $handle = $value-E<gt>get_handle($mode)

Retrieve the value of the property as an IO handle. The C<$mode> argument is used to specify what kind of handle it is. It should be one of:

=over

=item *

"<"

=item *

">"

=item *

">>"

=item *

"+<"

=item *

"+>"

=item *

"+>>"

=back

If the value cannot be returned with a handle in the given mode, the method will croak. If C<$mode> is not given, then "<" is assumed.

=cut

sub get_handle {
    my ($self, $mode) = @_;

    return $self->{engine}->get_handle($self->{path}, $mode)
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
