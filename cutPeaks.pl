#!/usr/bin/env perl
use warnings;
use strict;

# This script intends to act like bedtools intersect -a -b but for -v
# So if you have
# -a ================
# -b ---    ---   --
# your output will be:
#       ####   ###  #

my ($peaks, $remove) = @ARGV;
die "usage: $0 <bedfile of peaks> <bedfile of things to remove>\n" unless @ARGV == 2;

open (PEAKS, "<", $peaks) or die "Could not open peakfile $peaks: $!\n";

my %peakChrs;

while(<PEAKS>)
{
	my $line = $_;
	chomp $line;
	if ($line =~ /^\s*$/)
	{
		next;
	}
	if ($line =~ /\#|track/) {
		print $line;
	}
	else {
		my (@lineAr) = split(/\t/, $line);
		push(@{$peakChrs{$lineAr[0]}}, {start => $lineAr[1], end => $lineAr[2], line => $line});
	}
}

close PEAKS;

#warn "done with peakfile\n";

open (REM, "<", $remove) or die "could not open remove file $remove: $!\n";

my @removefile;
my %removeChrs;
while(<REM>)
{
	my $line = $_;
	
	if ($line =~ /\#|track/) {
		next;
	}
	else {
		my (@lineAr) = split(/\t/, $line);
		push(@{$removeChrs{$lineAr[0]}}, {start => $lineAr[1], end => $lineAr[2], line => $line});
	}
				
}

close REM;

#warn "done with remove file\n";

my %results;
foreach my $chrom (sort keys %peakChrs)
{
	#warn "on chr $chrom\n";
	if (!exists($removeChrs{$chrom}))
	{	
		#warn "chr does not exist in removeChrs\n";
		for (my $i = 0; $i < @{$peakChrs{$chrom}}; $i++)
		{
#			push(@{$results{$chrom}}, $peakChrs{$chrom}[$i]{line});
			print "$peakChrs{$chrom}[$i]{line}\n";

		}

		next;
	}
	
	for (my $i = 0 ; $i < @{$peakChrs{$chrom}}; $i++)
	{
		#warn "on peak $i\n";
		# blacklist MUST be sorted
		my $start_index = bsearch($peakChrs{$chrom}[$i]{start}, $removeChrs{$chrom}, 0);
		my $end_index = bsearch($peakChrs{$chrom}[$i]{end}, $removeChrs{$chrom}, 1);
		
		my @splitpeaks;
	
		my $curr_start = $peakChrs{$chrom}[$i]{start};
		my $curr_end = $peakChrs{$chrom}[$i]{end};
		my $flag = 1;
	
		#warn "start index is $start_index end index is $end_index\n";
		for (my $j = $start_index; $j != $end_index; $j++)
		{
			if ($removeChrs{$chrom}[$j]{start} > $curr_start)
			{
				# =====
				#   --...
				if ($removeChrs{$chrom}[$j]{end} < $curr_end)
				{
					# ======
					#   --
					push(@splitpeaks, {start=>$curr_start, end=>$removeChrs{$chrom}[$j]{start}-1});
					$curr_start = $removeChrs{$chrom}[$j]{end}+1;
					$flag = 1;
				}
				else
				{
					# =====
					#   ----...
					if ($removeChrs{$chrom}[$j]{start} < $curr_end)
					{
						# =====
						#   -----
						push(@splitpeaks, {start=>$curr_start, end=>$removeChrs{$chrom}[$j]{start}-1});
						$flag = 0;
						last;
					}
					else
					{
						# =====
						#        -----
						push(@splitpeaks, {start=>$curr_start, end=>$curr_end});
						$flag = 0;
						last;
					}
				}
			}
			else
			{
				#      =====
				#   --......
				if ($removeChrs{$chrom}[$j]{end} > $curr_start)
				{
					#    =====
					#  -----... 
					if ($removeChrs{$chrom}[$j]{end} < $curr_end)
					{
						#    =====
						# ------   
						$curr_start = $removeChrs{$chrom}[$j]{end} + 1;
						$flag = 1;		
					}  
					else
					{
						#      =====
						#   ----------   
						$flag = 0;
						last;	
					}
				}
				else
				{	
					#       ======
					# ----     
					$flag = 1;
				}
			}		
		}
			
		if ($flag == 1)
		{
			push(@splitpeaks, {start=>$curr_start, end=>$curr_end});
		}

		for (my $k = 0; $k < @splitpeaks; $k++)
		{
			my (@lineAr) = split(/\t/, $peakChrs{$chrom}[$i]{line});
			my $linestr = "$chrom\t$splitpeaks[$k]{start}\t$splitpeaks[$k]{end}";
			for (my $m = 3; $m < @lineAr; $m++)
			{
				$linestr .= "\t$lineAr[$m]";
			}

			#warn "going to print [$linestr]\n";
			$linestr .= "\n";
			print $linestr;
		}

	}
	#warn "done with chr $chrom\n";
}

# my $start_index = bsearch($peakChrs{$chrom}[$i]{start}, $removeChrs{$chrom}, 0);
sub bsearch {
	#warn "in bsearch\n";
	my $value = $_[0];
	my @array = @{$_[1]};
	my $mode = $_[2];

	my $min = 0; 
	my $max = @array - 1;
	my $mid = 0; 

	while ($min <= $max)
	{
		#warn "mid is $mid\n";
		$mid = int( ($min + $max) / 2);
			
		if ($array[$mid]{end} < $value)
		{
			$min = $mid + 1;
		}
		elsif ($array[$mid]{start} > $value)
		{
			$max = $mid - 1;
		}
		else
		{	
			last;
		}	
	}
	
	if ($mode == 0 && $mid != 0 && $array[$mid]{start} > $value)
	{
		$mid--;
	}
	elsif ($mode == 1 && $mid < @array && $array[$mid]{start} < $value)
	{
		$mid++;
	}

	#warn "end of bsearch\n";
	return $mid;
}
