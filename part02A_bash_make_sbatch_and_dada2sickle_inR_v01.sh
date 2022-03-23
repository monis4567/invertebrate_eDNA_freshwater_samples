#!/bin/bash
# -*- coding: utf-8 -*-

#put present working directory in a variable
WD=$(pwd)
#define input directory
OUDIR01="01_demultiplex_filtered"
REMDIR="${WD}"
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
	
	# and modify the R file
	cat part02_dada2_sickle_inR_v03.r | \
	# and modify inside the file
	# modify the #set min length for the 'fastqPairedFilter' function
	sed -E "s;fpfml <- 100;fpfml <- 50;g" | \
	# modify the  #set length for sickle
	sed -E "s;lsick <- 100;lsick <- 50;g" | \
	# modify the #set quality for sickle
	sed -E "s;qsick <- 28;qsick <- 2;g" | \
	# and use sed to replace a txt string w the b library number
	sed -E "s/blibnumber/"${smp}"/g" > "${PATH01}"/"${BDR}"/part02_dada2_sickle_inR_v03_"${smp}".r
	#make the DADA2 sh script executable
	chmod 755 "${PATH01}"/"${BDR}"/part02_dada2_sickle_inR_v03_"${smp}".r
done


# Iteration loop over b library numbers
# to start slurm submission scripts for each b library number
#iterate over sequence of numbers
# but pad the number with zeroes: https://stackoverflow.com/questions/8789729/how-to-zero-pad-a-sequence-of-integers-in-bash-so-that-all-have-the-same-width

#iterate over samples
for smp in ${SMPLARRAY[@]}
 	do	
	#echo $fn
	#make a directory name for the NGS library
	BDR=$(echo ""${smp}"")
	#
	cd "${PATH01}"/"${BDR}"/
	#
	sbatch part02_sbatch_run_dada2_sickle_R_v01_"${smp}".sh
	#
	cd "$WD"
done