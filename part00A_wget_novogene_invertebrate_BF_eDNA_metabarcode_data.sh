#!/bin/bash
#SBATCH --account=hologenomics         # Project Account
#SBATCH --partition=hologenomics 
#SBATCH --mem 512M
#SBATCH -c 1
#SBATCH -t 24:00:00
#SBATCH -J 00wget
#SBATCH -o stdout_01_wget.txt
#SBATCH -e stderr_01_wget.txt


wget https://englandaws-data1.s3-eu-west-1.amazonaws.com/out/CP2021121500088/X204SC22012323-Z01-F001/X204SC22012323-Z01-F001.zip

wget https://englandaws-data1.s3-eu-west-1.amazonaws.com/out/CP2021121500088/X204SC22012323-Z01-F001/checkSize.xls