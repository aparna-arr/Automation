#!/usr/bin/env perl
use warnings;
use strict;

my ($uniq_thread_num, @file_list) = @ARGV;
die "usage: $0 <unique thread number for outfile>  <list of paired fastq.gz files to check>" unless @ARGV >= 2;

open(OUT, ">", "errorfiles_$uniq_thread_num.txt") or die "could not open outfile:$!\n";
open(OUT_LINES, ">", "errorlines_$uniq_thread_num.txt") or die "could not open outfile 2:$!\n";

foreach my $file (@file_list) {

	#`gzip -d $file`;
	#my ($no_gz) = $file =~ /(.+)\.gz/;

	#warn "on file $file";
	open(TMP, "gunzip -c $file |") or die "could not open $file:$!";

	while(<TMP>) {
		my $line = $_;
		chomp $line;
		if ($. % 4 == 1) {
		
			if ($line !~ /^\@.+\/[12]$/) {
				#warn "Wrong format on file $file:\n[$line]!";
				print OUT $file . "\n";
				print OUT_LINES $file . ":[$line]\n";
				last;
			}
			#warn $line;
			#$die_counter++;
			#if ($die_counter == 5) {
			#		`gzip $no_gz`;
			#	close TMP;
			#		die;
			#}
		}
	}
	close TMP;
	#`gzip $no_gz`;
}
close OUT;
close OUT_LINES;
