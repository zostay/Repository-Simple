package Content::Repository::Factory;

use strict;
use warnings;

our $VERSION = '0.01';

use Carp;

=head1 NAME

Content::Repository::Factory - Factory for attaching to repositories

=head1 SYNOPSIS

  my $repository = Content::Repository::Factory->attach(
      FileSystem => root => '/var/chroot/foo',
  );

=head1 DESCRIPTION

The L<Content::Repository::Factory> provides the code necessary for locating content repository engines and attaching to storage using the requested engine.

=over 

=item $repository = Content::Repository::Factory->attach($module_name, ...)

This will attach to a repository via the named engine, C<$module_name>. The repository object representing that storage are is returned.

If the C<$module_name> does not contain any colons, then it the package "C<Content::Repository::Engine::$moodule_name>" is loaded. Otherwise, the C<$module_name> is loaded and it's C<new> method is used. For example,

Any additional arguments passed to this method are then passed to the C<new> method of the engine used.

See L<Content::Repository::Engine> if you are interested in the guts.

=cut

sub attach {
	my $class  = shift;
	my $engine = shift;

	$engine =~ /[\w:]+/
		or croak "The given content repository engine, $engine, "
                .'does not appear to be a package name.';

    # XXX should this be configurable?
	$engine =~ /:/
		or $engine = "Content::Repository::Engine::$engine";

	eval "use $engine";
	warn "Failed to load package for engine, $engine: $@" if $@;

	my $instance = eval { $engine->new(@_) };
	if ($@) {
		$@ =~ s/ at .*$//s;
		croak $@ if $@;
	}

	return Content::Repository->new($instance);
}

=back

=head1 AUTHOR

Andrew Sterling Hanenkamp, E<lt>hanenkamp@users.sourceforge.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2005 Andrew Sterling Hanenkamp. All Rights Reserved.

This software is distributed and licensed under the same terms as Perl itself.

=cut

1
