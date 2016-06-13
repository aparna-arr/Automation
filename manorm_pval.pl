#!/usr/bin/env perl
use warnings;
use strict;

my $usage = "
usage: <MAnorm outfile .xls> <new outfile name>

Warnings:
REQUIRES pre-processing, see comments in while loop
";

my ($ma_out, $outfile) = @ARGV;
die $usage unless @ARGV;

open (IN, "<", $ma_out) or die "Could not open $ma_out\n";
open (OUT, ">", $outfile) or die "Could not open $outfile\n";

while (<IN>) {
  my $line = $_;
  chomp $line;

  my @fields = split(/\s+/, $line);
  my $newline = $line;

#  if ($fields[9] > 0) {
#    $newline.="\tz"; # Intersect prioleau early 
#  }
#  elsif ($fields[10] > 0) {
#    $newline .="\tn"; # No intersect prioleau, intersect early
#  }
#  elsif ($fields[8] > 5) {
  if ($fields[8] eq "NA") {
    $newline.="\t0";
  }
  elsif ($fields[8] eq "Inf") {
      $newline.="\t5";
  } 
  elsif ($fields[8] !~ /^\d/)
  {
    print STDERR "skipping line [" . $line . "]\n";
    next;
  }
  elsif ($fields[8] > 5) {
    #p-value cut offs

    if ($fields[8] > 5 && $fields[8] <= 10) {
      $newline.="\t1";
    }
    if ($fields[8] > 10 && $fields[8] <= 50) {
      $newline.="\t2";
    }
    if ($fields[8] > 50 && $fields[8] <= 150) {
      $newline.="\t3";
    }
    if ($fields[8] > 150 && $fields[8] <= 300) {
      $newline.="\t4";
    }
    if ($fields[8] > 300) {
      $newline.="\t5";
    }
  }
  else {
    $newline.="\t0";
  }
  print OUT "$newline\n";
} 

close IN;
close OUT;
