#!perl

use strict;
use warnings FATAL => 'all';
use Test::More tests => 29;
use Data::Dumper;

use PerlIO::Layers qw/query_handle get_layers/;

my %flags = map { map { ($_ => 1) } @{$_} } map {  $_->[2] } get_layers(\*STDOUT);

ok $flags{CANWRITE}, 'STDOUT has CANWRITE flag';

is(query_handle(\*STDIN, 'readable'),   1, 'stdin is readable');
is(query_handle(\*STDIN, 'writeable'),  0, 'stdin is not writable');

is(query_handle(\*STDOUT, 'readable'),  0, 'stdout is readable');
is(query_handle(\*STDOUT, 'writeable'), 1, 'stdout is not writable');
is(query_handle(\*STDOUT, 'buffered'),  1, 'stdout is buffered');

is(query_handle(\*STDERR, 'readable'),  0, 'stderr is readable');
is(query_handle(\*STDERR, 'writeable'), 1, 'stderr is not writable');

SKIP: {
	skip('filehandles may not be open when automated testing', 3) if $ENV{AUTOMATED_TESTING};

	is(query_handle(\*STDIN, 'open'),       1, 'stdin is open');
	is(query_handle(\*STDOUT, 'open'),      1, 'stdout is open');
	is(query_handle(\*STDERR, 'open'),      1, 'stderr is open');
}

my $is_win32 = int($^O eq 'MSWin32');

is(query_handle(\*STDIN, 'crlf'), $is_win32, 'crlf is only true on Windows');

my @types = (
	['<', utf8 => 0, binary => !$is_win32, mappable => !$is_win32, crlf => $is_win32],
	['<:utf8', utf8 => 1, binary => 0, mappable => 1, crlf => $is_win32],
	['<:encoding(utf-8)', utf8 => 1, binary => 0, mappable => 0, crlf => $is_win32],
	['<:crlf', utf8 => 0, binary => 0, mappable => 0, crlf => 1],
	['<:mmap', 'mapped' => 1],
);

for my $type (@types) {
	my ($mode, %result_for) = @{$type};
	for my $test_type (keys %result_for) {
		open my $fh, $mode, $0 or BAIL_OUT('Open failed');
		is query_handle($fh, $test_type), $result_for{$test_type}, "File opened with $mode should return $result_for{$test_type} on test $test_type";
	}
}
