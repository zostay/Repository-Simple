package Content::Repository;

use strict;
use warnings;

our $VERSION = '0.01';

use Carp;
use Content::Repository::Node;

=head1 NAME

Content::Repository - Content Repository system for Perl

=head1 SYNOPSIS

  use Content::Repository;

  my $repository = Content::Repository->attach(
      FileSystem => root => /home/foo
  );

=head1 DESCRIPTION

This content repository system is loosely based upon the L<File::System> module I've written combined with ideas from the JSR 170 standard for Content Repositories in Java.

The goal of this package is to provide a content repository system with a similar feature set. At this time, I have created a compromise between closely adhering to JSR 170 and providing a system that has similar features. I think it would be a good goal to aim for loose compatibility, but it is not my intent to adhere to the strict letter of that standard. See L</"DIFFERENCES FROM JSR 170"> for details of the major deviations.

=head1 CONTENT REPOSITORY

This package provides an API for implementing content repository engines, an API for storing nodes, properties, and values into those engines, and connection factories for gaining access to these content repository engines. This package also comes with an engine used to gain access to a file system.

The basic idea is that every content repository is comprised of objects. We call this objects "nodes". Nodes are arranged in a rooted hierarchy. At the top is a single node named "/" (this differs from JSR 170, where the root is named "", but is more like typical basename implementations). Each node may have zero or more child nodes under them.

In addition to nodes, there are fields associated with nodes, called "properties". Each property has a name and value.

A given content repository may only store items that follow a specific schema. Each node has an associated node type. Each property has an associated property type. The node and property types determine what a valid hierarchy will look like for a repository.

The functionality available in a given repository is determined by the content repository engine which is used to run it. At the back-end of this API is a simple interface for creating new kinds of engines. A number of prebuilt engines are also available for compositing repositories together in interesting ways.

=head2 REPOSITORY ENGINE

This content repository package implements a bridge pattern for implementing repositories. Rather than having each engine implement several packages covering nodes, properties, values, and other parts, each engine is a single package containing definitions for all the methods required to access the repository's storage.

You never interact with the repository engine directly after you instantiate it using the repository connection factory method, C<attach()>:

  my $repository = Content::Repository->attach(...);

The returned repository object, C<$repository> in this example, is an instance of L<Content::Repository>, which holds an internal reference to the engine. Thus, you never need to be aware of how the engine works after instantiation.

If you are interested in building a repository engine, the details of repository engine design may be found in L<Content::Repository::Engine>.

=head2 THIS CLASS

This class provides the entry point into the repository API. The typical way of getting a reference to an instance of this class is to use the L<attach()> method to connect to a repository. This method of returns an instance of L<Content::Repository>, which encapsulates the requested repository engine connection.

As an alternative, you may also instantiate an engine directly:

  my $engine = MyProject::Content::Engine->new;
  my $repository = Content::Repository->new($engine);

This shouldn't be necessary in most cases though, since this is the same as:

  my $repository 
      = Content::Repository->attach('MyProject::Content::Engine');

An instance of this class may be used to retrieve information about the repository, fetch nodes or properties, and manipulate the repository.

=head1 METHODS

=over

=item $repository = Content::Repository-E<gt>attach($module_name, ...)

This will attach to a repository via the named engine, C<$module_name>. The repository object representing that storage is returned.

If the C<$module_name does not contain any colons, then the package "C<Content::Repository::Engine::$module_name>" is loaded. Otherwise, the C<$module_name> is loaded and its C<new> method is used.

Any additional arguments passed to this method are then passed to the C<new> method of the engine.

See L<Content::Repository::Engine> if you are interested in the guts.

=cut

sub attach {
    my ($class, $engine) = @_;

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
        $@ =~ s/ at .*//s;
        croak $@ if $@;
    }

    return Content::Repository->new($instance);
}

=item $repository = Content::Repository-E<gt>new($engine)

Given an engine, this constructor wraps the engine with a repository object.

=cut

sub new {
    my ($class, $engine) = @_;
    return bless { engine => $engine }, $class;
}

=item $engine = $repository-E<gt>engine

Returns a reference to the engine this repository is using.

=cut

sub engine {
    my ($self) = @_;
    return $self->{engine};
}

=item $node_type = $repository-E<gt>node_type($type_name)

Returns the L<Content::Repository::Type::Node> object for the given C<$type_name> or returns C<undef> if no such type exists in the repository.

=cut

sub node_type {
    my ($self, $type_name) = @_;

    if (!defined $type_name) {
        croak 'no type name given for lookup';
    }

    return $self->engine->node_type_named($type_name);
}

=item $property_type = $repository-E<gt>property_type($type_name)

Returns the L<Content::Repository::Type::Property> object for the given C<$type_name> or returns C<undef> if no such type exists in the repository.

=cut

sub property_type {
    my ($self, $type_name) = @_;

    if (!defined $type_name) {
        croak 'no type name given for lookup';
    }

    return $self->engine->property_type_named($type_name);
}

=item $root_node = $repository-E<gt>root_node

Return the root node in the repository.

=cut

sub root_node {
    my $self = shift;
    return Content::Repository::Node->new($self, "/");
}

=back

=head1 DIFFERENCES FROM JSR 170

I would like this implementation of a content repository system to provide a superset of the functionality provided by JSR 170. It is my expectation that it is more likely for Perl programs to access JSR 170 repositories than for Java or other language implementations to access a Perl repository. After I get this interface stabilized, I would like to create or see created interfaces to Apache's JackRabbit, Day's CRX, and perhaps others.

B<Typing is flexible rather than strict.> The functionality provided by this library is a superset because it avoids some of the stricter rules of implementation. For example, this implementation really does nothing to define any preset node types or property types. Implementations do not have to have a type named "nt:base". Furthermore, the value mapping system allows for much greater flexibility in the values stored in the repository than the strict Value class given by the JSR 170 specification.

B<Simplified interface.> The JSR 170 interface library includes several dozen classes. This implementation does not provide a corresponding implementation to most of these. Instead, I have tried to simplify by using Perl built-in data types whenever possible. I believe this interface provides a very Perlish representation of the concepts of JSR 170 while not quite adhering to the enormous API interface given by the specification.

There are surely other important differences, but I haven't thought of them to write them down yet.

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
