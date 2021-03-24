#!/usr/bin/env perl

$/="\n\n";

my $last = undef;
my $found = 0;

while (<>) {
	my $err = $1 if /Error:\s+(\S+)/;
	my $text = $1 if /Text:\s+"([^"]*)"/;

	if ($err eq "NoError" && $text !~ /^ /) {
		next if $text eq $last;
		$last = $text;

		if ($text =~ s/(.*),//) {
			## New file, get MIME
			if ($found) {
				exit;
			}
			print STDERR "MIME type: $1\n";
			$found = 1;
		}

		print $text, "\n";
	}
}
