#!/usr/bin/env perl
use warnings;
use strict;

my ($poised_genes, $erfs_genes_wo, $outfile) = @ARGV;
die "usage: <output of pol2_poised_index.pl for genes (6 col)> <output of bedtools intersect -wo -a erfs (3 col) -b genes (4 col)> <outfile>\n" unless @ARGV == 3;

open (POL2, "<", $poised_genes) or die "could not open $poised_genes:$!\n";

my %genes;
while(<POL2>)
{
	my $line = $_;
	chomp $line;

	warn "line is $line\n";
	
	my ($chr, $start, $end, $strand, $index, $percent) = split(/\t/, $line);
	warn "chr [$chr] start [$start] end [$end] strand [$strand] index [$index] perc [$percent]\n";

	$genes{$chr}{"$start-$end-$strand"} = {
		index => $index,
		percent => $percent
	};
}

close POL2;

open (ERFS, "<", $erfs_genes_wo) or die "could not open $erfs_genes_wo:$!\n";

my %intersect;
while (<ERFS>)
{
	my $line = $_;
	chomp $line;

	my ($erfs_chr, $erfs_start, $erfs_end, $genes_chr, $genes_start, $genes_end, $genes_strand, $trash) = split(/\s+/, $line);

	push(@{$intersect{$erfs_chr}{"$erfs_start-$erfs_end"}}, {chr => $genes_chr, string => "$genes_start-$genes_end-$genes_strand"}); 
}	

close ERFS;

open (OUT, ">", $outfile) or die "could not open $outfile:$!\n";
foreach my $chr (sort keys %intersect)
{
	foreach my $erf (keys %{$intersect{$chr}})
	{
		my @bins = (0, 0, 0, 0);
		my $total_genes = 0;

		for (my $i = 0; $i < @{$intersect{$chr}{$erf}}; $i++)
		{
			warn "chr is $chr string is [$intersect{$chr}{$erf}[$i]{string}]\n";
			if (!exists($genes{$chr}{$intersect{$chr}{$erf}[$i]{string}}))
			{

			#	warn "string does not exist in genes!";
				next;
			}
			my ($percent) = $genes{$chr}{$intersect{$chr}{$erf}[$i]{string}}{percent};
		warn "percent is [$percent]\n";

			# stupid way of fixing the percent == 100 therefore index == 4 therefore @bins == 5 issue
			$percent-- if ($percent == 100);

			$total_genes++;
			$bins[int($percent/25)]++; 
			
			if (int($percent/25) > 3)
			{
				warn "bins>4!\n";
			}
		}
		warn "bins is " . @bins . "\n";
	
		my ($start, $end) = split (/-/, $erf);

		my $string = "";
		for (my $j = 0; $j < @bins; $j++)
		{
			if ($total_genes == 0)
			{
				$string .= "\t0";
			}
			else
			{
				$string .= "\t" . (int ($bins[$j] / $total_genes * 100 * 100 ) / 100);
			}
		}

		print OUT "$chr\t$start\t$end" . $string . "\t$total_genes\n";
		
	}
}

close OUT;

`sort -k 1,1 -k 2,2n $outfile > tmp ; mv tmp $outfile`;
