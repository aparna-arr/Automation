#!/usr/bin/env perl
use warnings;
use strict;

my ($runName, $cmdFile, $outputDir, @inputs) = @ARGV;
die "usage: $0 <run base name> <file with command> <output dir> <list of input files to run on>
Command file in format:

bowtie2 -x /home/arrajpur/bowtie2_index/mm9 -U \$FILE

Where \$FILE is to be replaced by the inputs

This script generates a group of batch files that can be run in parallel
" unless @ARGV;

if ($runName eq "" || $cmdFile eq "" || $outputDir eq "" || @inputs == 0)
{
	die "Incorrect input! Check usage.\n";
}

open (CMD, "<", $cmdFile) or die "could not open $cmdFile\n";

my $genCmd = "";
while(<CMD>)
{
	my $line = $_;
	$genCmd .= $line;
}

close CMD;

for (my $i = 0; $i < @inputs; $i++)
{
	open(TMP, ">", "$outputDir/$runName\_$i.sh") or die "can't open outfile $i: $outputDir/$runName\_$i.sh : $!\n";

	my $cmd = $genCmd;	
	$cmd =~ s/\$FILE/$inputs[$i]/g;	
	print TMP "#!/bin/bash -l
# NOTE the -l flag!
#
# If you need any help, please email help\@cse.ucdavis.edu

# Name of the job - You'll probably want to customize this.
#SBATCH -J $runName\_$i

# Standard out and Standard Error output files with the job number in the name.
#SBATCH -o $runName\_$i.output
#SBATCH -e $runName\_$i.output
#SBATCH --mail-type=ALL
#SBATCH --mail-user=arrajpurkar\@ucdavis.edu

# no -n here, the user is expected to provide that on the command line.

# The useful part of your job goes below

# run one thread for each one the user asks the queue for
# hostname is just for debugging
hostname
export OMP_NUM_THREADS=\$SLURM_NTASKS

$cmd";
	close TMP;
}
