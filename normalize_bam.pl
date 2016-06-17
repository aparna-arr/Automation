#!/usr/bin/env perl
use warnings;
use strict;

#
# normalize_bam.pl
#
# Description: 
# 	Takes in a list of bam files to be normalized
# 	to each other. Finds # of reads in each file, 
# 	uses Fisher-Yates algorithm to randomly 
# 	select reads to keep so each file has
# 	the same number of reads as the lowest-read
# 	file. Depends on samtools flagstat to get # reads.
#
# Author: Aparna Rajpurkar (2016)
# Email: aparna.arr@gmail.com
# 
# NO GUARANTEE OF CORRECTNESS OR FUNCTION IS MADE
# USE AT YOUR OWN RISK.
#

my $usage = "
Normalize Bam Files

usage: $0 [-s <optional seed>] <list of bam files to normalize>

This script takes in multiple bam files and finds 
the file with the lowest readcount

All other files will be randomly downsampled to
equal the readcount of the smallest file.

Outfiles: <input bam>.norm

If input is sorted, output will also be sorted.

WARNING: High memory usage!
";

main();

sub main {
	my (@bamfiles) = @ARGV;
	die "Must enter more than 1 bamfile!\n$usage" unless @ARGV >= 2;

	if ($bamfiles[0] eq '-s' && $bamfiles[1] =~ /^\d+$/) {
		srand($bamfiles[1]);
		@bamfiles = @bamfiles[2..@bamfiles-1];
	}

	my %readcount;
	my $min = -1;

	warn "\nCounting reads for each file\n";
	foreach my $file (@bamfiles) {
		warn "On file [$file]\n";
	
		warn "- Counting reads\n";
		$readcount{$file} = count_reads($file);
		warn "- For file [$file], reads are [$readcount{$file}]\n";

		if ($min == -1) {
			$min = $readcount{$file};
		}
		elsif ($min > $readcount{$file}) {
			$min = $readcount{$file};
		}
	}

	warn "\nRemoving reads for each file\n";
	foreach my $file (@bamfiles) {
	
		warn "On file [$file]\n";
		
		my @index_ar;

		for (my $i = 0; $i < $readcount{$file}; $i++) {
			$index_ar[$i] = $i;
		}

		warn "- Begin shuffling index array\n";

		shuffle(\@index_ar);

		warn "- Select min read count indicies, sort\n";

		@index_ar = @index_ar[0..$min-1];
		my @sort_sub_ar = sort {$a <=> $b} @index_ar;

#		open (TEST, ">", $file . "test.out");
#		for (my $d = 0; $d < @sort_sub_ar; $d++) {
#			print TEST "$sort_sub_ar[$d]\n";
#		}
#		close(TEST);
#
		warn "- Reading in sam from bam file\n";

		my @sam = `samtools view $file`;
		my $header = `samtools view -H $file`;
		
		warn "- Constructing tmp sam outfile\n";

		my $out_sam = $header;
		
		for (my $i = 0; $i < @sort_sub_ar; $i++) {
			$out_sam .= $sam[$sort_sub_ar[$i]];
		}
		
		@sam = ();
		@index_ar = ();
		@sort_sub_ar = ();
	
		warn "- Printing out tmp sam outfile\n";

		open (TMP, ">", "tmpsam");
		print TMP $out_sam;
		close TMP;
		
		$out_sam = "";

		warn "- Converting to bam\n";

		`samtools view -bhS tmpsam > $file.norm`;

		warn "- Done\n";

#		`echo $out_sam | samtools view -bhS - > $file.norm`;
#		warn "file $file readcount is $readcount{$file}, file ar len is " . @sam . "\n";				
	}		
	
	`rm tmpsam`;	
}

sub shuffle {
	my $ar_ref = $_[0];
	
	for (my $i = @{$ar_ref} - 1; $i > 0; $i--)
	{
		my $j = int (rand($i+1)); 
		my $tmp = $ar_ref->[$j];
		$ar_ref->[$j] = $ar_ref->[$i];	
		$ar_ref->[$i] = $tmp;
	}
}

sub count_reads {
	my $filename = $_[0];

	my $output = `samtools flagstat $filename`;

#	warn "bamtools output is [\n$output\n]\n";

	my ($total) = $output =~ /(\d+)\s+\+\s+\d+\s+in\s+total.+/;
	my ($mapped) = $output =~ /(\d+)\s+\+\s+\d+\s+mapped.+/;

#	warn "my total is [$total], mapped is [$mapped]\n";	

	if (defined($total) && $total == $mapped && $total != 0) {
		return $total;
#		warn "for filename $filename, reads are $total\n";
	}
	else
	{
		die "Your file is not cleaned! Run a script like Stella's bam_RemoveBlacklist.pl first on all your files.\n";
	}
	

}
