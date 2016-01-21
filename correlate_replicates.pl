#!/usr/bin/env perl
use strict;
use warnings;

my ($dir) = @ARGV;
die "usage: $0 <DIR>\n" unless @ARGV == 1;

opendir(DIR, $dir) or die "could not open directory $dir:$!\n";
my @files = readdir(DIR);
closedir(DIR);

my %replicates;
foreach my $file (@files)
{
	next if (-d $file || $file =~ /(\.sh)|(\.R)|(\.r)|(\.pl)|(\.cpp)|(\.h)$/);
	if ($file =~ /rep[1|2]/i)
	{
		my ($wig, $rep, $bed) = $file =~ /(.+)_(rep[1|2])_(.+)\.mapwig$/;
		print "file is [$file]\n";
		print "wig [$wig] rep [$rep] bed [$bed]\n";
		$replicates{$wig}{$bed}{$rep} = $file;
	}	
}

foreach my $wig (keys %replicates)
{
	foreach my $bed (keys %{$replicates{$wig}})
	{
		next if (scalar values %{$replicates{$wig}{$bed}} != 2);
		my %merge;
		foreach my $rep (keys %{$replicates{$wig}{$bed}})
		{
			open (IN, "<", $replicates{$wig}{$bed}{$rep}) or die "Could not open $replicates{$wig}{$bed}{$rep}:$!\n";
			while(<IN>)
			{
				my $line = $_;
				chomp $line;
				my ($chr, $start, $end, $val, $other) = split(/\s+/, $line);
				$merge{$chr}{"$start,$end"} += $val;
			}
			close IN;
		}
		open(OUT, ">", "$wig\_$bed\_combined_reps.mapwig") or die "Could not open outfile:$!\n"; 
		foreach my $chrom(keys %merge)
		{
			foreach my $startend (keys %{$merge{$chrom}})
			{
				my ($start, $end) = split(/,/, $startend);
				print OUT "$chrom\t$start\t$end\t$merge{$chrom}{$startend}\n";
			}
		}
		close OUT;
	}
}
