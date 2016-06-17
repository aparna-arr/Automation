#!/usr/bin/env perl
use warnings;
use strict;

my ($bedfile, $namesandscores) = @ARGV;
die "usage: <bedfile> <genes_names \t scores file>\n" unless @ARGV == 2;

open(IN, "<", $bedfile) or die "could not open $bedfile";

my %hash;
while(<IN>)
{
	my $line = $_;
	chomp $line;
	
	my ($chr, $start, $end, $name, $score, $strand) = split(/\t/, $line);

	$hash{$name} = {chr => $chr, start => $start, first_str => "$chr\t$start\t$end\t$name", score => 0, strand => $strand};
}

close IN;

open(IN, "<", $namesandscores) or die "could not open $namesandscores\n";

while(<IN>)
{
	my $line = $_;
	chomp $line;

	my ($name, $change) = split(/\t/, $line);

	if (exists($hash{$name}))
	{
		$hash{$name}{score} = $change;
	}
}

close IN;

open (OUT, ">", "outfile.txt");

foreach my $gene (keys %hash)
{
	print OUT "$hash{$gene}{first_str}\t$hash{$gene}{score}\t$hash{$gene}{strand}\n";
}

close OUT;
