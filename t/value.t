# vim: set ft=perl :

use strict;
use warnings;

use Test::More tests => 10;

use_ok('Content::Repository');

my $repository = Content::Repository->attach(
    FileSystem => root => 't/root',
);
ok($repository);

my $root_node = $repository->root_node;
ok($root_node);

my %properties = map { ($_->name => $_) } $root_node->properties;
my $fs_uid = $properties{'fs:uid'};
ok($properties{'fs:uid'});

my $value = $fs_uid->value;
ok($value);

can_ok($value, qw(
    get_scalar
    get_handle
));

my $scalar_value = $value->get_scalar;
ok(defined $scalar_value);

my $handle_value = $value->get_handle;
ok(defined $handle_value);
my $scalar_handle_value = join '', <$handle_value>;
ok(defined $scalar_handle_value);

is($scalar_value, $scalar_handle_value);
