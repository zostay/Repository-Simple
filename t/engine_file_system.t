# vim: set ft=perl :

use strict;
use warnings;

use Test::More tests => 280;

use_ok('Repository::Simple::Engine::FileSystem');

use Repository::Simple::Engine qw( $NODE_EXISTS $PROPERTY_EXISTS );

# Test construction
my $engine = Repository::Simple::Engine::FileSystem->new(root => 't/root');
ok($engine, 'new');
isa_ok($engine, 'Repository::Simple::Engine', 'engine isa engine');
isa_ok($engine, 'Repository::Simple::Engine::FileSystem', 
    'engine isa file system');

# Test methods
can_ok($engine, qw(
    new
    node_type_named
    property_type_named
    path_exists
    node_type_of
    property_type_of
    nodes_in
    properties_in
    get_scalar
    get_handle
    namespaces
));

# Test fs:object node type
my $fs_object = $engine->node_type_named('fs:object');
ok($fs_object, 'fs:object');
isa_ok($fs_object, 'Repository::Simple::Type::Node', 
    'fs:object is a node type');
is($fs_object->name, 'fs:object', 'fs:object name');
is_deeply([ $fs_object->super_types ], [ ], 'fs:object isa [ ]');
is_deeply({ $fs_object->node_types }, { }, 'fs:object no node types');
is_deeply({ $fs_object->property_types },
    {
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
    }, 'fs:object property types'
);
ok(!$fs_object->auto_created, 'fs:object auto_created');
ok($fs_object->updatable, 'fs:object updatable');
ok($fs_object->removable, 'fs:object removable');
undef $fs_object;

# Test fs:file node type
my $fs_file = $engine->node_type_named('fs:file');
ok($fs_file, 'fs:file');
isa_ok($fs_file, 'Repository::Simple::Type::Node', 'fs:file isa node type');
is($fs_file->name, 'fs:file', 'fs:file name');
is_deeply([ $fs_file->super_types ], [ 'fs:object' ], 'fs:file super_types');
is_deeply({ $fs_file->node_types }, { }, 'fs:file node_types');
is_deeply({ $fs_file->property_types },
    {
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
        'fs:content' => 'fs:handle',
    }, 'fs:file property types'
);
ok(!$fs_file->auto_created, 'fs:file auto_created');
ok($fs_file->updatable, 'fs:file updatable');
ok($fs_file->removable, 'fs:file removable');
undef $fs_file;

# Test fs:directory node type
my $fs_directory = $engine->node_type_named('fs:directory');
ok($fs_directory, 'fs:directory');
isa_ok($fs_directory, 'Repository::Simple::Type::Node', 'fs:directory isa');
is($fs_directory->name, 'fs:directory', 'fs:directory name');
is_deeply([ $fs_directory->super_types ], [ 'fs:object' ], 
    'fs:directory super_types');
is_deeply({ $fs_directory->node_types }, 
    { 
        '*' => [ 'fs:object' ],
    }, 'fs:object node_types'
);
is_deeply({ $fs_directory->property_types },
    {
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
    }, 'fs:object property_types'
);
ok(!$fs_directory->auto_created, 'fs:directory auto_created');
ok($fs_directory->updatable, 'fs:directory updatable');
ok($fs_directory->removable, 'fs:directory removable');
undef $fs_directory;

# Test fs:scalar property type
my $fs_scalar = $engine->property_type_named('fs:scalar');
ok($fs_scalar, 'fs:scalar');
isa_ok($fs_scalar, 'Repository::Simple::Type::Property', 'fs:scalar isa');
is($fs_scalar->name, 'fs:scalar', 'fs:scalar name');
is($fs_scalar->value_type->name, 'rs:scalar', 'fs:scalar value_type');
ok($fs_scalar->auto_created, 'fs:scalar auto_created');
ok($fs_scalar->updatable, 'fs:scalar updatable');
ok(!$fs_scalar->removable, 'fs:scalar removable');
undef $fs_scalar;

# Test fs:scalar-static property type
my $fs_static_scalar = $engine->property_type_named('fs:scalar-static');
ok($fs_static_scalar, 'fs:scalar-static');
isa_ok($fs_static_scalar, 'Repository::Simple::Type::Property', 
    'fs:scalar-static isa');
is($fs_static_scalar->name, 'fs:scalar-static', 'fs:scalar-static name');
is($fs_static_scalar->value_type->name, 'rs:scalar', 
    'fs:scalar-static value_type');
ok($fs_static_scalar->auto_created, 'fs:scalar-static auto_created');
ok(!$fs_static_scalar->updatable, 'fs:scalar-static updatable');
ok(!$fs_static_scalar->removable, 'fs:scalar-static removable');
undef $fs_static_scalar;

# Test fs:handle property type
my $fs_handle = $engine->property_type_named('fs:handle');
ok($fs_handle, 'fs:handle');
isa_ok($fs_handle, 'Repository::Simple::Type::Property', 'fs:handle isa');
is($fs_handle->name, 'fs:handle', 'fs:handle name');
is($fs_handle->value_type->name, 'rs:scalar', 'fs:handle value_type');
ok($fs_handle->auto_created, 'fs:handle auto_created');
ok(!$fs_handle->updatable, 'fs:handle updatable');
ok(!$fs_handle->removable, 'fs:handle removable');
undef $fs_handle;

my %paths = (
    '/'        => 'fs:directory',
    '/foo'     => 'fs:file',
    '/bar'     => 'fs:file',
    '/baz'     => 'fs:directory',
    '/baz/qux' => 'fs:file',
);

for my $path (keys %paths) {
    # Test path_exists() on node
    is($engine->path_exists($path), $NODE_EXISTS, "path_exists($path)");

    # Test node_type_of()
    my $node_type = $engine->node_type_of($path);
    is_deeply($node_type, $engine->node_type_named($paths{$path}), 
        'node_type_of');

    # Get a node path with an appropriate trailing slash
    my $path_slash = $path eq '/' ? $path : "$path/";

    my %property_types = $node_type->property_types;

    # Test properties_in()
    is_deeply(
        [ sort $engine->properties_in($path) ],
        [ sort keys %property_types ], 
        'properties_in'
    );

    # Loop through all properties that are to be defined
    for my $property (keys %property_types) {

        # Test path_exists() on property
        my $property_path = $path_slash.$property;
        is($engine->path_exists($property_path), $PROPERTY_EXISTS,
            'path_exists');

        # Test property_type_of()
        my $property_type = $engine->property_type_of($property_path);
        is_deeply(
            $property_type, 
            $engine->property_type_named($property_types{$property}),
            'property_type_of'
        );

        # Test get_scalar() and get_handle()
        my $scalar = $engine->get_scalar($property_path);
        my $handle = $engine->get_handle($property_path);
        is($scalar, join '', <$handle>);
    }

    # Test path_exists() on a non-existent property
    ok(!$engine->path_exists($path_slash.'fs:notta'), '!path_exists property');
}

# Test path_exists() on a non-existent node
ok(!$engine->path_exists('/notta'), '!path_exists node');

# Test nodes_in()
is_deeply(
    [ sort grep !/^\.svn$/, $engine->nodes_in('/') ], 
    [ 'bar', 'baz', 'foo' ],
    'nodes_in');

# Test namespaces()
is_deeply($engine->namespaces, { 
    fs => 'http://contentment.org/Repository/Simple/Engine/FileSystem',
});
