use strict;

use Module::Build;

my $build = Module::Build->new(
	module_name        => 'Content::Repository',
	create_makefile_pl => 'passthrough',
	license            => 'perl',
	requires           => {
		'File::Copy::Recursive' => '0.05',
		'Parse::RecDescent'     => 1.94,
	},
	PL_files			=> {
		'lib/Content/Repository/Util/Globber.PL' => 'lib/Content/Repository/Util/Globber.pm',
	},
);

$build->create_build_script;
