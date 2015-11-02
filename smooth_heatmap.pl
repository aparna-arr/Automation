#!/usr/bin/env perl
use warnings;
use strict;

my ($file, $window, $shift) = @ARGV;
die "usage: $0 <heatmap_outfile.txt> <window> <shift>\n" unless @ARGV;

my @array;
my $outfile = $file . ".smooth";

open(IN, "<", $file) or die "Could not open $file: $!\n";
open(OUT, ">", $outfile) or die "Could not open $outfile: $!\n";

while(<IN>)
{
	my $line = $_;
	chomp $line;

	if ($line =~ /^peaks/)
	{
		print OUT "$line\n";
		next;
	}

	my @split = split(/\s+/, $line);

#	print "split size is " . @split . " window is $window split - window is " . (@split - $window) . "\n";
	my @dummyAr;
	
	for (my $i = 1; $i < @split; $i++)
	{
		$dummyAr[$i] = 0;
	}

	my $i;	
	for ($i = 1; $i <= @split - $window; $i+=$shift)
	{
		my $avg = 0;

		for (my $j = $i; $j < $i + $window; $j++)
		{
			$avg += $split[$j];
		}
		$avg /= $window;
		$dummyAr[int(($i + $i + $window) / 2)] = $avg;
#		print "\tprinted " . int(($i + $window) / 2) . "\n";
	}
#	print "stopped at " . int(($i + $window) / 2) . "\n";

	print OUT "$split[0]";
	for (my $i = 1; $i < @dummyAr; $i++)
	{
		print OUT "\t$dummyAr[$i]";
	}	
	print OUT "\n";
}
close OUT;
close IN;
