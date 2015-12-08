#!/usr/bin/env perl
use warnings;
use strict;

my ($genes, $pol2_wig, $bin_size, $TSS_MIN_LENGTH, $outfile) = @ARGV;
die "usage: <Genes sorted bed: 1 transcript per gene> <wig file of pol2> <bin size> <TSS min total length (ex. 1500)> <outfile>" unless @ARGV == 5;

open(GENES, "<", $genes) or die "Could not open file $genes: $!\n";

my %genes;
my @strands;

print STDERR "Reading in genes file\n";
while(<GENES>)
{
	my $line = $_;
	chomp $line;
	
	next if ($line =~ /^#|track/);
	
	my ($chr, $start, $end, $strand, $trash) = split(/\t/, $line);

	###warn "my [$chr] [$start] [$end] [$strand]\n";

	push(@{$genes{$chr}{$strand}}, {ignore => 0, start => $start, end => $end, strand => $strand});
	
	# 43 == + 
	# 45 == -
	# 43 - 45 = -2 ; -2 % 3 = 1
	# 45 - 45 = 0 ; 0 % 3 = 0
	$strands[(ord($strand) - 45) % 3] = $strand;	
}

close GENES;

open (POL, "<", $pol2_wig) or die "Could not open file $pol2_wig: $!\n";

my %pol2;

my $curr_chr = "INIT";
my $curr_span = -1;

print STDERR "Reading in pol2 wig file\n";
while(<POL>)
{
	my $line = $_;
	chomp $line;

	next if ($line =~ /^#|track/);

	if ($line =~ /^variableStep/)
	{
		($curr_chr, $curr_span) = $line =~ /^variableStep\s+chrom=(.+)\s+span=(\d+)$/;
	}
	elsif ($line =~ /^\d+/)
	{
		my ($pos, $val) = split(/\s+/, $line);

		##warn "my pos [$pos] and val [$val]\n";

		push(@{$pol2{$curr_chr}}, {start => $pos, end => $pos + $curr_span, val => $val});

		##warn "start is [$pos] end is " . ($pos + $curr_span) . " val is $val\n";
	}
}

close POL;

open (OUT, ">", $outfile) or die "Could not open $outfile: $!\n";
foreach my $chr (sort keys %genes)
{
	next if (keys %{$genes{$chr}} != 2);

	next if (!exists($pol2{$chr}));

	print STDERR "Preprocessing chr $chr\n";

	warn "Strands hash size is " . ( keys %{$genes{$chr}} ) . "\n";

#	foreach my $debug (keys %{$genes{$chr}})
#	{
		###warn "Strand is [$debug]\n";
		###warn "Ar size is " . @{$genes{$chr}{$debug}} . "\n";
#	}

	my @test;
	$test[0] = "unchanged";
	$test[1]{test} = "printme";

	my $test_ref = \@test;

	preprocess($genes{$chr}{$strands[0]}, $genes{$chr}{$strands[1]}, \@test);

	###warn "test0 is $test[0]\n";

	###warn "testref 0 is $test_ref->[0]\n";
	###warn "testref 1 is $test_ref->[1]{test}\n";

	my $strand = "+";
	
	print STDERR "Processing strand $strand of chromosome $chr\n";
	for (my $i = 0; $i < @{$genes{$chr}{$strand}}; $i++)
	{
#		warn "on $i of " . @{$genes{$chr}{$strand}} . "\n";

		next if ($genes{$chr}{$strand}[$i]{ignore} == 1);

		print OUT "$chr\t$genes{$chr}{$strand}[$i]{start}\t$genes{$chr}{$strand}[$i]{end}\t$strand\t" . get_ratio($genes{$chr}{$strand}[$i]{TSS}, $genes{$chr}{$strand}[$i]{genebody}, \%pol2, $chr) . "\n";	
	}

	$strand = "-";
	print STDERR "Processing strand $strand of chromosome $chr\n";
	for (my $i = 0; $i < @{$genes{$chr}{$strand}}; $i++)
	{
#		warn "on $i of " . @{$genes{$chr}{$strand}} . "\n";
	
		next if ($genes{$chr}{$strand}[$i]{ignore} == 1);

		print OUT "$chr\t$genes{$chr}{$strand}[$i]{start}\t$genes{$chr}{$strand}[$i]{end}\t$strand\t" . get_ratio($genes{$chr}{$strand}[$i]{TSS}, $genes{$chr}{$strand}[$i]{genebody}, \%pol2, $chr) . "\n";	
	}
}
close OUT;

#################
## SUBROUTINES ##
#################

sub get_ratio
{
		my %TSS = %{$_[0]};
		my %Genebody = %{$_[1]};
		my $pol2 = $_[2];
		my $chr = $_[3];
		# find TSS max
		my $max = 0;
		my $bins_start = $TSS{start};
		my $bins_end = $TSS{end};

		my $num_bins = int(($bins_end - $bins_start) / $bin_size + ($bin_size - 1));

		##warn "My bins start is $bins_start and end is $bins_end, num bins is $num_bins\n";
		##warn "Got number of bins\n";
		for (my $j = 0; $j < $num_bins; $j++)
		{
			my $start = $bins_start + $bin_size * $j;
			my $end = $bins_start + $bin_size + $bin_size * $j;

			my ($signal) = pol2($start, $end, $pol2->{$chr}); 
			
#			##warn "signal is $signal\n";

			if ($signal > $max)
			{
				$max = $signal;
			}
		}
		##warn "mapped pol2 to TSS\n";
		
		##warn "TSS max is $max\n";
		# find Genebody med
		my @bins;

		$bins_start = $Genebody{start};
		$bins_end = $Genebody{end};

		$num_bins = int((($bins_end - $bins_start) + ($bin_size - 1)) / $bin_size);
		##warn "My bins start is $bins_start and end is $bins_end, num bins is $num_bins\n";

		if ($num_bins < 5)
		{
			return 0;
		}

		##warn "got genebody bins\n";
		for (my $j = 0; $j < $num_bins; $j++)
		{
			my $start = $bins_start + $bin_size * $j;
			my $end = $bins_start + $bin_size + $bin_size * $j;

			$bins[$j] = pol2($start, $end, $pol2->{$chr}); 
#			##warn "signal is $bins[$j]\n";
		}

		##warn "mapped genebody\n";
		my @sort = sort {$a <=> $b} @bins;
			

		my $median = 1;
		my $this_med = 0;
		my $index = int(@bins / 2);

#		warn "Index is $index of " . @bins . "\n";

		if (@bins % 2 == 0)
		{
			# even
			$this_med = ($sort[$index] + $sort[$index+1]) / 2;
		}
		else
		{
			$index++;
			$this_med = $sort[$index];
		}

		##warn "this med is $this_med\n";
		if ($this_med > 0)
		{
			$median = $this_med;
		}

		if ($median < 1)
		{
			$median = $median + 1;
		}	

		##warn "My genebody median is $median\n";

#		warn "my max is $max my median is $median my ratio is ". ($max / $median) . "\n";

		my $perc = $max == 0 ? 0 : ($max / $median) / $max * 100;
		return ($max / $median) . "\t" . $perc ;
}

sub pol2
{
	my $start = $_[0];
	my $end = $_[1];
#	my @wig = @{$_[2]};
	my $wig = $_[2];
	
	my $signal = 0;

#	my $index = bsearch(\@wig, $start);
	my $index = bsearch($wig, $start);

#	for (my $i = $index; $i < @wig; $i++)	
	for (my $i = $index; $i < @{$wig}; $i++)	
	{
		if ($wig->[$i]{start} < $end && $wig->[$i]{end} > $start)
		{
			$signal += $wig->[$i]{val}; # NOTE expects non-overlapping wig
		}
		elsif ($wig->[$i]{start} > $end)
		{	
			last;
		}	
	}

	##warn "pol2: Start is $start, end is $end, signal is $signal\n";

	return $signal;
}

sub preprocess
{
#	my $array1 = $_[0];
#	shift(@$array1);
#	my $array2 = $_[1];
#	shift(@$array2);

	my $array1 = $_[0];
	my $array2 = $_[1];


	my $test = $_[2];

	$test->[0] = "change";

#	for (my $d = 0; $d < @args; $d++)
#	{
#		###warn "args $d is [$args[$d]]\n";
#		###warn "ar size is " . @{$args[$d]} . "\n";
#	}

	

	###warn "array1 size is " . @{$array1} . "\n";
	###warn "array2 size is " . @{$array2} . "\n";
#	my @array1 = shift(@$arg1);
#	my @array2 = shift(@$arg2);

	# assume longest transcript (1 transcript per gene)
	# Now: remove both + & - genes if antisense
	# then remove genes < 1.5kb: order is important here
	# bin gene length?? make giant array? high mem, low computation later
	# I want to splice out genes we don't use ... can do this for strand[1], but for strand[0] this will be tricky
		## using lazy deletion
	for (my $i = 0; $i < @{$array1}; $i++)
	{
		my $index_2 = bsearch($array2, $array1->[$i]{start});

		###warn "after bsearch index is $index_2\n";	
		for (my $j = $index_2; $j < @{$array2}; $j++)
		{
			###warn "in for of array2 loop\n";
			if ($array2->[$j]{start} < $array1->[$i]{end} && $array2->[$j]{end} > $array1->[$i]{start})
			{
				$array1->[$i]{ignore} = 1;	
				$array2->[$j]{ignore} = 1;	
			}
			elsif ($array2->[$j]{start} > $array1->[$i]{end})
			{
				last;
			}
		}

		if ($array1->[$i]{end} - $array1->[$i]{start} <= $TSS_MIN_LENGTH)
		{
			$array1->[$i]{ignore} = 1;
		}

		if ($array1->[$i]{ignore} != 1)
		{
			if ($array1->[$i]{strand} eq "+")
			{
				$array1->[$i]{TSS} = {
					start => $array1->[$i]{start} - int($TSS_MIN_LENGTH/2),
					end => $array1->[$i]{start} + int($TSS_MIN_LENGTH/2) - 1
				};
				$array1->[$i]{genebody} = {
					start => $array1->[$i]{start} + int($TSS_MIN_LENGTH),
					end => $array1->[$i]{end}
				};
			}
			else
			{
				$array1->[$i]{TSS} = {
					start => $array1->[$i]{end} - int($TSS_MIN_LENGTH/2),
					end => $array1->[$i]{end} + int($TSS_MIN_LENGTH/2) - 1
				};	

				$array1->[$i]{genebody} = {
					start => $array1->[$i]{start},
					end => $array1->[$i]{end} - int($TSS_MIN_LENGTH),
				};
			}
		}
	}

	for (my $k = 0; $k < @{$array2}; $k++)
	{
		next if ($array2->[$k]{ignore} == 1);

		if ($array2->[$k]{end} - $array2->[$k]{start} <= $TSS_MIN_LENGTH)
		{
			$array2->[$k]{ignore} = 1;
		}

		if ($array2->[$k]{strand} eq "+")
		{
			$array2->[$k]{TSS} = {
				start => $array2->[$k]{start} - int($TSS_MIN_LENGTH/2),
				end => $array2->[$k]{start} + int($TSS_MIN_LENGTH/2) - 1
			};
			$array2->[$k]{genebody} = {
				start => $array2->[$k]{start} + int($TSS_MIN_LENGTH),
				end => $array2->[$k]{end}
			};
		}
		else
		{
			$array2->[$k]{TSS} = {
				start => $array2->[$k]{end} - int($TSS_MIN_LENGTH/2),
				end => $array2->[$k]{end} + int($TSS_MIN_LENGTH/2) - 1
			};	

			$array2->[$k]{genebody} = {
				start => $array2->[$k]{start},
				end => $array2->[$k]{end} - int($TSS_MIN_LENGTH)
			};
		}
	}	
}

sub bsearch
{
	my $array = $_[0];
	my $start = $_[1];

	###warn "bsearch: array size is " . @array . " start is $start\n";

	my $min = 0;
	my $max = @{$array};
	my $mid;
	
	while ($min < $max)
	{
		$mid = int(($max + $min)/2);
		###warn "\tin while, peak is $array[$mid]{start} $array[$mid]{end} mid is $mid\n";

		if ($array->[$mid]{end} == $start)
		{
			return $mid;
		}
		elsif ($array->[$mid]{end} < $start)
		{
			$min = $mid + 1;
		}
		else 
		{
			$max = $mid - 1;
		}
	}

	if ($mid != 0 && $array->[$mid]{end} > $start)
	{
		$mid--;
	}
		
	return $mid;
}


