#!/usr/bin/env perl

while(<>) {
	if (/qrcodejs/) {
		print "<script type=\"text/javascript\">\n";
		open(my $fh, "<", "qrcodejs/qrcode.min.js");
		while(<$fh>) {
			print "$_\n";
		}
		print "</script>\n";
	} else {
		print;
	}
}
