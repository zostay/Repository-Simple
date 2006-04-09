# vim: set ft=perl :

use strict;
use warnings;

use Test::More tests => 19;

use_ok('Content::Repository::Engine',
    qw( $NODE_EXISTS $PROPERTY_EXISTS $NOT_EXISTS )
);

use vars qw( $NODE_EXISTS $PROPERTY_EXISTS $NOT_EXISTS );

ok(!$NOT_EXISTS);
ok($NODE_EXISTS);
ok($PROPERTY_EXISTS);
isnt($NODE_EXISTS, $PROPERTY_EXISTS);

package Content::Repository::Engine::Test;

use base 'Content::Repository::Engine';

package main;

# Test generic constructor
my $engine = Content::Repository::Engine::Test->new(foo => 1, bar => 2);
ok($engine);
isa_ok($engine, 'Content::Repository::Engine::Test');
is($engine->{foo}, 1);
is($engine->{bar}, 2);

my @methods = qw(
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
);

# Test the presence of all required methods
can_ok($engine, @methods);

for my $method (@methods) {
    next if $method eq 'new';
    eval { $engine->$method };
    ok($@, $method);
}
