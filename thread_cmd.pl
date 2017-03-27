#!/usr/bin/perl
use strict; use warnings;
use Thread;
use Thread::Queue;

my ($cmd_list, $num_threads) = @ARGV;
die "usage: <full path to command list> <number of threads>\n" unless @ARGV;

my $Q = Thread::Queue->new;

open(CMD, "<", $cmd_list) or die "could not open $cmd_list:$!\n";

while(<CMD>) {
	my $line = $_;
	chomp $line;
        my $cmd = $line

	$Q->enqueue($cmd);
}

close CMD;

#$Q->end();

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
