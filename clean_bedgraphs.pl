#!/usr/bin/env perl
use warnings;
use strict;

my ($file, $namestr, $chrinfo) = @ARGV;
die "usage: $0 <bedgraph file> <track name> <chromosome sizes file>\n" unless @ARGV;

open (CHR, "<", $chrinfo) or die "could not open $chrinfo\n";

my %chrs;
while (<CHR>)
{
	my $line = $_;
	chomp $line;
	## process line ##
	my ($chr, $size) = split(/\t/, $line);	
	## store in %chrs ##
	$chrs{$chr} = $size;
}
close CHR;

open (IN, "<", $file) or die "Could not open $file\n";
open (TMP, ">", "tmp") or die "could not open tmpfile\n";

my $loopfirst = 1;

while (<IN>)
{
	my $line = $_;
	chomp $line;

	if ($line !~ /^chr/)
	{
		next;
	}
	
	my ($chr, $start, $end, $val) = split(/\t/, $line);

	if ($loopfirst)
	{
		print TMP "track type=bedGraph name=\"$namestr\"\n";
		$loopfirst = 0;
	}
	
	if ($end <= $chrs{$chr})
	{
		print TMP "$line\n";
	}	
}

close IN;
close TMP;

`mv tmp $file`;
