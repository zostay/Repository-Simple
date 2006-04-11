# vim: set ft=perl :

use strict;
use warnings;

use Test::More tests => 15;

use_ok('Repository::Simple');

my $repository = Repository::Simple->attach(
    FileSystem => root => 't/root',
);
ok($repository);

my $engine = $repository->engine;
ok($engine);
isa_ok($engine, 'Repository::Simple::Engine::FileSystem');

my $fs_object = $repository->node_type('fs:object');
ok($fs_object);
isa_ok($fs_object, 'Repository::Simple::Type::Node');

my $fs_scalar = $repository->property_type('fs:scalar');
ok($fs_scalar);
isa_ok($fs_scalar, 'Repository::Simple::Type::Property');

my $root_node = $repository->root_node;
ok($root_node);
isa_ok($root_node, 'Repository::Simple::Node');

my $node = $repository->get_item('/baz/qux');
ok($node);
isa_ok($node, 'Repository::Simple::Node');

my $property = $repository->get_item('/baz/qux/fs:content');
ok($property);
isa_ok($property, 'Repository::Simple::Property');
is($property->value->get_scalar, "Your mom goes to college!\n");
