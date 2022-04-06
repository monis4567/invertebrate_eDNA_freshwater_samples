#!/bin/bash
#SBATCH --account=hologenomics         # Project Account
#SBATCH --partition=hologenomics 
#SBATCH --mem 16G
#SBATCH -c 1
#SBATCH -t 48:00:00
#SBATCH -J pa04C
#SBATCH -o stdout_pa04C.txt
#SBATCH -e stderr_pa04C.txt

cd $HOME/data
# get the date
DATE=$(date "+%y%m%d")
# make a prefix name
LOCAL_NCBI_DB_prefix="local_ncbi_copy"
# make a string that has the prefix name and the date
LOCAL_NCBI_DB=$(echo ""$LOCAL_NCBI_DB_prefix"_"$DATE"")

LOCAL_NCBI_DB_nodate=$(ls | grep "$LOCAL_NCBI_DB_prefix")

rm -rf "$LOCAL_NCBI_DB_nodate"
mkdir "$LOCAL_NCBI_DB"
cd "$LOCAL_NCBI_DB"
#load modules required
module purge
# you can check what module is available with the command:
# module avail
# But if you know that you want to look for 'blast' then instead try:
# module spider blast
# This will tell you which of the remote applications has any similarity 
# in naming with your search  
# Load the correct module

# Load perl before loading blast
module load perl/v5.28.1
#module load perl/v5.32.0
module load blast+/v2.12.0

# The older versions of blast+ might not be able to perform the remote search operation. 
# see this question : https://www.biostars.org/p/296360/
# wget https://github.com/jrherr/bioinformatics_scripts/blob/0ce2db576727fdaef012f50cfc28065f2727a5a5/perl_scripts/update_blastdb.pl
# chmod 755 update_blastdb.pl
update_blastdb.pl nt --timeout 500

