# vim: set ft=perl :

use strict;
use warnings;

use Test::More tests => 2;

use_ok('Content::Repository');

my $fs_repo = Content::Repository::Factory->attach(
    FileSystem => root => 't/root',
);
ok($fs_repo);

my $layer_repo = Content::Repository::Factory->attach(
    Layered =>
        [ FileSystem => root => 't/root' ],
        [ FileSystem => root => 't/root2' ],
);
ok($layer_repo);

my $pt_repo = Content::Repository::Factory->attach(
    Passthrough => [ FileSystem => root => 't/root' ],
);
ok($pt_repo);

my $table_repo = Content::Repository::Factory->attach(
    Table =>
        '/'    => [ FileSystem => root => 't/root' ],
        '/bar' => [ FileSystem => root => 't/root2' ],
);
ok($table_repo);
