#!/bin/bash
#SBATCH --account=hologenomics         # Project Account
#SBATCH --partition=hologenomics 
#SBATCH --mem 16G
#SBATCH -c 8
#SBATCH -t 48:00:00
#SBATCH -J pa02_dada2_sickle_blibnumber
#SBATCH -o stdout_pa02_sickle_blibnumber.txt
#SBATCH -e stderr_pa02_sickle_blibnumber.txt


#get present working directory and put it in a variable
WD=$(pwd)
#change directory to where previously attempted filtered files have been saved
cd DADA2_AS
#remove any previous output directories generated by the r-script you are about to run
rm -rf filtered
#change back to the working directory
cd "$WD"
#change directory to where previously attempted filtered files have been saved
cd DADA2_SS
#remove any previous output directories generated by the r-script you are about to run
rm -rf filtered
#change back to the working directory
cd "$WD"
#remove any previous versions of sickle
rm -rf sickle*
#copy sickle master
#cp /groups/hologenomics/phq599/data/software/sickle-master.tar.gz .
cp /groups/hologenomics/phq599/data/software/sickle_master.tar.gz .
#uncompress the tar.gz file
tar -zxf sickle_master.tar.gz

cd sickle_master
chmod 755 sickle

cd "$WD"
##source activate YOUR_CONDA_ENV
##source /com/extra/R/3.5.0/load.sh
#load modules required
module purge
module load python/v2.7.12
module load cutadapt/v1.11
module load vsearch/v2.8.0

# the 'dada2' package for R requires R v3.4
# the 'dada2' package for R requires R v4.0.2 - in July-2021 it requires R v4.0.2

#module load R/v3.4.3
module load R/v4.0.2

# start the job with sbatch
#srun part02_dada2_sickle_v2_AMRH_AL_v02.r
srun part02_dada2_sickle_inR_v03_blibnumber.r
#	 part02_dada2_sickle_inR_v03.r