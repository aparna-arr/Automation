#!/usr/bin/env perl
use warnings;
use strict;

my ($mcrs, $conversion, $outfile) = @ARGV;
die "usage: <MCR file> <UCSC conversion file cytobands.txt> <outfile>\n" unless @ARGV == 3;

open(MCR, "<", $mcrs) or die "could not open $mcrs: $!\n";
open(ERR, ">", "err.out");
open(OUT, ">", $outfile) or die "could not open $outfile: $!\n";

my %mcr_coords;
#my %mcr_dup;
while(<MCR>) {
	my $line = $_;
	chomp $line;

	if ($line !~ /^\d+/ || $line !~ /^\d+\t.+\t\S+\s*$/) {
		print ERR $line . "\n";	
		next;
	}

	my ($mcr_num, $trash, $coord) = split(/\t/, $line);

#	next if (exists($mcr_dup{$coord}));
#
#	$mcr_dup{$coord} = 1;

	push(@{$mcr_coords{$mcr_num}}, $coord);
}
close ERR;
close MCR;

open(CONV, "<", $conversion) or die "could not open $conversion: $!\n";

my %conv_coords;
while(<CONV>) {
	my $line = $_;
	chomp $line;

	next if ($line !~ /^chr/);

	my ($chr, $start, $end, $cyto, $trash) = split(/\s+/, $line);

	my ($pq) = $cyto =~ /^([p|q][^\.]+)\.*\d*$/;

#	die "pq is [$pq]\n";
#	warn "while loop [$cyto]\n";

	if ($pq eq $cyto) {
		$conv_coords{$chr}{$pq} = {start => $start, end => $end};
	}
	else {
		my ($dec) = $cyto =~ /^$pq\.(\d+)$/;
		my (@dec_ar) = split("", $dec);

		if (@dec_ar == 1) {
			$conv_coords{$chr}{$pq}{$dec} = {start => $start, end => $end};
		} 
		elsif (@dec_ar == 2) {
			$conv_coords{$chr}{$pq}{$dec_ar[0]}{$dec_ar[1]} = {start => $start, end => $end};
		} 
		elsif (@dec_ar == 3) {
			$conv_coords{$chr}{$pq}{$dec_ar[0]}{$dec_ar[1]}{$dec_ar[2]} = {start => $start, end => $end};
		} 
		else {
			warn "WHILE LOOP dec_ar has > 3 numbers! it is size: " . @dec_ar . "\n";
		}
			
	}
}

close CONV;

my %results;

