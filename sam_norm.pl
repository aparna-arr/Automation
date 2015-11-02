#!/usr/bin/env perl
use warnings;
use strict;

my ($sam, $tot_reads, $seed) = @ARGV;
die "usage: $0 <sorted sam file to normalize> <# reads to normalize to> <seed--set to -1 for no seed>\nif input is sorted, output is sorted\n" unless @ARGV;

open (IN, "<", $sam) or die "could not open $sam\n";
open (OUT, ">", $sam . ".norm") or die "could not open outfile\n";

if ($seed != -1)
{
	srand($seed);
}

### METHOD ###
# Read in file
# Set each sam line to index in array1
# find length of array1
# generate array2 of indicies where array[i] = i as long as length of array1
# Fisher-Yates shuffle array2
# take first N indicies of array2, where N is #reads to normalize to
# sort smallArray2
# for @smallArray2
# 	print OUT array1[smallArray2[$_]

my @samreads; # aka array1

warn "reading in samfile\n";
while (<IN>)
{
	my $line = $_;
	chomp $line;

	if ($line =~ /^@/)
	{
		print OUT "$line\n";
	}
	else 
	{
		$samreads[@samreads] = $line;		
	}
}

close IN;

#get length
my $count = @samreads;

warn "total count is $count\n";

#generate array2
my @indexes;
for (my $i = 0; $i < $count; $i++)
{
	$indexes[$i] = $i;
}

warn "starting Fisher-Yates shuffle\n";
# Fisher-Yates shuffle @indexes
for (my $i = $count-1; $i > 0; $i--)
{
	my $j = int( rand($i+1) );

	my $tmp = $indexes[$j];
	$indexes[$j] = $indexes[$i];
	$indexes[$i] = $tmp;
}
warn "done with shuffle\n";

# get correct number of randomly shuffled indexes
my @rands = @indexes[0..$tot_reads-1];

#delete @indexes
@indexes = ();

# sort 
my @sorts = sort{$a <=> $b} @rands;

# delete @rands
@rands = ();

warn "printing reads\n";
for (my $i = 0; $i < @sorts; $i++)
{
	print OUT "$samreads[$sorts[$i]]\n";
}

close OUT;
