package Content::Repository::Engine::FileSystem;

use strict;
use warnings;

our $VERSION = '0.01';

use Carp;
use Content::Repository::Engine qw( $NODE_EXISTS $PROPERTY_EXISTS $NOT_EXISTS );
use Content::Repository::Type::Node;
use Content::Repository::Type::Property;
use Content::Repository::Util qw( dirname basename );
use File::Spec;
use IO::Scalar;
use Symbol;

use base 'Content::Repository::Engine';

=head1 NAME

Content::Repository::Engine::FileSystem - Content repository in the real FS

=head1 SYNOPSIS

  use Content::Repository;
  my $fs = Content::Repository::Factory->('FileSystem', root => '/usr/local');

=head1 DESCRIPTION

Each node in this content repository is a file system file. As of this writing, the repository is capable of handling directories and files. All other file types may or may not be handled appropriate.

=head1 OPTIONS

This file system module accepts only a single option, C<root>. If not given, the current working directory is assumed for the value C<root>. All files returned by the file system will be rooted at the given (or assumed) point.

=cut

my %node_type_defs = (
    'fs:object' => {
        name     => 'fs:object',
        property_types => {
            'fs:dev'     => 'fs:scalar-static',
            'fs:ino'     => 'fs:scalar-static',
            'fs:mode'    => 'fs:scalar',
            'fs:nlink'   => 'fs:scalar-static',
            'fs:uid'     => 'fs:scalar',
            'fs:gid'     => 'fs:scalar',
            'fs:rdev'    => 'fs:scalar-static',
            'fs:size'    => 'fs:scalar-static',
            'fs:atime'   => 'fs:scalar',
            'fs:mtime'   => 'fs:scalar',
            'fs:ctime'   => 'fs:scalar',
            'fs:blksize' => 'fs:scalar-static',
            'fs:blocks'  => 'fs:scalar-static',
        },
        updatable => 1,
        removable => 1,
    },

    'fs:file' => {
        name        => 'fs:file',
        super_types => [ qw( fs:object ) ],
        property_types => {
            'fs:content' => 'fs:handle',
        },
        updatable => 1,
        removable => 1,
    },

    'fs:directory' => {
        name        => 'fs:directory',
        super_types => [ qw( fs:object ) ],
        node_types => {
            '*' => [ 'fs:object' ],
        },
        updatable => 1,
        removable => 1,
    },
);

my %property_type_defs = (
    'fs:scalar' => {
        name         => 'fs:scalar',
        auto_created => 1,
        updatable    => 1,
        removable    => 0,
    },

    'fs:scalar-static' => {
        name         => 'fs:scalar-static',
        auto_created => 1,
        updatable    => 0,
        removable    => 0,
    },
    
    'fs:handle' => {
        name         => 'fs:handle',
        auto_created => 1,
        updatable    => 0,
        removable    => 0,
    },
);

my %stat_names = (
    'fs:dev'     => 0,
    'fs:ino'     => 1,
    'fs:mode'    => 2,
    'fs:nlink'   => 3,
    'fs:uid'     => 4,
    'fs:gid'     => 5,
    'fs:rdev'    => 6,
    'fs:size'    => 7,
    'fs:atime'   => 8,
    'fs:mtime'   => 9,
    'fs:ctime'   => 10,
    'fs:blksize' => 11,
    'fs:blocks'  => 12,
);

sub new {
	my $class = shift;
	my %args  = @_;

	$args{root} ||= '.';
	$args{root} = File::Spec->rel2abs($args{root});
	my $root = File::Spec->canonpath($args{root});

	-e $root or croak "Sorry, root $root does not exist!";
	-d $root or croak "Sorry, root $root is not a directory!";

	my $self = bless {
		fs_root  => $root,
	}, $class;

    while (my ($name, $node_def) = each %node_type_defs) {
        $self->{node_types}{$name}
            = Content::Repository::Type::Node->new(
                engine => $self,
                %$node_def,
            );
    }

    while (my ($name, $prop_def) = each %property_type_defs) {
        $self->{property_types}{$name}
            = Content::Repository::Type::Property->new(
                engine => $self,
                %$prop_def,
            );
    }

    return $self;
}

sub node_type_named {
    my ($self, $type_name) = @_;
    return $self->{node_types}{ $type_name };
}

sub property_type_named {
    my ($self, $type_name) = @_;
    return $self->{property_types}{ $type_name };
}

sub nodes_in {
    my ($self, $path) = @_;

    my $real_path = $self->real_path($path);
    
    $self->check_real_path($real_path, $path);

    if (!-d $real_path) {
        return ();
    }

    my $handle = gensym;
    opendir $handle, $real_path 
        or croak qq(failed to readdir for path "$path");
    my @dirs = grep { $_ !~ /^\.\.?$/ } readdir $handle;
    closedir $handle;

    return @dirs;
}

