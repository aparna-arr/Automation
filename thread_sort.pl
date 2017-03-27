#!/usr/bin/perl
use strict; use warnings;
use Thread;
use Thread::Queue;

my ($bam_list, $num_threads) = @ARGV;
die "usage: <full path to list of .bam.gz> <number of threads>\n" unless @ARGV;

my $Q = Thread::Queue->new;

open(BAM, "<", $bam_list) or die "could not open $bam_list:$!\n";
my @bams;

while(<BAM>) {
	my $line = $_;
	chomp $line;

        my $cmd = "samtools sort -n $line -o $line.name";

	$Q->enqueue($cmd);
#	print $cmd . "\n"
}

close BAM;

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
