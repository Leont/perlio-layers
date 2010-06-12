package PerlIO::Layers;

use 5.008;
use strict;
use warnings FATAL => 'all';
use XSLoader;
use PerlIO ();
use Carp qw/croak/;
use List::Util qw/reduce/;
use List::MoreUtils qw/natatime/;
use Exporter 5.57 qw/import/;

our @EXPORT_OK = qw/query_handle/;

our $VERSION = '0.003';

XSLoader::load(__PACKAGE__, $VERSION);

sub _names_to_flags {
	our %FLAG_FOR;
	return reduce { $a | $b } map { $FLAG_FOR{$_} } @_;
}

sub _has_flags {
	my $check_flag = _names_to_flags(@_);
	return sub {
		my $iterator = shift;
		while (my ($name, $arguments, $flags) = $iterator->()) {
			my $entry = $flags & $check_flag;
			return 1 if $entry;
		}
		return 0;
	}
}

sub _lack_flags {
	my @args = @_;
	my $func = _has_flags(@args);
	return sub {
		return not $func->(@_);
	}
}

my %is_binary = map { ( $_ => 1) } qw/unix stdio perlio crlf flock creat excl/;

my $nonbinary_flags = _names_to_flags('UTF8', 'CRLF');

my %query_for = (
	writeable => _has_flags('CANWRITE'),
	readable  => _has_flags('CANREAD'),
	buffered  => _lack_flags('UNBUF'),
	open      => _has_flags('OPEN'),
	temp      => _has_flags('TEMP'),
	crlf      => _has_flags('CRLF'),
	utf8      => _has_flags('UTF8'),
	binary    => sub {
		my $iterator = shift;
		while (my ($name, $arguments, $flags) = $iterator->()) {
			return 0 if not $is_binary{$name} or $flags & $nonbinary_flags;
		}
		return 1;
	},
);

sub query_handle {
	my ($fh, $query_name, @args) = @_;
	my @results;
	my $query = $query_for{$query_name} or croak "Query $query_name isn't defined";
	my $iterator = natatime(3, PerlIO::get_layers($fh, details => 1));
	return $query->($iterator, @args);
}

1;    # End of PerlIO::Layers

__END__

=head1 NAME

PerlIO::Layers - Querying your filehandle's capabilities

=head1 VERSION

Version 0.003

=head1 SYNOPSIS

 use PerlIO::Layers qw/query_handle/;

 if (!query_handle(\*STDOUT, binary)) {
     ...
 }

=head1 DESCRIPTION

Perl's filehandles are implemented as a stack of layers, with the bottom-most usually doing the actual IO and the higher ones doing buffering, encoding/decoding or transformations. PerlIO::Layers allows you to query the filehandle's properties concerning there layers.

=head1 SUBROUTINES

=head2 query_handle($fh, $query_name)

This query a filehandle for some information. Currently supported queries include:

=over 4

=item * utf8

Check whether the filehandle handles unicode

=item * crlf

Check whether the filehandle does crlf translation

=item * binary

Check whether the filehandle is binery. This test is pessimistic (for unknown layers it will assume it's not binary).

=item * buffered

Check whether the filehandle is buffered.

=item * readable

Check whether the filehandle is readable.

=item * writeable

Check whether the filehandle is writeable.

=item * open

Check whether the filehandle is open.

=item * temp

Check whether the filehandle refers to a temporary file.

=back

=head1 AUTHOR

Leon Timmermans, C<< <leont at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-perlio-layers at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PerlIO-Layers>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PerlIO::Layers

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=PerlIO-Layers>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/PerlIO-Layers>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/PerlIO-Layers>

=item * Search CPAN

L<http://search.cpan.org/dist/PerlIO-Layers/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Leon Timmermans.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

