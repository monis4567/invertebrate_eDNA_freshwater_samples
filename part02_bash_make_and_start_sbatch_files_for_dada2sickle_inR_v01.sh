#!/bin/bash
# -*- coding: utf-8 -*-

#put present working directory in a variable
WD=$(pwd)
REMDIR="${WD}"
#define input directory
OUDIR01="01_demultiplex_filtered"

#define path for b_library numbers
PATH01=$(echo ""${REMDIR}"/"${OUDIR01}"")

# #prepare paths to files, and make a line with primer set and number of nucleotide overlap between paired end sequencing
# Iteration loop over b library numbers
# to prepare slurm submission scripts for each b library number
#iterate over sequence of numbers
# but pad the number with zeroes: https://stackoverflow.com/questions/8789729/how-to-zero-pad-a-sequence-of-integers-in-bash-so-that-all-have-the-same-width
cd "$PATH01"
# make a list that holds the names of the fastq files
LSSMPL=$(ls | uniq)
#make the list of samples an array you can iterate over
declare -a SMPLARRAY=($LSSMPL)
	
#change back to the working dir
cd "$WD"

# rm stdout_pa01A.txt
# touch "$WD"/stdout_pa01A.txt
# iconv -f UTF-8 -t UTF-8 "$WD"/stdout_pa01A.txt

#iterate over samples
for smp in ${SMPLARRAY[@]}
do	
	#echo $fn
	#make a directory name for the NGS library
	BDR=$(echo ""${smp}"")
	# write the contents with cat
	cat part02_sbatch_run_dada2_sickle_R_v01.sh | \
	# and use sed to replace a txt string w the b library number
	sed "s/blibnumber/"${smp}"/g" > "${PATH01}"/"${BDR}"/part02_sbatch_run_dada2_sickle_R_v01_"${smp}".sh
	#make the DADA2 sh script executable
	chmod 755 "${PATH01}"/"${BDR}"/part02_sbatch_run_dada2_sickle_R_v01_b"${smp}".sh	
done