sub properties_in {
    my ($self, $path) = @_;

    my $real_path = $self->real_path($path);

    $self->check_real_path($real_path, $path);

    my @properties = keys %stat_names;

    if (-f $real_path) {
        push @properties, 'fs:content';
    }

    return @properties;
}

sub node_type_of {
    my ($self, $path) = @_;

    my $real_path = $self->real_path($path);

    $self->check_real_path($real_path, $path);

    if (-d $real_path) {
        return $self->{node_types}{'fs:directory'};
    }

    elsif (-f $real_path) {
        return $self->{node_types}{'fs:file'};
    }

    else {
        return $self->{node_types}{'fs:object'};
    }
}

sub property_type_of {
    my ($self, $path) = @_;

    my $basename = basename($path);
    my $dirname  = dirname($path);

    my $node_type = $self->node_type_of($dirname);
    my %property_types = $node_type->property_types;

    if (!defined $property_types{$basename}) {
        croak qq(no property named "$basename" for node "$dirname");
    }

    return $self->property_type_named($property_types{$basename});
}

sub path_exists {
	my ($self, $path) = @_;

    my $dirname  = dirname($path);
    my $basename = basename($path);

    my $real_path = $self->real_path($path);

    # If it is a node path, just find if it exists
    return $NODE_EXISTS if -e $real_path;

    # Next, check to see if it's a property
    my $property = $basename =~ m[
        fs:
            (?: dev     | ino     | mode  | nlink 
              | uid     | gid     | rdev  | size
              | atime   | mtime   | ctime | blksize 
              | blocks  | content )
    ]x;

    if ($property) {
        $real_path = $self->real_path($dirname);

        # fs:content exists only if the path is a file, the other properties
        # exist for both files or directories
        if ($basename eq 'fs:content') {
            return -f $real_path ? $PROPERTY_EXISTS : $NOT_EXISTS;
        }

        else {
            return -e $real_path ? $PROPERTY_EXISTS : $NOT_EXISTS;
        }
    }

    # Doesn't exist
    return $NOT_EXISTS;
}

sub _get_scalar {
    my ($self, $file, $property) = @_;

    return (stat $file)[ $stat_names{ $property } ];
}

sub _get_handle {
    my ($self, $dirname, $file, $mode) = @_;

    my $handle = gensym;
    open $handle, $mode, $file
        or croak qq(failed to read "fs:content" property of node ),
                 qq("$dirname");

    return $handle;
}

sub get_scalar {
    my ($self, $path) = @_;

    my $basename = basename($path);
    my $dirname  = dirname($path);

    my $real_path = $self->real_path($dirname);

    $self->check_real_path($real_path, $dirname);

    if ($basename eq 'fs:content') {
        unless (-f $real_path) {
            croak qq(no "fs:content" property associated with node at ),
                  qq("$dirname");
        }

        my $handle = $self->_get_handle($dirname, $real_path, '<');
        my $scalar = join '', <$handle>;
        close $handle;

        return $scalar;
    }

    elsif (defined $stat_names{ $basename }) {
        return $self->_get_scalar($real_path, $basename);
    }

    else {
        croak qq(no "$basename" property associated with node at "$dirname");
    }
}

sub get_handle {
    my ($self, $path, $mode) = @_;

    $mode ||= '<';

    if ($mode ne '<') {
        croak qq(invalid mode "$mode" given);
    }

    my $basename = basename($path);
    my $dirname  = dirname($path);

    my $real_path = $self->real_path($dirname);

    $self->check_real_path($real_path, $dirname);

    if ($basename eq 'fs:content') {
        if (!-f $real_path) {
            croak qq(no "fs:content" property associated with node at ),
                  qq("$dirname");
        }

        return $self->_get_handle($dirname, $real_path, '<');
    }

    elsif (defined $stat_names{ $basename }) {
        my $scalar = $self->_get_scalar($real_path, $basename);
        return IO::Scalar->new(\$scalar);
    }

    else {
        croak qq(no "$basename" property associated with node at "$dirname");
    }
}

sub real_path {
    my ($self, $fs_path) = @_;

    return File::Spec->catfile($self->{fs_root}, $fs_path);
}

sub check_real_path {
    my ($self, $real_path, $path) = @_;

    if (!-e $real_path) {
        croak qq(no file found at path "$path");
    }
}

=head1 SEE ALSO

L<File::System>, L<File::System::Object>

=head1 AUTHOR

Andrew Sterling Hanenkamp, E<lt>hanenkamp@users.sourceforge.netE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2005 Andrew Sterling Hanenkamp. All Rights Reserved.

This software is distributed and licensed under the same terms as Perl itself.

=cut

1
