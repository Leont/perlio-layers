#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'PerlIO::Layers' ) || print "Bail out!
";
}

diag( "Testing PerlIO::Layers $PerlIO::Layers::VERSION, Perl $], $^X" );
