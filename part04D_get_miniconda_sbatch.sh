#!/bin/bash
#SBATCH --account=hologenomics         # Project Account
#SBATCH --partition=hologenomics 
#SBATCH --mem 16G
#SBATCH -c 1
#SBATCH -t 1:00:00
#SBATCH -J pa04D
#SBATCH -o stdout_pa04D.txt
#SBATCH -e stderr_pa04D.txt

cd $HOME
rm -rf miniconda3
cd $HOME/data

wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh
sleep 120s
chmod +x miniconda.sh
bash miniconda.sh -b
sleep 120s
# then navigate to $HOME
cd $HOME
# and then run
./miniconda3/bin/conda init bash
