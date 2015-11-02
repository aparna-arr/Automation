#!/usr/bin/env perl
use warnings ;
use strict ;

my $warning = "
Warnings
Skips track and comment lines
Outfile: STDOUT

";

my ($input) = @ARGV ;
die "usage : $0 <bedgraph file>\n$warning" unless @ARGV ;

chomp $input ;
open (BED, "<", $input) or die "Could not open $input\n";
my $prevspan = -1 ;
my $prevchr = "INIT";
while (<BED>) 
{
  my $line = $_ ;
  chomp $line ;
  if ($line =~ /^track/ || $line =~ /\#/)
  {
    next ;
  }
  my ($chr, $start, $end, $value) = split (/\t/, $line) ;
  my $span = $end - $start ;

  if ($span != $prevspan || $chr ne $prevchr) 
  {
    print "variableStep chrom=$chr span=$span\n" ;
    print "$start\t$value\n" ;
  }
  else
  {
    print "$start\t$value\n" ;
  }
  $prevspan = $span ;
  $prevchr = $chr;
}

close BED ;
