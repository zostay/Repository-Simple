# vim: set ft=perl :

use strict;
use warnings;

use Test::More skip_all => 'Layered storage engine is not implemented yet.';

use_ok('Content::Repository::Engine::Layered');