foreach my $mcr (keys %mcr_coords) {
	for (my $i = 0; $i < @{$mcr_coords{$mcr}}; $i++) {
		my $raw_coord = $mcr_coords{$mcr}[$i];

		my $start = -1;
		my $end = -1;

		if ($raw_coord =~ /^.+-.+$/) {
			next;
		}

		if ($raw_coord =~ /^.+\|.+$/) {
			next;
		}
		
		my ($chr_num, $pq) = $raw_coord =~ /^(.+)([p|q][^\.]*)\.*\d*$/;

		my $chr = "chr" . $chr_num;

		warn "chr is [$chr], pq is [$pq], raw_coord is [$raw_coord] chr_number is [$chr_num]\n";

		if ($pq =~ /^[p|q]$/) {
			warn "pq is just p or q! raw: $raw_coord ($pq)\n";
			next;
		}

		if ("$chr_num" . $pq eq $raw_coord) {
			if (exists($conv_coords{$chr}{$pq}))
			{
				if (exists($conv_coords{$chr}{$pq}{start})) {
					$start = $conv_coords{$chr}{$pq}{start};
					$end = $conv_coords{$chr}{$pq}{end};
				}
				else {
					warn "there is no start but pq exists! raw: $raw_coord ($pq)\n";

					foreach my $sub (keys $conv_coords{$chr}{$pq}) {
						if (exists($conv_coords{$chr}{$pq}{$sub}{start})) {
							$start = $conv_coords{$chr}{$pq}{$sub}{start};
							$end = $conv_coords{$chr}{$pq}{$sub}{end};
						}
						else {
							foreach my $subsub(keys $conv_coords{$chr}{$pq}{$sub}) {
								if (exists($conv_coords{$chr}{$pq}{$sub}{$subsub}{start})) {
									$start = $conv_coords{$chr}{$pq}{$sub}{$subsub}{start};
									$end = $conv_coords{$chr}{$pq}{$sub}{$subsub}{end};
								}
								else {
									foreach my $subsubsub (keys $conv_coords{$chr}{$pq}{$sub}{$subsub}) {
										if (exists($conv_coords{$chr}{$pq}{$sub}{$subsub}{$subsubsub}{start})) {
											$start = $conv_coords{$chr}{$pq}{$sub}{$subsub}{$subsubsub}{start};
											$end = $conv_coords{$chr}{$pq}{$sub}{$subsub}{$subsubsub}{end};
										}
										else {
											warn "more than 3 levels deep!!!!\n";
										}
									}
								}
							}
						}
						
					}
				}
			}
			else {
				warn "$raw_coord ($pq) does not exist!\n";
			}
		}
		else {
			my ($dec) = $raw_coord =~ /^$chr_num$pq\.(\d+)$/;
			warn "dec is [$dec] from raw_coord [$raw_coord]\n";
			my (@dec_ar) = split("", $dec);

			if (@dec_ar == 1) {
				if (exists($conv_coords{$chr}{$pq}{$dec})){
					if (exists($conv_coords{$chr}{$pq}{$dec}{start})) {
						$start = $conv_coords{$chr}{$pq}{$dec}{start};
						$end = $conv_coords{$chr}{$pq}{$dec}{end};
					}
					else {
						foreach my $subcoords (keys %{$conv_coords{$chr}{$pq}{$dec}}) {
							if (exists($conv_coords{$chr}{$pq}{$dec}{$subcoords}{start})) {
								if ($conv_coords{$chr}{$pq}{$dec}{$subcoords}{start} < $start || $start == -1) {
									$start = $conv_coords{$chr}{$pq}{$dec}{$subcoords}{start};
								}

								if ($conv_coords{$chr}{$pq}{$dec}{$subcoords}{end} > $end) {
									$end = $conv_coords{$chr}{$pq}{$dec}{$subcoords}{end};
								}
							}
							else {
								foreach my $subsub (keys %{$conv_coords{$chr}{$pq}{$dec}{$subcoords}}) {
									if ($conv_coords{$chr}{$pq}{$dec}{$subcoords}{$subsub}{start} < $start || $start == -1) {
										$start = $conv_coords{$chr}{$pq}{$dec}{$subcoords}{$subsub}{start};
									}
	
									if ($conv_coords{$chr}{$pq}{$dec}{$subcoords}{$subsub}{end} > $end) {
										$end = $conv_coords{$chr}{$pq}{$dec}{$subcoords}{$subsub}{end};
									}
								}
							}
						}

					}
				}
				else {
					warn "$raw_coord ($pq) ($dec) does not exist!\n";
				}
			}
			elsif (@dec_ar == 2) {
				if (exists($conv_coords{$chr}{$pq}{$dec_ar[0]}{$dec_ar[1]})){
					if (exists($conv_coords{$chr}{$pq}{$dec_ar[0]}{$dec_ar[1]}{start})) {
						$start = $conv_coords{$chr}{$pq}{$dec_ar[0]}{$dec_ar[1]}{start};
						$end = $conv_coords{$chr}{$pq}{$dec_ar[0]}{$dec_ar[1]}{end};
					}
					else {
						foreach my $subcoords (keys %{$conv_coords{$chr}{$pq}{$dec_ar[0]}{$dec_ar[1]}}) {
							if ($conv_coords{$chr}{$pq}{$dec_ar[0]}{$dec_ar[1]}{$subcoords}{start} < $start || $start == -1) {
								$start = $conv_coords{$chr}{$pq}{$dec_ar[0]}{$dec_ar[1]}{$subcoords}{start};
							}

							if ($conv_coords{$chr}{$pq}{$dec_ar[0]}{$dec_ar[1]}{$subcoords}{end} > $end) {
								$end = $conv_coords{$chr}{$pq}{$dec_ar[0]}{$dec_ar[1]}{$subcoords}{end};
							}
						}

					}
				}
				else {
					warn "$raw_coord ($pq) ($dec_ar[0]) ($dec_ar[1]) does not exist!\n";
				}
			} 
			elsif (@dec_ar == 3) {
				if (exists($conv_coords{$chr}{$pq}{$dec_ar[0]}{$dec_ar[1]}{$dec_ar[2]})) {
					$start = $conv_coords{$chr}{$pq}{$dec_ar[0]}{$dec_ar[1]}{$dec_ar[2]}{start};
					$end = $conv_coords{$chr}{$pq}{$dec_ar[0]}{$dec_ar[1]{$dec_ar[2]}}{end};
				}
				else {
					warn "$raw_coord ($pq) ($dec_ar[0]) ($dec_ar[1]) ($dec_ar[2]) does not exist!\n";
				}
			} 
			else {
				warn "dec_ar has > 2 numbers! it is size: " . @dec_ar . "\n";
			}
		}
	
		if ($start == -1 || $end == -1) {
			warn "start is [$start], end is [$end], there is a problem!\n";
		}
		else {
			push(@{$results{$chr}{$mcr}}, {start => $start, end => $end});
			warn "adding start [$start] end [$end] to results for mcr [$mcr] chr [$chr]\n";

		}
	}
}
#die;
foreach my $chr (keys %results) {
	foreach my $mcr (keys %{$results{$chr}}) {
		my $start = -1;
		my $end = -1;

		for (my $i = 0; $i < @{$results{$chr}{$mcr}}; $i++) {
			if ($start == -1 || $results{$chr}{$mcr}[$i]{start} < $start) {
				$start = $results{$chr}{$mcr}[$i]{start};
			}
	
			if ($results{$chr}{$mcr}[$i]{end} > $end) {
				$end = $results{$chr}{$mcr}[$i]{end};
			}
		}
	
		if ($start == -1 || $end == -1) {
			warn "something went wrong! start is [$start], end is [$end]\n";
		}
		else {
			print OUT "$chr\t$start\t$end\t$mcr\n";
		}					
	}
}

close OUT;

`sort -k 1,1 -k 2,2n $outfile > tmp; mv tmp $outfile`;
