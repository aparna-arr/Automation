#!/bin/bash -l
# NOTE the -l flag!

# If you need any help, please email help@cse.ucdavis.edu

# Name of the job - You'll probably want to customize this.
#SBATCH -J tophat1

# Standard out and Standard Error output files with the job number in the name.
#SBATCH -o tophat1.output
#SBATCH -e tophat1.output
#SBATCH --mail-type=ALL
#SBATCH --mail-user=arrajpurkar@ucdavis.edu

# no -n here, the user is expected to provide that on the command line.

# The useful part of your job goes below

# run one thread for each one the user asks the queue for
# hostname is just for debugging
hostname
export OMP_NUM_THREADS=$SLURM_NTASKS

tophat ~/bowtie2_index/mm9 ~/raw-data/GSE43504/RNAseq/HU_rep1/SRR648793.fastq
