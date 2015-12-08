#!/usr/bin/env perl
use warnings;
use strict;

my ($file) = @ARGV;
die "usage: <sorted bed file>\n" unless @ARGV == 1;

open (IN, "<", $file) or die "could not open $file:$!\n";

while (<IN>)
{
	my $line = $_;

	my ($chr) = $line =~ /^(chr\S+)\t/;

	open (TMP, ">>", "$chr.bed") or die "cannot open chromosome $chr file\n";

	print TMP $line;

	close TMP;
}

close IN;
