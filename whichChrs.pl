#!/usr/bin/env perl
use warnings;
use strict;

my ($file) = @ARGV;
die "usage: <gff or bed>\n" unless @ARGV;

open (IN, "<", $file) or die "Could not open $file\n";

my %chroms;

while(<IN>)
{
	my $line = $_;
	chomp $line;
	my $chr;
	if ($line =~ /^chr/)
	{
		($chr) = $line =~ /^(\S+)\s+/;
		$chroms{$chr}++;
	}
	
}

close IN;

foreach my $chr (sort keys %chroms)
{
	print "[$chr] : $chroms{$chr}\n";
}
