#!/usr/bin/perl
use strict; use warnings;
use Thread;
use Thread::Queue;

my ($acc_list, $num_threads) = @ARGV;
die "usage: <full path to accension list> <number of threads>\n" unless @ARGV;

my $Q = Thread::Queue->new;

open(ACC, "<", $acc_list) or die "could not open $acc_list:$!\n";

while(<ACC>) {
	my $line = $_;
	chomp $line;
	my $cmd = " ~/.aspera/connect/bin/ascp -QT -l 300m -i ~/.aspera/connect/etc/asperaweb_id_dsa.openssh era-fasp\@fasp.sra.ebi.ac.uk:$line .";

	$Q->enqueue($cmd);
}

close ACC;

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
