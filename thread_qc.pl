#!/usr/bin/perl
use strict; use warnings;
use Thread;
use Thread::Queue;

my ($fastq_list, $outdir, $num_threads) = @ARGV;
die "usage: <full path to list of .fastq.gz> <fastqc outdir> <number of threads>\n" unless @ARGV;

my $Q = Thread::Queue->new;

open(FASTQ, "<", $fastq_list) or die "could not open $fastq_list:$!\n";
my @fastqs;

while(<FASTQ>) {
	my $line = $_;
	chomp $line;
	push(@fastqs,$line)
}

close FASTQ;

my $count = 0;
my $files_per_thread = int(@fastqs/$num_threads);
my $cmd = "fastqc -o $outdir --noextract ";
	
for (my $i = 0; $i < @fastqs; $i++) {
	if ($count >= $files_per_thread) {
		$Q->enqueue($cmd);
#		print $cmd . "\n";
		$cmd = "fastqc -o $outdir --noextract ";
		$count = 0;
	}

	$cmd .= "$fastqs[$i] ";
	$count++;
}

$Q->enqueue($cmd) if $count != 0;

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
