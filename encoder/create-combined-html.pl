#!/usr/bin/env perl

while(<>) {
	next if /qrcodejs/;
	print;
	if (/<script/) {
		open(my $fh, "<", "qrcodejs/qrcode.min.js");
		while(<$fh>) {
			print "$_\n";
		}
	}
}
