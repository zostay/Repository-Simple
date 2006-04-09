# vim: set ft=perl :

use strict;
use warnings;

use Test::More tests => 10;

use_ok('Content::Repository');

my $repository = Content::Repository->attach(
    FileSystem => root => 't/root',
);
ok($repository);

my $engine = $repository->engine;
ok($engine);
isa_ok($engine, 'Content::Repository::Engine::FileSystem');

my $fs_object = $repository->node_type('fs:object');
ok($fs_object);
isa_ok($fs_object, 'Content::Repository::Type::Node');

my $fs_scalar = $repository->property_type('fs:scalar');
ok($fs_scalar);
isa_ok($fs_scalar, 'Content::Repository::Type::Property');

my $root_node = $repository->root_node;
ok($root_node);
isa_ok($root_node, 'Content::Repository::Node');
