#!/bin/bash -l
# NOTE the -l flag!

# If you need any help, please email help@cse.ucdavis.edu

# Name of the job - You'll probably want to customize this.
#SBATCH -J brca1_rep1

# Standard out and Standard Error output files with the job number in the name.
#SBATCH -o brca1_rep1.output
#SBATCH -e brca1_rep1.output
#SBATCH --mail-type=ALL
#SBATCH --mail-user=arrajpurkar@ucdavis.edu

# no -n here, the user is expected to provide that on the command line.

# The useful part of your job goes below

# run one thread for each one the user asks the queue for
# hostname is just for debugging
hostname
export OMP_NUM_THREADS=$SLURM_NTASKS

#bowtie2 -x /home/arrajpur/bowtie2_index/mm9.fa -U [FASTA] -S [SAM]
#samtools view -bS [SAM] > [BAM]
#macs2 callpeak -t [BAM] -f BAM -g mm -n [FOLDER] -w

fastq=BRCA1_rep1.trim.fastq

sam=~/processing/sam/$fastq\.sam
bam=~/processing/bam/$fastq\.bam

bowtie2 -x /home/arrajpur/bowtie2_index/mm9 -U $fastq -S $sam
gzip $fastq
samtools view -bS $sam > $bam
