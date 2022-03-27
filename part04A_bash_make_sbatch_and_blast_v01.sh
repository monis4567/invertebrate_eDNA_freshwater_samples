#!/bin/bash
# -*- coding: utf-8 -*-

#put present working directory in a variable
WD=$(pwd)
#REMDIR="/groups/hologenomics/phq599/data/EBIODIV_2021jun25"
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
	
	#also replace in the slurm submission script
	cat part04_run_02blast_global_v01.sh | \
	# and use sed to replace a txt string w the b library number
	# replace "blibrarynumber"
	sed "s/blibnumber/"${smp}"/g" > "${PATH01}"/"${BDR}"/part04_run_02blast_global_v01_"${smp}".sh
	
# end iteration over sequence of numbers	
done

# Iteration loop over b library numbers
# to prepare slurm submission scripts for each b library number
#iterate over sequence of numbers
# but pad the number with zeroes: https://stackoverflow.com/questions/8789729/how-to-zero-pad-a-sequence-of-integers-in-bash-so-that-all-have-the-same-width

#iterate over samples
for smp in ${SMPLARRAY[@]}
 	do	
	#echo $fn
	#make a directory name for the NGS library
	BDR=$(echo ""${smp}"")
	
	# change directory to the subdirectory
	cd "${PATH01}"/"${BDR}"
	# start the slurm sbatch code
	sbatch part04_run_02blast_global_v01_"${smp}".sh
	# change directory to the working directory
	cd "${WD}"
# end iteration over sequence of numbers	
done


#Line to use for cancelling multiple jobs
#NJOBS=$(seq 30959042 30959048); for i in $NJOBS; do scancel $i; done
#
#
#