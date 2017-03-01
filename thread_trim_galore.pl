#!/usr/bin/perl
use strict; use warnings;
use Thread;
use Thread::Queue;

my ($fastq_list, $outdir, $num_threads) = @ARGV;
die "usage: <full path to list of .fastq.gz> <trim_galore outdir> <number of threads>\nUSE FOR PAIRED READS ONLY\n" unless @ARGV;

my $Q = Thread::Queue->new;

open(FASTQ, "<", $fastq_list) or die "could not open $fastq_list:$!\n";
my @fastqs;
my %paired_fastqs;
while(<FASTQ>) {
	my $line = $_;
	chomp $line;

	my ($basename, $read) = $line =~ /(.*)(read[12])/;

	if (($read eq "read1" || $read eq "read2") && $basename ne "") {
		push(@{$paired_fastqs{$basename}}, $line)
	}		
	else {
		die "unrecognized filename format [$line]\n";
	}
}

close FASTQ;

my $base_cmd = "trim_galore --fastqc -q 25 -o $outdir --paired ";
	
foreach my $base (keys %paired_fastqs) {
	if (@{$paired_fastqs{$base}} != 2) {
		warn "Error! Basename [$base] does not have 2 files. Skipping.\n";
		next;

	}
	my $cmd = $base_cmd . "$paired_fastqs{$base}[0] $paired_fastqs{$base}[1] ; ";
	$Q->enqueue($cmd);
}


my @threads;
for (my $i = 0; $i < $num_threads; $i++) {
	$threads[$i] = threads->create(\&worker, $i, $Q);
}

for (my $i = 0; $i < $num_threads; $i++) {
	$threads[$i]->join();
}

sub worker {
	my ($thread, $queue) = @_;
	my $thread_id = threads->tid;
	
	while ($queue->pending) {
		my $command = $queue->dequeue;
		system($command);
		#print "$thread_id: RUNNING $command\n";
	}
	return;
}
