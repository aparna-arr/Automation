#!/usr/bin/perl
use strict; use warnings;
use Thread;
use Thread::Queue;

my ($fastq_list, $num_threads) = @ARGV;
die "usage: <full path to list of .fastq.gz> <number of threads>\n" unless @ARGV;

my $Q = Thread::Queue->new;

open(FASTQ, "<", $fastq_list) or die "could not open $fastq_list:$!\n";
my @fastqs;

while(<FASTQ>) {
	my $line = $_;
	chomp $line;

	my ($fastq_name) = $line =~ /(.+).gz/;
	my $cmd = "gzip -d $line ; grep -A3 -P \"\@.*/1\$\" --no-group-separator $fastq_name > $fastq_name.read1 ; grep -A3 -P \"\@.*/2\$\" --no-group-separator $fastq_name > $fastq_name.read2; gzip $fastq_name; gzip $fastq_name.read1; gzip $fastq_name.read2;";
	$Q->enqueue($cmd);
#	print $cmd . "\n"
}

close FASTQ;

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
