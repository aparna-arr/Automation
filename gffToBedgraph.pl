#!/usr/bin/env perl
use warnings;
use strict;

my ($gff) = @ARGV;
die "usage: <StochHMM gff output file>\n" unless @ARGV;

open (IN, "<", $gff) or die "Could not open $gff\n";
open(OUT, ">", $gff . ".bedgraph") or die "Could not open outfilr\n";

while (<IN>) 
{
	my $line = $_;
	chomp $line;
	
	if ($line =~ /^chr/) 
	{
		my ($chr, $start, $end) = $line =~ /^(.+)\t.+\t.+\t(\d+)\t(\d+)\t.+/;
		print OUT "$chr\t$start\t$end\n";
	}
}	

close IN;
close OUT;
