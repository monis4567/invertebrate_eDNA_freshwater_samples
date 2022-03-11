#!/bin/bash
#SBATCH --account=hologenomics         # Project Account
#SBATCH --partition=hologenomics 
#SBATCH --mem 512M
#SBATCH -c 1
#SBATCH -t 1:00:00
#SBATCH -J 00C_uncomp_fastq
#SBATCH -o stdout_00C_uncomp_fastq.txt
#SBATCH -e stderr_00C_uncomp_fastq.txt

#load modules required
module purge
#start the bash script that iterates over compressed gz files
#Define the zipped novogene file
RWzipF="X204SC22012323-Z01-F001.zip"
# define input directory with novogen file 
INDR1="00A_raw_compressed_novogenefile"
# define output directory where the  unzipped novogene files are to be placed 
OUDR1="00B_raw_compressed_fastq.gz_files"
# define output directory where the unzipped 'fastq.gz' files are to be placed 
OUDR2="00C_uncompressed_fastq.gz_files"
#put present working directory in a variable
WD=$(pwd)

#WD="${REMDIR}"
REMDIR="${WD}"
#define inpout directory
INDIR01="00B_raw_compressed_fastq.gz_files/X204SC22012323-Z01-F001/raw_data"
INDIR02=$(echo ""${REMDIR}"/"${INDIR01}"")
# Remove any previous versions of the output directory, and make it again
rm -rf "${OUDR2}" 
mkdir "${OUDR2}"
# change dir to the dir that holds the fastq files
cd "$INDIR02"
# make a list that holds the names of the folders with the zipped fastq files
LSSMPL=$(ls | awk 'BEGIN { FS = "_" } ; {print $1"_"$2}' | sed '/Rawdata_Readme.pdf/q' | sed '$d')
#make the list of samples an array you can iterate over
declare -a SMPLARRAY=($LSSMPL)
#change back to the working dir
cd "$WD"
#iterate over samples
for smp in ${SMPLARRAY[@]}
do
	
	mkdir $WD/"${OUDR2}"/"${smp}"
	# define a path to each directory which have compressed fastq files inside
	PATH02=$(echo ""${INDIR02}"/"${smp}"")
	# navigate in to this directory
	cd "${PATH02}"
	#then iterate over files that has the ending : *.fq.gz
	for f in *.fq.gz
	do
		
		#and copy them to the output directory
		cp $f $WD/"${OUDR2}"/"${smp}"/.
		gunzip $WD/"${OUDR2}"/"${smp}"/"$f"
	done
done
