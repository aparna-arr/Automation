#!/usr/bin/env perl
use warnings;
use strict;

my ($dir) = @ARGV;
die "usage: $0 <dir>\n" unless @ARGV == 1;

opendir(DIR, $dir);
my @files = readdir(DIR);
closedir(DIR);

my %hash;

foreach my $file (sort @files)
{
	next if (-d $file || $file =~ /rep[12]/ || $file !~/\.mapwig$/);

        my ($wig, $bed) = $file =~ /(.+?(?:_GSE\d+|_merge)*)_(.+?)(?:_combined_reps|\.)/;

	my $erfs = "";

	if ($bed =~ /mm9/)
	{
		$erfs = "genes";
	}
	elsif ($bed =~ /Alt/)
	{
		$erfs = "AltERFs";
	}
	else
	{
		$erfs = "OrigERFs";
	}

        print "wig [$wig] bed [$bed] erfs [$erfs]\n";

	if ($bed =~ /top|middle|bottom/)
	{
		my ($rank, $split, $sample) = $bed =~ /(top|middle|bottom)_by_(.+?)_(.+)/;

		print "Ranked: my rank [$rank] split [$split] and sample [$sample]\n";

		my $num;

		if ($rank =~ /top/)
		{
			$num = 0;
		}
		elsif ($rank =~ /middle/)
		{
			$num = 1;
		}
		elsif ($rank =~ /bottom/)
		{
			$num = 2;
		}
		else 
		{
			die "Error with rank!";
		}

		$hash{$wig}{ranks}{$split}{$sample}[$num] =  { file=>$file, erfs=>$erfs };
	}
	elsif ($bed =~ /unique|common/)
	{
		my ($sample, $uOrC) = $bed =~ /(.+)_(common|unique)/;

		my $num = 0;

		if ($uOrC =~ /common/)
		{
			$num = 1;
		}

		$hash{$wig}{uniqueOrCommon}{$sample}[$num] = { file=>$file, erfs=>$erfs };
	}
	elsif ($erfs eq "genes")
	{
		warn "pushing to control\n";
		push(@{$hash{$wig}{control}}, {file => $file, erfs=> $erfs});
	}
	else 
	{
		
		push(@{$hash{$wig}{normal}}, {file=>$file, erfs => $erfs});
	}
}

#open (OUT, ">", "Master_boxplot.sh");
open (OUT, ">", "Master_boxplot.R");
print OUT "library(ggplot2)\npdf(\"boxplots.pdf\", width=25, height=5)\n";
foreach my $wig (keys %hash)
{
	open(R, ">", "$wig\_boxplot.R");

#	print OUT "R --no-save < $wig\_boxplot.R\n";
	print OUT "source(\"$wig\_boxplot.R\")\n";

	print R "library(reshape2)
library(ggplot2)

";
	my @array;

	warn "wig is [$wig]\n";
	for (my $control = 0; $control < @{$hash{$wig}{control}}; $control++)
	{
		print R "$hash{$wig}{control}[$control]{erfs}<-read.delim(\"$hash{$wig}{control}[$control]{file}\", header=F)\n";
		print R "$hash{$wig}{control}[$control]{erfs}<-$hash{$wig}{control}[$control]{erfs}\$V4\n";
		push(@array, "data.frame($hash{$wig}{control}[$control]{erfs}=log10($hash{$wig}{control}[$control]{erfs}), group=\"$hash{$wig}{control}[$control]{erfs}\", sample=\"AltERFs\")");
		push(@array, "data.frame($hash{$wig}{control}[$control]{erfs}=log10($hash{$wig}{control}[$control]{erfs}), group=\"$hash{$wig}{control}[$control]{erfs}\", sample=\"OrigERFs\")");
	}

	for(my $other = 0; $other < @{$hash{$wig}{normal}}; $other++)
	{
		print R "$hash{$wig}{normal}[$other]{erfs}<-read.delim(\"$hash{$wig}{normal}[$other]{file}\", header=F)\n";
		print R "$hash{$wig}{normal}[$other]{erfs}<-$hash{$wig}{normal}[$other]{erfs}\$V4\n";

		push(@array, "data.frame($hash{$wig}{normal}[$other]{erfs}=log10($hash{$wig}{normal}[$other]{erfs}), group=\"All Peaks\", sample=\"$hash{$wig}{normal}[$other]{erfs}\")");
	}

	foreach my $split (sort keys %{$hash{$wig}{ranks}})
	{
		foreach my $sample (sort keys %{$hash{$wig}{ranks}{$split}})	
		{
			for (my $i = 0; $i < @{$hash{$wig}{ranks}{$split}{$sample}}; $i++)
			{		
				my $rank;

				if ($i == 0)
				{
					$rank = "top_$hash{$wig}{ranks}{$split}{$sample}[$i]{erfs}";
				}
				elsif ($i == 1)
				{
					$rank = "middle_$hash{$wig}{ranks}{$split}{$sample}[$i]{erfs}";
				}
				elsif ($i == 2)
				{
					$rank = "bottom_$hash{$wig}{ranks}{$split}{$sample}[$i]{erfs}";
				}
			
				print R "$split\_$sample\_$i<-read.delim(\"$hash{$wig}{ranks}{$split}{$sample}[$i]{file}\", header=F)\n";
				print R "$split\_$sample\_$i<-$split\_$sample\_$i\$V4\n";
				push(@array, "data.frame($rank=log10($split\_$sample\_$i), group=\"Split by $split\", sample=\"$hash{$wig}{ranks}{$split}{$sample}[$i]{erfs}\")");
			}	
		}	
	}	

	foreach my $sample (sort keys %{$hash{$wig}{uniqueOrCommon}})
	{
		for (my $i = 0; $i < @{$hash{$wig}{uniqueOrCommon}{$sample}}; $i++)
		{
			my $oc;
			if ($i == 0)
			{	
				$oc = "unique";
			}
			else
			{
				$oc = "common";
			}

			print R "$oc\_$sample<-read.delim(\"$hash{$wig}{uniqueOrCommon}{$sample}[$i]{file}\", header=F)\n";
			print R "$oc\_$sample<-$oc\_$sample\$V4\n";

			push(@array, "data.frame($sample\_$oc=log10($oc\_$sample), group=\"Unique And Common\", sample=\"$hash{$wig}{uniqueOrCommon}{$sample}[$i]{erfs}\")");
		}
	}

	print R "data<-list(" . join(",\n", @array) . ")\n";
	print R "data<-melt(data)\n";

#	print R "png(\"$wig\_boxplot.png\", heigh=600, width=1600)\n";
	print R "print(ggplot(data, aes(group, value, fill=variable))+geom_boxplot() + ggtitle(\"$wig\") + xlab(\"Peaks\") + ylab(\"$wig Signal\") + facet_grid(.~sample) + theme(axis.text.x=element_text(size=14, colour=rgb(0,0,0)), axis.text.y = element_text(size=14, colour=rgb(0,0,0))))\n";
#	print R "dev.off()\n";
	close R;
}
print OUT "dev.off()\n";
close OUT;

`R --no-save < Master_boxplot.R`;
