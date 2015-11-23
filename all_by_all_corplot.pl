#!/usr/bin/env perl
use warnings;
use strict;

my ($dir) = @ARGV;
die "usage: $0 <dir>\n" unless @ARGV == 1;

opendir(DIR, $dir);
my @files = readdir(DIR);
closedir(DIR);

my %hash;
foreach my $file (@files)
{
	next if (-d $file || $file =~ /rep[12]/ || $file !~ /\.mapwig$/);

        my ($wig, $bed) = $file =~ /(.+?(?:_GSE\d+|_merge)*)_(.+?)(?:_combined_reps|\.)/;
	
	print "wig [$wig] bed [$bed]\n";

	$hash{$bed}{$wig} = $file;
}

#open (OUT, ">", "Master.sh");
open (OUT, ">", "Master.R");
print OUT "library(ggplot2)\n";
print OUT "pdf(\"panelcorplots.pdf\", width=18, height=18)\n";
foreach my $beds (sort keys %hash)
{
#	print OUT "R --no-save < $beds.R\n";
	print OUT "source(\"$beds.R\")\n";
	open (R, ">", "$beds.R");

	print R "library(reshape2)
library(ggplot2)
source(\"../../panels.R\")
";

	my @colnames;
	foreach my $wigs (sort keys %{$hash{$beds}})
	{
		push (@colnames, $wigs);
		print R "
$wigs<-read.delim(\"$hash{$beds}{$wigs}\", header=F)
$wigs<-$wigs\$V4
#quartile<-quantile($wigs, na.rm=TRUE)

# remove outliers
#$wigs\[$wigs < quartile[2]] <- NA
#$wigs\[$wigs > quartile[4]] <- NA


$wigs.log<-$wigs
$wigs.log[$wigs.log == 0] <- NA
$wigs.log <- log10($wigs.log)


";
	}

	print R "data<-as.data.frame(cbind(" . join(".log,", @colnames) . "))\n";
#	print R "data<-as.data.frame(cbind(" . join(",", @colnames) . "))\n";
	print R "colnames(data)<-c(" . (join ',', map qq("$_"), @colnames) . ")\n";
#	print R "data.corr<-round(cor(data, method=\"p\", use=\"na.or.complete\"), 2)\n";
#	print R "data.corr.m<-melt(data.corr)\n";
#	print R "png(\"$beds\_corr.png\", width=1200, height=1000)\n";
#	print R "
#ggplot(data.corr.m, aes(x=Var1, y=Var2, fill=value)) + geom_tile() + geom_text(aes(Var1, Var2, label=value)) + scale_fill_gradient2(low=\"darkblue\", mid=\"white\", high=\"darkred\", limits=c(-1,1), midpoint=0) + ggtitle(\"$beds Corrplot\") + xlab(\"\") + ylab(\"\")
#";

	print R "panelcor(data, \"$beds\")\n";
#	print R "dev.off()\n";

	close R;
}
print OUT "dev.off()\n";
close OUT;
#`bash Master.sh`;
`R --no-save < Master.R`
