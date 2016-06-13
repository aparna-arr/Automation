#!/usr/bin/env perl
use warnings;
use strict;

my ($gtf, $conv) = @ARGV;
die "usage: <gtf file> <2 col: old\tnew conversion file>\n" unless @ARGV;

open (CONV, "<", $conv) or die "could not open $conv\n";

my %names;
while(<CONV>)
{
	my $line = $_;
	chomp $line;

	my ($old, $new) = split(/\t/, $line);
	$names{$old} = $new;
}

close CONV;

open (IN, "<", $gtf);

while (<IN>)
{
	my $line = $_;
	chomp $line;	
	my ($before, $name, $after) = $line =~ /^(.+gene_id \")(.+?)(\";\st.+)$/;
#	print "debug: [$line]\n";
#	print "debug: [$before] [$name] [$after]\n";
	if (!exists $names{$name})
	{
		warn  "[$name] does not have an equivalent!\n";
	}
	else 
	{
		print "$before" . $names{$name} . "$after\n";
	}
}

close IN;
