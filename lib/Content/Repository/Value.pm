package Content::Repository::Value;

use strict;
use warnings;

our $VERSION = '0.01';

=head1 NAME

Content::Repository::Value - Tie interface to property values

=head1 DESCRIPTION

This class is used as a helper to L<Content::Repository::Property> and L<Content::Repository::PropertyType>. Do not use this directly. Ever.

=cut

sub TIESCALAR {
    my ($class, $type, $value) = @_;

    my $self = bless { 
        type     => $type, 
        value    => $type->inflate($value),
    }, $class;

    return $self;
}

sub FETCH {
    my $self = shift;
    return $self->{value};
}

sub STORE {
    my ($self, $value) = @_;
    $self->{type}->check($value);
    $self->{changed}++;
    $self->{value} = shift;
}

sub has_changed {
    my $self = shift;
    return $self->{changed};
}

sub value {
    my $self = shift;
    return $self->{type}->deflate($self->{value});
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
