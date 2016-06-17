#!/usr/bin/env perl
use warnings;
use strict;

my ($genelist, $allgenes) = @ARGV;
die "usage: $0 <gene id list> <UCSC name chrom strand txStart txEnd name2 table>\n" unless @ARGV == 2;

open(IN, "<", $genelist) or die "could not open $genelist:$!\n";

my %genes;
while(<IN>)
{
	my $line = $_;
	chomp $line;

	$genes{$line} = {
		chrom => "INIT", 
		start => -1,
		end => -1,
		strand => "0"
	};
}

close IN;

open(IN, "<", $allgenes) or die "could not open $allgenes:$!\n";

while(<IN>)
{
	my $line = $_;
	chomp $line;

	my ($refname, $chrom, $strand, $start, $end, $name) = split(/\t/, $line);
		
	if (!exists($genes{$name}))
	{
		next;
	}

	if ($genes{$name}{chrom} eq "INIT")
	{
		$genes{$name}{chrom} = $chrom;
		$genes{$name}{start} = $start;
		$genes{$name}{end} = $end;
		$genes{$name}{strand} = $strand;	
	}
	elsif($genes{$name}{end} - $genes{$name}{start} < $end - $start)
	{
		$genes{$name}{start} = $start;
		$genes{$name}{end} = $end;
	}
	
}

close IN;

open(OUT, ">", "$genelist.out") or die "could not open outfile:$!\n";

foreach my $gene (keys %genes)
{
	print OUT "$genes{$gene}{chrom}\t$genes{$gene}{start}\t$genes{$gene}{end}\t$gene\t0\t$genes{$gene}{strand}\n";
}

close OUT;

`sort -k 1,1 -k 2,2n $genelist.out > tmp ; mv tmp $genelist.out`;
