#!/usr/bin/env perl
use warnings;
use strict;

## SET BIN SIZE ##
my $smooth = 100000;

my ($input, $chromfile, $outfile) = @ARGV;
die "usage: <brdu wig file SORTED, FIXED SIZE BINS, -v blacklist> <chromosome length file> <s50 outfile name>\n" unless @ARGV == 3;

open (IN, "<", $input) or die "could not open $input\n";

my $curr_span = -1;
my $curr_chr = "INIT";
my %wig;

my %wighash;

warn "starting read in\n";
while(<IN>) {
	my $line =$_;
	chomp $line;
	
	if ($line =~ /^variableStep/) {
		my ($chr, $span) = $line =~ /chrom=(.+)\sspan=(\d+)/;
#		warn "chr is [$chr]\n";
#		die;	
		if ($chr ne $curr_chr) {
			warn "on chr $chr\n";
			$curr_chr = $chr;
			$wighash{$chr} = 1;
		}
		
		if ($span != $curr_span && $curr_span != -1) {
			die "curr span is $span and prev span was $curr_span!\n";
		}
		elsif ($curr_span = -1) {
			$curr_span = $span;
		}
	}	
	elsif ($line =~ /^\d+/) {
		my ($pos, $val) = split(/\s+/, $line);
		push(@{$wig{$curr_chr}}, {pos => $pos, val => $val});	
	}	
}

warn "curr_span is $curr_span\n";
close IN;

warn "done with read in\n";
warn "starting chr length file\n";
open(CHR, "<", $chromfile) or die "could not open $chromfile\n";

my %bins;
while (<CHR>) {
	my $line = $_;
	chomp $line;

	my ($chr, $length) = split(/\s+/, $line);

	next if (!exists($wighash{$chr}));

	my $bincount = int($length/$smooth);

	for (my $i = 0; $i < $bincount; $i++) {
		$bins{$chr}[$i] = 0;
	}
}

close CHR;
warn "done with chr length file\n";
warn "starting smooth\n";
foreach my $chr (keys %bins) {
	warn "on chr $chr\n";
	my $max_signal = -1;
	my $min_signal = -1;

	for (my $i = 0; $i < @{$wig{$chr}}; $i++) {
		my $index = int($wig{$chr}[$i]{pos}/$smooth);
		last if ($index > @{$bins{$chr}});
#		warn "[$index], [$i]\n";

		$bins{$chr}[$index] += $wig{$chr}[$i]{val} * $curr_span;
#		warn "$bins{$chr}[$index]\n";		
		if ($bins{$chr}[$index] > $max_signal) {
			$max_signal = $bins{$chr}[$index];
		}
	
		if ($min_signal == -1 || ($bins{$chr}[$index] < $min_signal && $bins{$chr}[$index] != 0)) {
			$min_signal = $bins{$chr}[$index];
		}
	}
		

	## TESTING ##
#	$min_signal = 0;	
	warn "max signal for chr $chr is " . ($max_signal / $smooth) . ", min signal is " . ($min_signal / $smooth) . "\n";

	my @sorted = sort {$b <=> $a} @{$bins{$chr}};
	
	my $i = @sorted - 1;
	while($i > -1 && $sorted[$i] == 0) {
		$i--;
	}

	warn "i is $i, sorted size is " . @sorted . "\n";

	@sorted = @sorted[0..$i];	

	my $median_signal = $sorted[int(@sorted/2)];
	my $first_q_signal = $sorted[int(@sorted/4)];
	my $third_q_signal = $sorted[int(@sorted/4*3)];

	warn "first q is " . ($first_q_signal/$smooth) . ", median is " . ($median_signal/$smooth) . ", third q is " . ($third_q_signal/$smooth) . "\n";

	@sorted = ();

	for (my $j = 0; $j < @{$bins{$chr}}; $j++) {

		if ($max_signal == 0) {
			$bins{$chr}[$j] = "NA";
		}
		elsif ($bins{$chr}[$j] == 0) {
			$bins{$chr}[$j] = "NA";
		}
		else {
			# linear interpolation should go here
			# 1st q = 25%
			# med = 50%
			# 3rd q = 75%

#			my ($x0, $x1, $y0, $y1);
#
#			if ($bins{$chr}[$j] <= $first_q_signal) {
#				$x0 = $max_signal;	
#				$x1 = $first_q_signal;
#				$y0 = 100;
#				$y1 = 75;
#			}
#			elsif ($bins{$chr}[$j] <= $median_signal) {
#				$x0 = $first_q_signal;	
#				$x1 = $median_signal;
#				$y0 = 75;
#				$y1 = 50;
#
#			}
#			elsif ($bins{$chr}[$j] <= $third_q_signal) {
#				$x0 = $median_signal;	
#				$x1 = $third_q_signal;
#				$y0 = 50;
#				$y1 = 25;
#
#			}
#			else {
#				$x0 = $third_q_signal;	
#				$x1 = $min_signal;
#				$y0 = 25;
#				$y1 = 0;
#			}
#
#			if ($x0 == $x1) {
#				warn "x0 == x1 ($x0 == $x1) putting NA!\n";
#				$bins{$chr}[$j] = "NA";
#				next;
#			}
#		
#			my $x = $bins{$chr}[$j];
#			my $y = $y0 + ($y1 - $y0) * ($x - $x0) / ($x1 - $x0);
#
#			$bins{$chr}[$j] = $y;
			$bins{$chr}[$j] = (1-($bins{$chr}[$j] / $max_signal))*100;
		}
	}
}

warn "done with smooth\n";
warn "printing outfiles\n";
foreach my $chr (sort keys %bins) {
	warn "on chr $chr\n";

	open (OUT, ">", "$chr\_$outfile") or die "could not open chr$chr\_$outfile\n";

	for (my $i = 0; $i < @{$bins{$chr}}; $i++) {
		print OUT ($i*$smooth) . "\t" . $bins{$chr}[$i] . "\n";	
		print OUT (($i+1) * $smooth - 1) . "\t" . $bins{$chr}[$i] . "\n";
	}

	close OUT;	
}
warn "done with printing\n";
