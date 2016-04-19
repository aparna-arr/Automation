#!/usr/bin/env perl
use warnings;
use strict;

my ($input) = @ARGV;
die "usage: <output of \"bedtools -wao -a peakfile -b blacklistfile\">\n" unless @ARGV == 1;

open(IN, "<", $input) or die "could not open $input\n";

my %final;

my %splitme;

while (<IN>) {
	my $line = $_;
	chomp $line;

	my ($chr, $start, $end, $bchr, $bstart, $bend, $int) = split(/\s+/, $line);

	if ($int == 0) {
		push(@{$final{$chr}}, {start => $start, end => $end});
	}
	else {
		push(@{$splitme{$chr}{"$start-$end"}}, {bstart => $bstart, bend => $bend});
	}
}

close IN;
foreach my $chr (keys %splitme) {
	foreach my $peak (keys %{$splitme{$chr}}) {
		my ($start, $end) = split(/-/, $peak);

		my @sortb = sort {$a->{bstart} <=> $b->{bstart}} @{$splitme{$chr}{$peak}};

		for (my $i = 0; $i < @sortb; $i++) {
			my $split_start = -1;
			my $split_end = -1;
			if ($sortb[$i]{bstart} <= $start && $sortb[$i]{bend} >= $start)
			{
			#	=====
			#     ---	
				$start = $sortb[$i]{bend} + 1;	
			}			
			elsif ($sortb[$i]{bstart} > $start)
			{
			# 	=====
			# 	  --...
				$split_start = $start;
				$split_end = $sortb[$i]{bstart} - 1;
		
				$start = $sortb[$i]{bend} + 1;
			}
	
			if ($split_start != -1) {
				push(@{$final{$chr}}, {start => $split_start, end => $split_end});
			}
		}
	}
}

foreach my $chrom (keys %final)
{
	for(my $i = 0; $i < @{$final{$chrom}}; $i++)
	{
		print "$chrom\t$final{$chrom}[$i]{start}\t$final{$chrom}[$i]{end}\n";
	}
}
