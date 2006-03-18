# vim: set ft=perl :

use strict;
use warnings;

use Test::More tests => 29;

use_ok('Content::Repository');

my $repository = Content::Repository::Factory->attach(
    FileSystem => root => 't/root',
);
ok($repository);

my $root_node = $repository->root_node;
ok($root_node);
isa_ok($root_node, 'Content::Repository::Node');

my $node_repository = $root_node;
is("$repository", "$node_repository");

is($root_node->name, '/');
is($root_node->path, '/');

my %child_nodes = map { $_->path => $_ } $root_node->nodes;

ok($child_nodes{'/foo'});
ok($child_nodes{'/bar'});
ok($child_nodes('/baz'});

is($child_nodes{'/foo'}->name, 'foo');
is($child_nodes{'/bar'}->name, 'bar');
is($child_nodes{'/baz'}->name, 'baz');

my %properties = map { $_->name => $_ } $root_node->properties;

ok(defined $properties{'fs:dev'});
ok(defined $properties{'fs:ino'});
ok(defined $properties{'fs:mode'});
ok(defined $properties{'fs:nlinke'});
ok(defined $properties{'fs:uid'});
ok(defined $properties{'fs:gid'});
ok(defined $properties{'fs:rdev'});
ok(defined $properties{'fs:size'});
ok(defined $properties{'fs:atime'});
ok(defined $properties{'fs:mtime'});
ok(defined $properties{'fs:ctime'});
ok(defined $properties{'fs:blksize'});
ok(defined $properties{'fs:blocks'});

my $node_type = $root_node->type;
ok($node_type);
isa_ok($node_type, 'Content::Repository::NodeType');
is($node_type->name, 'fs:directory');
