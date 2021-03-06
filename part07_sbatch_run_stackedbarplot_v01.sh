#!/bin/bash
#SBATCH --account=hologenomics         # Project Account
#SBATCH --partition=hologenomics 
#SBATCH --mem 256G
#SBATCH -c 2
#SBATCH -t 4:00:00
#SBATCH -J p07_blibnumber
#SBATCH -o stdout_pa07_blibnumber.txt
#SBATCH -e stderr_pa07_blibnumber.txt

##source activate YOUR_CONDA_ENV
##source /com/extra/R/3.5.0/load.sh
#load modules required
module purge
#copy the outs table input file needed for the stacked bar plots
#cp DADA2_nochim.table part03_DADA2_nochim.table.blibnumber.txt
# the 'ggpubr' package for R requires R/v3.6.1
# you will need to install the 'ggpubr' package  on your remote directory before you can run this R code
# in July-2021 dada2 will only install in R v4.0.2. with the aid from "BiocManager"
# ## https://www.bioconductor.org/packages/release/bioc/html/dada2.html
module load R/v4.0.2

WD=$(pwd) 
cat part07_stackedbarplots_per_group_v01.r  | \
 sed "s;present_working_directory;$WD;g" > part07_stackedbarplots_per_group_v02.r
chmod 755 part07_stackedbarplots_per_group_v02.r
#chmod 755 part07_stackedbarplots_w_color_per_group_R05.r
#srun part07_stackedbarplots_w_color_per_group_R05.r
#srun part07_stackedbarplots_per_group_blibnumber_v01.r
srun part07_stackedbarplots_per_group_v02.r

#for fn in $(seq -f "%03g" 9 16);do echo "b0"${fn}"";cd ./01_demultiplex_filtered/b"${fn}"/; rm *part07*;cd /groups/hologenomics/phq599/data/EBIODIV_2021jun25;done

# cut to get replicate sections in the 'DADA2_nochim.table'
# as the full file is to large to handle in R on the HPC server 
# cut -f1,2-71 DADA2_nochim.table > DADA2_nochim.table_repl1.txt
# cut -f1,72-140 DADA2_nochim.table > DADA2_nochim.table_repl2.txt 
# cut -f1,141-208 DADA2_nochim.table > DADA2_nochim.table_repl3.txt 
# cut -f1,209-278 DADA2_nochim.table > DADA2_nochim.table_repl4.txt 

# cut -f1,2-140 DADA2_nochim.table > DADA2_nochim.table_repl1and2.txt
