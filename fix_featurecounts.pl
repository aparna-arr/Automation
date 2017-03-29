#!/usr/bin/env perl
use warnings;
use strict;

## Script that takes featureCounts per-bam outfiles and 
#compiles a proper outfile for all bams
#also outputs a summary
##

my ($out_dir, $gtffile, $outfile_name) = @ARGV;
die "usage: <FeatureCounts per bam outfile dir (filename has \"cell\")> <GTF file> <outfile basename>" unless @ARGV;

opendir(DIR, $out_dir) or die "could not open $out_dir:$!";
my (@files) = grep(/cell/, readdir(DIR));
close DIR;

my %counts_per_gene;
my %summary_per_status = (
        Unassigned_Ambiguity => {},
        Unassigned_NoFeatures => {},
        Unassigned_Secondary => {},
        Unassigned_Unmapped => {},
        Assigned => {}
);

@files = sort(@files);
my $header = join("\t", @files);
my $num_files = @files;
my $curr_index = 0;

foreach my $file (@files) {
    warn "on file $file\n";

    open(FP, "<", "$out_dir/$file") or die "could not open $file:$!";

    foreach my $status (%summary_per_status) {
        $summary_per_status{$status}{$file} = 0;
    }

    while(<FP>) {
        my $line = $_;
        chomp $line;
        my (@line_ar) = split(/\t/, $line);

        if (@line_ar < 3) {
            warn "Line < 3 [$line]\n";
            next;
        }

        if ($line_ar[1] =~ /^Assigned/) {

            if (exists($counts_per_gene{$line_ar[2]})) {
                $counts_per_gene{$line_ar[2]}[$curr_index]++;
            }
            else {
                @{$counts_per_gene{$line_ar[2]}} = (0)x$num_files;
                $counts_per_gene{$line_ar[2]}[$curr_index]++;
            }
        }

        if (!exists($summary_per_status{$line_ar[1]})) {
            die "Unaccounted for status: [" . $line_ar[1] . "]\n";
        }
        else {
            $summary_per_status{$line_ar[1]}{$file}++;
        }
        
    }

    close FP;
    $curr_index++;
}


my @out;
warn "constructing summary outstrings\n";
foreach my $status (sort keys %summary_per_status) {
    my $curr_str = "$status";
    foreach my $file (sort keys %{$summary_per_status{$status}}) {
        $curr_str .= "\t$summary_per_status{$status}{$file}";
    }
    push (@out,$curr_str);
}

warn "printing summary file\n";
open(OUT_SUM, ">", $outfile_name . ".summary") or die "could not open outfile $outfile_name.summary:$!";

print OUT_SUM "Status\t" . $header . "\n";

foreach my $out_line (@out) {
    print OUT_SUM $out_line . "\n";
}

close OUT_SUM;

open(OUT_COUNT, ">", $outfile_name . ".counts") or die "could not open outfile $outfile_name.counts:$!\n";

print OUT_COUNT "chr\tstart\tend\tname\tstrand\t" . $header . "\n";

open(GTF, "<", $gtffile) or die "could not open $gtffile:$!\n";

warn "processing GTF file & printing out\n";
while(<GTF>) {
    my $line = $_;
    chomp $line;

    next if $line =~ /^#/;
    my (@line_ar) = split(/\t/, $line);
    next if $line_ar[2] ne "gene";
    my ($id) = $line_ar[8] =~ /gene_id \"(.*?)\";/;

#    warn "gene id is $id\n";

    my $out_str = "$line_ar[0]\t$line_ar[3]\t$line_ar[4]\t$id\t$line_ar[6]";

    if (exists($counts_per_gene{$id})) {
        $out_str .=  "\t" . join("\t", @{$counts_per_gene{$id}});
    }
    else {
        $out_str .= "\t" . join("\t", (0)x$num_files);
    }

    print OUT_COUNT $out_str . "\n";
}

close GTF;
close OUT_COUNT;
warn "Done\n";
