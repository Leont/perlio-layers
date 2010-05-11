use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'PerlIO::Layers',
    license             => 'perl',
    dist_author         => q{Leon Timmermans <leont@cpan.org>},
    dist_version_from   => 'lib/PerlIO/Layers.pm',
	configure_requires => {
		'Module::Build' => 0,
	},
    build_requires => {
		'ExtUtils::CBuilder' => 0,
		'Module::Build'      => 0,
        'Test::More'         => 0,
    },
	requires => {
		perl               => 5.008,
		Exporter           => 5.57,
		'List::MoreUtils'  => 0,
		'namespace::clean' => 0,
	},
    add_to_cleanup      => [ 'PerlIO-Layers-*' ],
    create_makefile_pl  => 'small',
);

$builder->create_build_script();
