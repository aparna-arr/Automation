#!/usr/bin/env perl
use warnings;
use strict;

my (@input) = @ARGV;
die "usage: $0 <list of fastqc_data.txt files>
prints to STDOUT!
" unless @ARGV;

for (my $i = 0; $i < @input; $i++)
{
	open (TMP, "<", $input[$i]) or die "could not open $input[$i]: $!\n";

	my $start_parsing = 0;

	while (<TMP>)
	{
		my $line = $_;
		chomp $line;

		if ($start_parsing == 1 && $line !~ /^\#/)
		{
			if ($line =~ /^>>END_MODULE/)	
			{
				last;
			}

			my (@line_fields) = split(/\t/, $line);

			($line_fields[3]) = $line_fields[3] =~ /^([^()]+)\({0,1}/;
			print ">$line_fields[3]\n$line_fields[0]\n";
		}

		if ($line =~ /^>>Overrepresented/)
		{
			$start_parsing = 1;
		}		
	}

	close TMP;
}
