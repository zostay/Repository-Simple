# vim: set ft=perl :

use strict;
use warnings;

use Test::More tests => 11;

use_ok('Repository::Simple');

my $repository = Repository::Simple->attach(
    FileSystem => root => 't/root',
);
ok($repository);

my $root_node = $repository->root_node;
ok($root_node);

my %properties = map { ($_->name => $_) } $root_node->properties;
my $fs_uid = $properties{'fs:uid'};
ok($fs_uid);

my $parent = $fs_uid->parent;
is($parent->path, $root_node->path);

is($fs_uid->name, 'fs:uid');

is($fs_uid->path, '/fs:uid');

my $value = $fs_uid->value;
ok($value);
isa_ok($value, 'Repository::Simple::Value');

my $property_type = $fs_uid->type;
ok($property_type);
isa_ok($property_type, 'Repository::Simple::Type::Property');

