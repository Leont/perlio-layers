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

our $VERSION = '0.001';

XSLoader::load(__PACKAGE__, $VERSION);

sub names_to_flags {
	our %FLAG_FOR;
	return reduce { $a | $b } map { $FLAG_FOR{$_} } @_;
}

sub has_flags {
	my $check_flag = names_to_flags(@_);
	return sub {
		my $iterator = shift;
		my @results;
		while (my ($name, $arguments, $flags) = $iterator->()) {
			my $entry = $flags & $check_flag;
			push @results, $entry if $entry;
		}
		return @results;
	}
}

sub lacks_flags {
	my $check_flag = names_to_flags(@_);
	return sub {
		my $iterator = shift;
		while (my ($name, $arguments, $flags) = $iterator->()) {
			my $entry = $flags & $check_flag;
			return if $entry;
		}
		return 1;
	}
}

my %is_binary = map { ( $_ => 1) } qw/unix stdio perlio crlf flock creat excl/;

my %query_for = (
	binary    => sub {
		my $iterator = shift;
		while (my ($name, $arguments, $flags) = $iterator->()) {
			return if not $is_binary{$name};
			return if $flags & names_to_flags('UTF8', 'CRLF');
		}
		return 1;
	},
	writeable => has_flags('CANWRITE'),
	readable  => has_flags('CANREAD'),
	buffered  => lacks_flags('UNBUF'),
	open      => has_flags('OPEN'),
	temp      => has_flags('TEMP'),
	crlf      => has_flags('CRLF'),
	utf8      => has_flags('UTF8'),
);

use namespace::clean;

sub query_handle {
	my ($fh, $query_name) = @_;
	my @results;
	my $query = $query_for{$query_name} or croak "Query $query_name isn't defined";
	my $iterator = natatatime(3, PerlIO::get_layers($fh, details => 1));
	return $query->($iterator);
}

1;    # End of PerlIO::Layers

=head1 NAME

PerlIO::Layers - Querying your filehandle's capabilities

=head1 VERSION

Version 0.001

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use PerlIO::Layers;

    my $foo = PerlIO::Layers->new();
    ...

=head1 SUBROUTINES

=head2 query_handle($fh, $query_name)

This query a filehandle for some information. Currently supported queries include:

=over 4

=item * utf8

=item * crlf

=item * binary

=item * buffered

=item * readable

=item * open

=item * temp

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

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Leon Timmermans.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

