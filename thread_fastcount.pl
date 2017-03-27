#!/usr/bin/perl
use strict; use warnings;
use Thread;
use Thread::Queue;

my ($bam_list, $out, $num_threads) = @ARGV;
die "usage: <full path to list of .bam> <outfile basename> <number of threads>\n" unless @ARGV;

my $Q = Thread::Queue->new;

open(BAM, "<", $bam_list) or die "could not open $bam_list:$!\n";
my @bams;

while(<BAM>) {
	my $line = $_;
	chomp $line;
	push(@bams,$line)
}

close BAM;

my $count = 0;
my $outfile_count = 1;
my $files_per_thread = int(@bams/$num_threads);
my $cmd = "python3 FastCount.py gtffile $out\_0 ";
	
for (my $i = 0; $i < @bams; $i++) {
	if ($count >= $files_per_thread) {
                $outfile_count++;
		$Q->enqueue($cmd);
#		print $cmd . "\n";
                my $cmd = "python3 FastCount.py gtffile $out\_$outfile_count ";
		$count = 0;
	}

	$cmd .= "$bams[$i] ";
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
