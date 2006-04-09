package Repository::Simple::Value;

use strict;
use warnings;

our $VERSION = '0.01';

=head1 NAME

Repository::Simple::Value - Tie interface to property values

=head1 DESCRIPTION

This class is used as a helper to L<Repository::Simple::Property> and L<Repository::Simple::Type::Value>. Do not use this directly. Ever.

=cut

sub new {
    my ($class, $engine, $path) = @_;

    return bless { 
        engine => $engine,
        path => $path,
    }, $class;
}

sub get_scalar {
    my $self = shift;

    return $self->{engine}->get_scalar($self->{path});
}

sub get_handle {
    my ($self, $mode) = @_;

    return $self->{engine}->get_handle($self->{path}, $mode)
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
