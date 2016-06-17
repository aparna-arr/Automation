#!/usr/bin/env perl
use warnings;
use strict;
use Thread;
use Thread::Queue;

# 
# shuffle_user_friendly.pl
#
# Description: 
# 	performs simulation of peak intersects on genome
# 	Shuffles one peak set on same-chromosome
# 	with exclusion of gaps set by user
# 	and intersects with N other peaksets
# 	to give the "random" incidence of bp intersection
#
# Features:
# 	Threading
# 	Actual user input validation
# 	Tests command before running threads
# 	Many more error messages than I usually give
#	
# Author: Aparna Rajpurkar (June 2016)
# Email: aparna.arr@gmail.com
#
# NO GUARANTEE IS MADE. 
#


## GLOBALS ##

my $usage = "
Shuffle Genome: user friendly

usage: $0 
		--excl <gaps file> 
		--chrlen <chr length file> 
		--tmpdir <tmp directory> 
		--reps <number of shuffles> 
		--threads <number of threads>
		--shuffle <file to be shuffled> 
		--intersect <file to be intersected 1> <file 2> <...> 
		--outfiles <outfile name 1> <outfile2> <...>

* All options above are required! 
* All options are space seperated 
* \# outfiles MUST equal \# files to be intersected!
";

## ##

main();

## SUBROUTINES ##

sub main {
	my (@cli_args) = @ARGV;
	die $usage unless @ARGV >= 14;

	my %opts = (
		excl => '',
		chr_len => '',
		shuffle => '',
		tmpdir => '',
		intersect => [],
		out => [],
		reps => 0,
		threads => 0
	);

	parse_options(\@cli_args, \%opts);
	validate(\%opts);
	print_opts(\%opts);
	run_threads(\%opts);
}

sub print_opts {
	my $opts_ref = $_[0];
	
	my $str = "\nYour opts are:
--excl: $opts_ref->{excl}
--chrlen: $opts_ref->{chr_len}
--tmpdir: $opts_ref->{tmpdir}
--reps: $opts_ref->{reps}
--threads: $opts_ref->{threads}
--shuffle: $opts_ref->{shuffle}
--intersect:"; 

	for (my $i = 0; $i < @{$opts_ref->{intersect}}; $i++) {
		$str .= " $opts_ref->{intersect}[$i]";
	}

	$str .= "\n";
	$str .= "--outfiles:";

	for (my $i = 0; $i < @{$opts_ref->{out}}; $i++) {
		$str .= " $opts_ref->{out}[$i]";
	}

	$str .= "\n";
	
	warn $str;
}

sub run_threads {
	my $opts_ref = $_[0];

	my $Q = new Thread::Queue;

	for (my $i = 0; $i < $opts_ref->{reps}; $i++) {
		my $cmd = "bedtools shuffle -chrom -excl $opts_ref->{excl} -i $opts_ref->{shuffle} -g $opts_ref->{chr_len} > $opts_ref->{tmpdir}/tmp_$i;";
		for (my $j = 0; $j < @{$opts_ref->{intersect}}; $j++) {
			$cmd .= "bedtools intersect -a $opts_ref->{tmpdir}/tmp_$i -b $opts_ref->{intersect}[$j] | awk '{print \$3 - \$2}' | awk '{sum+=\$1} END {print sum}' >> $opts_ref->{out}[$j];";
		}

		$cmd .= " rm $opts_ref->{tmpdir}/tmp_$i;";

		if ($i == 0) {
			warn "\nCOMMAND CHECK\n";
			warn "Command is :\n[$cmd]\n";
			warn "Running command\n";
	
			system($cmd);
	
			warn "Checking outfile\n";
	
			open(TEST, "<", $opts_ref->{out}[0]) or warn "ERROR: Could not open test outfile [" . $opts_ref->{out}[0] . "] : something went wrong!" && exit(1);
			my $line = <TEST>;
			close(TEST);

			if ($line !~ /^\d+$/) {
				warn "ERROR: First line of file is [$line]: something went wrong!";
				exit(1);
			}
			system("rm $opts_ref->{out}[0]");	
			warn "Test command was successful\n";
		}
		
		$Q->enqueue($cmd);
	} 
	
	$Q->end;

	my @threads;

	warn "\nRunning threads\n";	
	for (my $i = 0; $i < $opts_ref->{threads}; $i++) {
		$threads[$i] = threads->create(\&worker, $i, $Q);
	}

	for (my $i = 0; $i < $opts_ref->{threads}; $i++) {
		$threads[$i]->join();
	}
}

sub worker {
	my ($thread, $queue) = @_;
	my $thread_id = threads->tid;
	
	while($queue->pending) {
		my $command = $queue->dequeue;
		system($command);
	}

	return;
}

