#!perl -T

use Test::More tests => 14;

use PerlIO::Layers qw/query_handle/;

is(query_handle(\*STDIN, 'open'),       1, 'stdin is open');
is(query_handle(\*STDIN, 'readable'),   1, 'stdin is readable');
is(query_handle(\*STDIN, 'writeable'),  0, 'stdin is not writable');

is(query_handle(\*STDOUT, 'open'),      1, 'stdout is open');
is(query_handle(\*STDOUT, 'readable'),  0, 'stdout is readable');
is(query_handle(\*STDOUT, 'writeable'), 1, 'stdout is not writable');
is(query_handle(\*STDOUT, 'buffered'),  1, 'stdout is buffered');

is(query_handle(\*STDERR, 'open'),      1, 'stderr is open');
is(query_handle(\*STDERR, 'readable'),  0, 'stderr is readable');
is(query_handle(\*STDERR, 'writeable'), 1, 'stderr is not writable');

is(query_handle(\*STDIN, 'crlf'),       int($^O eq 'MSWin32'), 'crlf is only true on Windows');

is(query_handle(\*STDIN, 'utf8'),       0, 'stdin isn\'t unicode');
binmode STDIN, ':utf8';
is(query_handle(\*STDIN, 'utf8'),       1, 'stdin is unicode after binmode \':utf8\'');

binmode STDIN, ':raw';

is(query_handle(\*STDIN, 'binary'),     1, 'stdin is binary');
