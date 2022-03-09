#!/bin/bash
#SBATCH --account=hologenomics         # Project Account
#SBATCH --partition=hologenomics 
#SBATCH --mem 512M
#SBATCH -c 1
#SBATCH -t 3:00:00
#SBATCH -J 00B_uncomp_raw
#SBATCH -o stdout_00B_uncomp_raw.txt
#SBATCH -e stderr_00B_uncomp_raw.txt

#load modules required
module purge

#start the bash script that iterates over compressed gz files
#srun part00A_bash_gunzip_fastqfiles_Ole_Akvarie.sh


#get working directory and place in variable
WD=$(pwd)


RWzipF="X204SC22012323-Z01-F001.zip"
# define input directory with 'fastq.gz' files 
INDR1="00A_raw_zipped_fastq.gz_files"
# define output directory where the  unzipped 'fastq.gz' files are to be placed 
OUDR1="00B_raw_decompressed_fastq.gz_files"

rm -rf "${INDR1}" 
mkdir "${INDR1}"

rm -rf "${OUDR1}" 
mkdir "${OUDR1}"

cp "$WD"/"${RWzipF}" "$WD"/"${INDR1}"/.
cd "${WD}"/"${OUDR1}"
unzip "${WD}"/"${INDR1}"/"${RWzipF}" 


# # remove the previous version of the output directory
# rm -rf "${OUDR1}"
# # make a new version of the output directory
# mkdir -p "${OUDR1}"
# # In order to keep the original gz files you can gunzip them to a different directory:
# # See this website: https://superuser.com/questions/139419/how-do-i-gunzip-to-a-different-destination-directory
# # gunzip -c file.gz > /THERE/file

# # Iterate over uncompressed files
# for f in "${WD}"/"${INDR1}"/b0*_R*
# do
# 	#echo $f
# 	#modify the filename with the sed command, to delete the end of the file name
# 	nf=$(echo $f | sed -E 's/^.*[/]//g' | sed 's/.gz//g')
# 	echo $nf
# 	#modify the path name with the sed command, to delete the last sub directory
# 	SWD=$(echo $WD | sed -E 's;(.*)\\/.*$;\1;g')
# 	#echo ""${SWD}"/"${OUDR1}""
# 	#uncompress the gz files
# 	gunzip -c "$f" > ""${SWD}"/"${OUDR1}""/$nf
# 	# and character modify the uncompressed file
# 	chmod 755 ""${SWD}"/"${OUDR1}""/$nf
# done