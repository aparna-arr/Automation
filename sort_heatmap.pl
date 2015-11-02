#!/usr/bin/env perl
use warnings;
use strict;

my ($heatmap, $option, $regionLen) = @ARGV;
die "usage: $0 <smoothed heatmap outfile> <option> <region length>\noptions:\n\tcenter: <REGION LENGTH> / 2 +- center of peak\n\tall: full peak\n\t2kb: +- <REGION LENGTH> around both + and - 2kb from peak center\n\tleft: +- <REGION LENGTH> around -2kb from peak center\n\tright: +- <REGION LENGTH> around +2kb from peak center\n" unless @ARGV == 3;

open(IN, "<", $heatmap) or die "Could not open $heatmap: $!\n";

my %heatmap;

while(<IN>) {
	my $line = $_;
	chomp $line;
	
	if ($line =~ /^peaks/) {
		$heatmap{header} = $line;
		next;
	}

	my (@array) = split(/\t/, $line);
	
	push(@{$heatmap{$array[0]}{ar}}, @array[1..@array-1]); # this notation is probably wrong
	$heatmap{$array[0]}{line} = $line;
}

close IN;
my %values;
foreach my $peak (keys %heatmap) {

	if ($peak eq "header") {
		next;
	}

	my @subarray = @{get_subarray($heatmap{$peak}{ar}, $option, $regionLen)};
	
	my $val = get_val(\@subarray);

#	push(@values, {peak => $peak, value => $val});
	$values{$peak} = $val;
}

#my (@sorted) = sort {$$a{"value"} <=> $$b{"value"}} @values;

print "$heatmap{header}\n";

#for (my $i = 0; $i < @sorted; $i++)

foreach (sort {$values{$b} <=> $values{$a}} (keys %values))
{
	print "$heatmap{$_}{line}\n";
}

## functions ##

sub get_subarray {
	my @array = @{$_[0]};
	my $option = $_[1];
	my $regionLen = $_[2];
	my @small;
	
	if ($option eq "center") {
		my $middleIndex = int(@array / 2);

		if ($middleIndex - int($regionLen / 2) < 0)
		{
			die "Your regionLen is too large for a centered sort! Your array is only of size " . @array . "\n";
		}

		my @small = @array[($middleIndex - int($regionLen / 2))..($middleIndex + int($regionLen / 2))];


#		for (my $i = 0; $i < @array; $i++)
#		{
#			print "array[i] orig $array[$i]\n";
#		}		

#		for (my $i = 0; $i < @small; $i++)
#		{
#			print "small[i] is $small[$i]\n";
#		}

		return \@small;
	}
	elsif ($option eq "all") {
		return \@array;
	}
	elsif ($option eq "2kb") {
		my $middleIndex = int(@array / 2);

		if ($middleIndex - 2000 - int($regionLen / 2) < 0)
		{
			die "Your array is of size " . @array . " which is too small for middle - 2kb - regionLen / 2!\n";
		}

		my $left_middle = $middleIndex - 2000;
		my $right_middle = $middleIndex + 2000;
		
		my @combo = @array[($left_middle - int($regionLen / 2))..($left_middle + int($regionLen / 2))];
		push(@combo, @array[($right_middle - int($regionLen / 2))..($right_middle + int($regionLen / 2))]); 
#		my @combo = push(@array[($left_middle - int($regionLen / 2))..($left_middle + int($regionLen / 2))], @array[($right_middle - int($regionLen / 2))..($right_middle + int($regionLen / 2))])  

		return \@combo;
	}
	elsif ($option eq "left") {
		my $middleIndex = int(@array / 2);

		if ($middleIndex - 2000 - int($regionLen / 2) < 0)
		{
			die "Your array is of size " . @array . " which is too small for middle - 2kb - regionLen / 2!\n";
		}

		my $left_middle = $middleIndex - 2000;

		my @left = @array[($left_middle - int($regionLen / 2))..($left_middle + int($regionLen / 2))];

		return \@left;
	}
	elsif ($option eq "right") {
		my $middleIndex = int(@array / 2);

		if ($middleIndex + 2000 + int($regionLen / 2) < 0)
		{
			die "Your array is of size " . @array . " which is too small for middle + 2kb + regionLen / 2!\n";
		}

		my $right_middle = $middleIndex + 2000;

		my @right = @array[($right_middle - int($regionLen / 2))..($right_middle + int($regionLen / 2))];

		return \@right;

	}
	else {
		die "Your option $option doesn't fit any of the choices!\n";
	}
}

sub get_val {
	my @array = @{$_[0]};


	my $value = 0;

	for (my $i = 0; $i < @array; $i++)
	{
#		print "array[i] is $array[$i]\n";
		$value += $array[$i];		
	}

	return $value;
}

