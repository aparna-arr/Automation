#!/usr/bin/env perl
use warnings;
use strict;
use Color::Rgb;

my $convert = new Color::Rgb(rgb_txt=>"/home/arrajpur/rgb.txt");

my (@mapwigs) = @ARGV;
die "usage: <mapwig1> <mapwig2> <...>\n*** NOTE: ALL MAPWIGS MUST CONTAIN SAME ERFS ***\n" unless @ARGV;


my %erf_hash;

foreach my $mapwig (@mapwigs) 
{
	print "on mapwig $mapwig\n";
	open(IN, "<", $mapwig) or die "could not open $mapwig: $!\n";

	while(<IN>)
	{
		my $line = $_;
		chomp $line;
		my ($chr, $start, $end, $val, $trash) = split(/\t/, $line);
		$erf_hash{"$chr-$start-$end"}{value} += $val;	
	}

	close IN;
}

my $min = 1000; # arbitrary
my $max = 0;
my $total = 0;

my @values;

foreach my $erf (keys %erf_hash)
{
	if ($erf_hash{$erf}{value} < $min)
	{
		$min = $erf_hash{$erf}{value};
	}	
	
	if ($erf_hash{$erf}{value} > $max)
	{
		$max = $erf_hash{$erf}{value};
	}

	push (@values, $erf_hash{$erf}{value});
	$total += $erf_hash{$erf}{value};
}

print "min is $min, max is $max\n";

@values = sort {$a <=> $b} @values;

my $range = $max - $min;

my $median_index = int(@values / 2);

my $first_index = int($median_index / 2);

my $third_index = $first_index + $median_index;

print "first is $first_index, median is $median_index, third is $third_index\n";
print "VALUE: first is $values[$first_index], median is $values[$median_index], third is $values[$third_index]\n";

my @rgb;

my $j = 0;
for (my $i = 0; $i <= 255; $i += 10)
{
#	$rgb[$j] = {r => $i, g => $i, b => 255};
#	$rgb[$j] = {r => 0, g => $i, b => 255 - $i};
	$rgb[$j] = {r => $i, g => $i, b => 255 - $i};
	$j++;
}

for (my $i = 0; $i <= 255; $i += 10)
{
#	$rgb[$j] = {r => 255, g => 255 - $i, b => 255 - $i};
#	$rgb[$j] = {r => $i, g => 255 - $i, b => 0};
	$rgb[$j] = {r => 255, g => 255 - $i , b => 0};
	$j++;
}

print "RGB: " . @rgb . "\n";

open (RGB, ">", "rgb.txt");
for (my $d = 0; $d < @rgb; $d++)
{
	print "RBG: [$rgb[$d]{r},$rgb[$d]{g},$rgb[$d]{b}]\n";

	my @array = ($rgb[$d]{r}, $rgb[$d]{g}, $rgb[$d]{b});
	my $hex = $convert->rgb2hex(@array);

	print RGB "<div class=\"foo\" style=\"background-color:\#$hex\"></div>\n";
}	
close RGB;

open (OUT, ">", "ERFs_genome_browser.bed");

print OUT "track name=\"ERFs\"itemRgb=\"On\"\n";
foreach my $erf (keys %erf_hash)
{

# simple index: BAD because of the eternal negative binomial curse
#	my $index = int( ( ($erf_hash{$erf}{value}  - $min )/ $range ) * (@rgb - 1));

	# find which quartile the value is in
	# find what % of the range of that quartile the value is in
	# assign index
	# this is probably statistically horrible but oh well

	# indicies in VALUES array
	my ($max_index, $min_index, $quarter);

	if ($erf_hash{$erf}{value} < $values[$first_index])
	{
		$max_index = $first_index - 1;
		$min_index = 0;
		$quarter = 1;
	}
	elsif ($erf_hash{$erf}{value} < $values[$median_index])
	{
		$max_index = $median_index - 1;
		$min_index = $first_index;
		$quarter = 2;
	}	
	elsif ($erf_hash{$erf}{value} < $values[$third_index])
	{
		$max_index = $third_index - 1;
		$min_index = $median_index;	
		$quarter = 3;
	}
	else {
		$max_index = @values - 1;
		$min_index = $third_index;
		$quarter = 4;
	}

	# rgb index
	my $index = int( ( ( $erf_hash{$erf}{value} - $values[$min_index] ) / ( $values[$max_index] - $values[$min_index] ) ) * (@rgb/4*$quarter - 1) );

#	warn "first [" . ( $erf_hash{$erf}{value} - $values[$min_index] ) . "] second [" . ( $values[$max_index] - $values[$min_index] ) . "] third [" . (@rgb/4*$quarter - 1)  . "]\n";
	
#	print "index is $index\n";

	my ($chr, $start, $end) = split (/-/, $erf);
#	warn "chr is $chr start is $start end is $end index is $index rgbr is $rgb[$index]{r} rgbg is $rgb[$index]{g} rgbb is $rgb[$index]{b}\n";

	print OUT "$chr\t$start\t$end\tERF\t" . ($index / @rgb * 100) . "\t+\t$start\t$start\t$rgb[$index]{r},$rgb[$index]{g},$rgb[$index]{b}\n"; 
}

close OUT;

