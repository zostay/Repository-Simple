# vim: set ft=perl :

use strict;
use warnings;

use Test::More tests => 1;

use_ok('Content::Repository');

my $repository = Content::Repository::Factory->attach(
    FileSystem => root => 't/root',
);
ok($repository);

my $node_type = $repository->node_type('fs:object');

is($node_type->name, 'fs:object');
ok($node_type->abstract);
ok(!$node_type->supertypes);
ok(!$node_type->child_nodes);

my %properties = $node_type->child_properties;
ok($properties{'fs:dev'});
ok($properties{'fs:ino'});
ok($properties{'fs:mode'});
ok($properties{'fs:nlinke'});
ok($properties{'fs:uid'});
ok($properties{'fs:gid'});
ok($properties{'fs:rdev'});
ok($properties{'fs:size'});
ok($properties{'fs:atime'});
ok($properties{'fs:mtime'});
ok($properties{'fs:ctime'});
ok($properties{'fs:blksize'});
ok($properties{'fs:blocks'});

ok(!$node_type->auto_created);
ok($node_type->mutable);
ok(!$node_type->required);
ok(!$node_type->ordered);
