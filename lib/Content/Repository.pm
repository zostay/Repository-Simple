package Content::Repository;

use strict;
use warnings;

our $VERSION = '0.01';

use Content::Repository::Factory;

=head1 NAME

Content::Repository - Content Repository system for Perl

=head1 SYNOPSIS

  use Content::Repository;

  my $repository = Content::Repository::Factory->attach(
      FileSystem => root => /home/foo
  );

=head1 DESCRIPTION

This content repository system is loosely based upon the L<File::System> module I've written combined with ideas from the JSR 170 standard for Content Repositories in Java.

The goal of this package is to provide a content repository system with a similar feature set. I considered implementing a JSR 170 repository using the Perl language rather than Java. However, this would have required creating a new library from scratch, and I was interested in creating a workable solution in a short amount of time. Therefore, I have compromised by creating a repository system that is in the same spirit, but a completely different implementation.

=head1 CONTENT REPOSITORY

This package provides an API for implementing content repository engines, an API for storing nodes, properties, and values into those engines, and connection factories for gaining access to these content repository engines. This package also comes with an engine used to gain access to a file system.

The basic idea is that every content repository is comprised of objects. We call this objects "nodes". Nodes are arranged in a rooted hierarchy. At the top is a single node named "/" (this differs from JSR 170, where the root is named "", but is more like typical basename implementations). Each node may have zero or more child nodes under them.

In addition to nodes, there are fields associated with nodes, called "properties". Each property has a name and value.

A given content repository may only store items that follow a specific schema. Each node has an associated node type. Each property has an associated property type. The node and property types determine what a valid hierarchy will look like for a repository.

The functionality available in a given repository is determined by the content repository engine which is used to run it. At the back-end of this API is a simple interface for creating new kinds of engines. A number of prebuilt engines are also available for compositing repositories together in interesting ways.

=head2 REPOSITORY ENGINE

This content repository package implements a bridge pattern for implementing repositories. Rather than having each engine implement several packages covering nodes, properties, values, and other parts, each engine is a single package containing definitions for all the methods required to access the repository's storage.

You never interact with the repository engine directly after you instantiate it using the repository connection factory:

  my $repository = Content::Repository::Factory->connect(...);

The returned repository object, C<$repository> in this example, is an instance of L<Content::Repository>, which holds an internal reference to the engine. Thus, you never need to be aware of how the engine works after instantiation.

If you are interested in building a repository engine, the details of repository engine design may be found in L<Content::Repository::Engine>.

=head2 THIS CLASS

This class provides the entry point into the repository API. The typical way of getting a reference to an instance of this class is to use the L<Content::Repository::Factory> class to connect to a repository. The C<connect()> method of that class returns an instance of this class.

As an alternative, you may also instantiate an engine directly:

  my $engine = MyProject::Content::Engine->new;
  my $repository = Content::Repository->new($engine);

This shouldn't be necessary in most cases though, since this is the same as:

  my $repository 
      = Content::Repository::Factory->connect('MyProject::Content::Engine');

An instance of this class may be used to retrieve information about the repository, fetch nodes or properties, and manipulate the repository.

=head1 METHODS

=over

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

Returns the L<Content::Repository::NodeType> object for the given C<$type_name> or returns C<undef> if no such type exists in the repository.

=cut

sub node_type {
    my ($self, $type_name) = @_;
    return $self->engine->fetch_node_type_named($type_name);
}

=item $property_type = $repository-E<gt>property_type($type_name)

Returns the L<Content::Repository::PropertyType> object for the given C<$type_name> or returns C<undef> if no such type exists in the repository.

=cut

sub property_type {
    my ($self, $type_name) = @_;
    return $self->engine->fetch_property_type_named($type_name);
}

=item $root_node = $repository-E<gt>root_node

Return the root node in the repository.

=cut

sub root_node {
    my $self = shift;
    return Content::Repository::Node->new($self, "/");
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