sub validate {
	my $opts_ref = $_[0];
	
	if ($opts_ref->{reps} == 0) {
		warn "ERROR: [--reps] must be > 0! Yours is [". $opts_ref->{reps} . "]\n" . $usage;
		exit(1);
	}

	if ($opts_ref->{threads} == 0) {
		warn "ERROR: [--threads] must be > 0! Yours is [". $opts_ref->{threads} . "]\n" . $usage;
		exit(1);
	}

	if (! -f $opts_ref->{excl}) {
		warn "ERROR: File arg [" . $opts_ref->{excl} . "] to [--excl] does not exist!\n" . $usage;
		exit(1);
	}
 
	if (! -f $opts_ref->{chr_len}) {
		warn "ERROR: File arg [" . $opts_ref->{chr_len} . "] to [--chrlen] does not exist!\n" . $usage;
		exit(1);
	} 

	if (! -d $opts_ref->{tmpdir}) {
		warn "ERROR: Dir arg [" . $opts_ref->{tmpdir} . "] to [--tmpdir] does not exist!\n" . $usage;
		exit(1);
	} 

	for (my $i =0; $i < @{$opts_ref->{intersect}}; $i++) {
		if (! -f $opts_ref->{intersect}[$i]) {
			warn "ERROR: File arg [" . $opts_ref->{intersect}[$i] . "] to [--intersect] does not exist!\n" . $usage;
			exit(1);

		}
	}
	
}

sub parse_options {
	my @cli = @{$_[0]};
	my $options = $_[1];

	for (my $i = 0; $i < @cli; $i++) {
#		warn "on opt [" . $cli[$i] . "], i is $i\n";
		if ($cli[$i] =~ /^--/)
		{
			if ($cli[$i] eq "--excl") {
				if ($i != @cli - 1 && $cli[$i+1] !~ /^--/) {
					$options->{excl} = $cli[$i+1];
					$i++;
				}
				else {	
					warn "ERROR: option --excl requires a file name argument!\n" . $usage;
					exit(1);
				}	
			}
			elsif ($cli[$i] eq "--chrlen") {
				if ($i != @cli - 1 && $cli[$i+1] !~ /^--/) {
					$options->{chr_len} = $cli[$i+1];
					$i++;
				}
				else {	
					warn "ERROR: option --chrlen requires a file name argument!\n" . $usage;
					exit(1);
				}	

			}
			elsif ($cli[$i] eq "--tmpdir") {
				if ($i != @cli - 1 && $cli[$i+1] !~ /^--/) {
					$options->{tmpdir} = $cli[$i+1];
					$i++;
				}
				else {	
					warn "ERROR: option --tmpdir requires a dir name argument!\n" . $usage;
					exit(1);
				}	

			}
			elsif ($cli[$i] eq "--reps") {
				if ($i != @cli - 1 && $cli[$i+1] =~ /^\d+$/) {
					$options->{reps} = $cli[$i+1];
					$i++;
				}
				else {	
					warn "ERROR: option --reps requires an INT argument!\n" . $usage;
					exit(1);
				}	

			}
			elsif ($cli[$i] eq "--threads") {
				if ($i != @cli - 1 && $cli[$i+1] =~ /^\d+$/) {
					$options->{threads} = $cli[$i+1];
					$i++;
				}
				else {	
					warn "ERROR: option --threads requires an INT argument!\n" . $usage;
					exit(1);
				}	

			}
			elsif ($cli[$i] eq "--shuffle") {
				if ($i != @cli - 1 && $cli[$i+1] !~ /^--/) {
					$options->{shuffle} = $cli[$i+1];
					$i++;
				}
				else {	
					warn "ERROR: option --shuffle requires a dir name argument!\n" . $usage;
					exit(1);
				}	
		
			}
			elsif ($cli[$i] eq "--intersect") {
				while($i < @cli - 1 && $cli[$i+1] !~ /^--/)
				{
					$i++;
					push(@{$options->{intersect}}, $cli[$i]);
				}

				if (@{$options->{intersect}} == 0) {
					warn "ERROR: option --intersect requires one or more filenames as argument!\n" . $usage;
				}

			}		
			elsif ($cli[$i] eq "--outfiles") {
				while($i < @cli - 1 && $cli[$i+1] !~ /^--/)
				{
					$i++;
					push(@{$options->{out}}, $cli[$i]);
				}
				
				if (@{$options->{out}} == 0) {
					warn "ERROR: option --outfiles requires one or more filenames as argument!\n" . $usage;
				}
			}
		} #if
		else {
			warn "ERROR: unrecognized option [" . $cli[$i] . "]\n" . $usage;	
			exit(1);
		} #else
	} # for

	if (@{$options->{out}} != @{$options->{intersect}}) {
		warn "ERROR: intersect files and outfiles must be equal in number!\n" . $usage;
		exit(1);
	}
}

## ##
