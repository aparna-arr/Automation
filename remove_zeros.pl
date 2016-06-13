#!/usr/bin/env perl
use warnings;
use strict;

my (@input) = @ARGV;
die "usage: $0 <list of .mapwig files> <value to remove>\n" unless @ARGV;

my @matrix;
for (my $i = 0; $i < @input - 1; $i++)
{
	open (IN, "<", $input[$i]) or die "Could not open $input[$i]\n";
	
	while(<IN>)
	{
		my $line = $_;
		chomp $line;
		my ($chr, $start, $end, $val) = split(/\t/, $line);

		push(@{$matrix[$i]}, {
			chr => $chr,
			start => $start,
			end => $end,
			val => $val
		});
	}

	close IN;
}

open (OUT, ">", "combined_map.bed") or die "Could not open outfile!";

for (my $i = 0; $i < @{$matrix[0]}; $i++)
{
	my $is_zero = 1;

	for (my $j = 1; $j < @matrix; $j++)
	{
		if ($matrix[$j][$i]{val} > $input[@input - 1])
		{
			$is_zero = 0;
			last;
		}
	}

	if ($is_zero == 0)
	{
		print OUT "$matrix[0][$i]{chr}\t$matrix[0][$i]{start}\t$matrix[0][$i]{end}\t$matrix[0][$i]{val}";

		for (my $k = 1; $k < @matrix; $k++)
		{
			print OUT "\t$matrix[$k][$i]{val}";
		}

		print OUT "\n";
	}
}

close OUT;
