#!/bin/bash
# -*- coding: utf-8 -*-

# Important. This bash code makes use of the gunzip files resulting from the NGS sequencing
# A list of the gunzip files is needed for the iterations below, as the loop over the numbers 
# then needs the gunzip file names to make lists of the files

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

INDIR02=$(echo ""${WD}"/"${OUDR2}"")
#define output directory
OUDIR03="01_demultiplex_filtered"
#Make a new output file directory
rm -rf "$OUDIR03"
mkdir "$OUDIR03"
PATH01=$(echo ""${WD}"/"${OUDIR03}"")
#_______________________________________________________________________________________________________________________
# Primers are adopted from :	Elbrecht, V., & Leese, F. (2017). Validation and development of COI metabarcoding primers for freshwater macroinvertebrate bioassessment. Frontiers in Environmental Science, 5(11), 1–11. https://doi.org/10.3389/fenvs.2017.00011. 
# BF1	ACWGGWTGRACWGTNTAYCC
# BR1	ARYATDGTRATDGCHCCDGC
PRIMSET_BF1BR1="ACWGGWTGRACWGTNTAYCC ARYATDGTRATDGCHCCDGC" #BF1BR1 primer set
# This metabarcode sequencing setup used
TAGS_BF1BR1="part01C_tag01_96_BF1BR1.txt"
# Prepare the '.txt' files with list of tags like this. Notice that the tags are repeated twice, as you have used
# twin tags (also known as  paired tags)
# Also notice the name if the sample does not include any points, and the underscores used makes the sample names
# equal 3 columns, one for the sample, one for primerset and one for the tag number
# Do not introduce additional underscores in the sample  names, or in the primerset names, as this will influence
# whether the demulitplex step with DADA2 is able to work
# The first column denotes your sample names you want associated with the tags, 
# the second and third
# column denotes your tags used in combination. Note that since this NGS data file has been 
# prepared to have matching tags in both F- and R- primer the second and third column 
# match each other

# IMPORTANT ! 
# This tags.txt file must have a an end-of-line character at the end of the very
# last line of tags.
# If this last end-of-line is not included the 'dada2_demultiplexing_v2.sh' part will not take this
# last tag combination into consideration. Also. If you add to many unnecessary end-of-lines at the end
# the 'dada2_demultiplexing_v2.sh' code will start assigning NGS reads to non-existing tags. In other
# words you need exactly one end-of-line character added after the very last line of tags.
# You can check that your 'tags.txt' file has this extra end-of-line by inspecting the 
# 'tags.txt'
# file in a text-editor. You should see the last line with tags having a number in the text-editor. 
# You should also be able to see that the next line also is assigned a number in the text-editor 
# margin. But also note that there are no more empty lines afterwards.

# Example of the tag list file: "part01B_tag01_96_BF1BR1.txt"
#_______________________________________________________________________________________________________________________

# ID006_BF1_tag01	AACAAC	AACAAC
# ID007_BF1_tag02	AACCGA	AACCGA
# ID008_BF1_tag03	CCGGAA	CCGGAA
# ID009_BF1_tag04	AGTGTT	AGTGTT
# ID010_BF1_tag05	CCGCTG	CCGCTG
# ID011_BF1_tag06	AACGCG	AACGCG
# ID012_BF1_tag07	GGCTAC	GGCTAC
# ID013_BF1_tag08	TTCTCG	TTCTCG
# ID014_BF1_tag09	TCACTC	TCACTC
# ID015_BF1_tag10	GAACTA	GAACTA
# ID016_BF1_tag11	CCGTCC	CCGTCC
# ID017_BF1_tag12	AAGACA	AAGACA
# ID018_BF1_tag13	CGTGCG	CGTGCG
# ID019_BF1_tag14	GGTAAG	GGTAAG
# ID020_BF1_tag15	ATAATT	ATAATT
# ID021_BF1_tag16	CGTCAC	CGTCAC
# ID022_BF1_tag17	TTGAGT	TTGAGT
# ...

#_______________________________________________________________________________________________________________________


# #prepare paths to files, and make a line with primer set and number of nucleotide overlap between paired end sequencing
# Iteration loop for the MiFiU primerset
#iterate over sequence of numbers
# but pad the number with zeroes: https://stackoverflow.com/questions/8789729/how-to-zero-pad-a-sequence-of-integers-in-bash-so-that-all-have-the-same-width
# do this for 009 to 012 for the MiFiU primerset


# change directory to the dir that holds the fastq files
cd "$INDIR02"
# make a list that holds the names of the libraries
LSSMPL=$(ls | awk 'BEGIN { FS = "_" } ; {print $1"_"$2}' | uniq)

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
	#define a directory name for the NGS library
	BDR=$(echo "b"${smp}"")
	#PATH01=$(echo ""${INDIR02}"/"${smp}"")
 	PATH02=$(echo ""${INDIR02}"/"${smp}"")
	#echo $fn
	FASTQF01=$(ls "${PATH02}" | grep "$smp" | grep 'L1_1' | sed -E 's/\.gz//g')
	#echo "$FASTQF01"
	FASTQF02=$(ls "${PATH02}" | grep "$smp" | grep 'L1_2' | sed -E 's/\.gz//g')
	#echo "$FASTQF02"
	# make an output file name with the number iterated over
	OUTLSTF01=$(echo "part01A_batch_file_b"${smp}".list")
	#make a directory for the NGS library
	rm -rf "${PATH01}"/"${BDR}"
	mkdir -p "${PATH01}"/"${BDR}"
	# put varaibles together and write the the line to a file, notice the number of nucleotide overlapping requested
	# also notice the new-line at the end of the line (i.e. after the number of nucleotides needed to be overlapping)
	# that includes all variables, this is needed for the demultiplexing part
	# later on. Without this new-line the demultiplexing part will not work
echo ""${PATH02}"/"${FASTQF01}" "${PATH02}"/"${FASTQF02}" "${TAGS_BF1BR1}" "${PRIMSET_BF1BR1}" 5
" > "${PATH01}"/"${BDR}"/"${OUTLSTF01}"
	# copy tags file into the b000 directory
	cat "${TAGS_BF1BR1}" | \
	  # replace the odd characters
            # https://unix.stackexchange.com/questions/381230/how-can-i-remove-the-bom-from-a-utf-8-file
            LC_ALL=C sed 's/\xEF\xBB\xBF//g' | \
            # replace the odd characters : https://superuser.com/questions/207207/how-can-i-delete-u200b-zero-width-space-using-sed
            LC_ALL=C sed 's/\xe2\x80\x8b//g' > "${PATH01}"/"${BDR}"/"${TAGS_BF1BR1}"
#end iteration over numbers
done


#_______________________________________________________________________________________________________________________

# To make slurm submission scripts inside each directory where tags files and batch files are placed
# Iterate over sequence numbers
# but pad the number with zeroes: https://stackoverflow.com/questions/8789729/how-to-zero-pad-a-sequence-of-integers-in-bash-so-that-all-have-the-same-width
#iterate over samples
for smp in ${SMPLARRAY[@]}
 	do
#make a directory name for the NGS library
	BDR=$(echo "b"${smp}"")
	# now print the slurm submission sbatch file, that you will use to submit the slurm run
printf "#!/bin/bash
#SBATCH --account=hologenomics         # Project Account
#SBATCH --partition=hologenomics 
#SBATCH --mem 4G
#SBATCH -c 1
#SBATCH -t 4:00:00
#SBATCH -J pa01B_demulti_b"${smp}"
#SBATCH -o stdout_pa01B_demulplex_b"${smp}".txt
#SBATCH -e stderr_pa01B_demulplex_b"${smp}".txt


## Activating the shell script: 'part01B_dada2_demultiplexing_v3_b"${smp}".sh  
## will call upon two additional files as input files for the demultiplex process.
## In this case these files are :
## "part01A_batch_file_b"${smp}".list"
## and
## part01B_tags.txt
## Make sure these files also are available in the same directory as where you place
## the file 'part01B_dada2_demultiplexing_v3_b"${smp}".sh'
## Equally important ! Also make sure that these two files hold :
## I) The right path to the correctt input files - i.e. the raw NGS read
## II) The correct filename for the lsit of matching tags and names of samples
## III) The correct metabarcode primers you used originally for the tagged PCR
## The shell scrip you are about to activate with this slurm submission code will not work if these
## pieces of information are not matching

##source activate YOUR_CONDA_ENV # if you are using a conda environment at AU , not at UCPH
## Instead on HPC at UCPH load the required modules
module load python/v2.7.12
module load cutadapt/v1.11
module load vsearch/v2.8.0

#run the shell script
# notice the use of the slurm command 'srun'
srun part01B_dada2_demultiplexing_v3_b"${smp}".sh" > "${PATH01}"/"${BDR}"/part01B_sbatch_run_dada2_demultiplexing_v3_b"${smp}".sh

#> "${OUDIR01}"/part01B_dada2_demultiplexing_v3_b"${fn}".sh

#end iteration over sequence of numbers
done
# 
#_______________________________________________________________________________________________________________________



#_______________________________________________________________________________________________________________________

# To make DADA2 demultiplexing sh scripts
# Iterate over sequence numbers
# but pad the number with zeroes: https://stackoverflow.com/questions/8789729/how-to-zero-pad-a-sequence-of-integers-in-bash-so-that-all-have-the-same-width
#iterate over samples
for smp in ${SMPLARRAY[@]}
do
	#define a directory name for the NGS library
	BDR=$(echo "b"${smp}"")
	# write the contents with cat
	cat part01B_dada2_demultiplexing_v3.sh | \
	# and use sed to replace a txt string w the b library number
	sed "s/b_library_number/b"${smp}"/g" > "${PATH01}"/"${BDR}"/part01B_dada2_demultiplexing_v3_b"${smp}".sh
	#make the DADA2 sh script executable
	chmod 755 "${PATH01}"/"${BDR}"/part01B_dada2_demultiplexing_v3_b"${smp}".sh

done
#_______________________________________________________________________________________________________________________




#_______________________________________________________________________________________________________________________

# write a sh script that can start all slurm submissions of the DADA2 demultiplex script in one go
# making this overall script executable, will make it possible to start all individual slurm submission scripts for
# part01B in one go, by just executing this resulting script

# Notice the use of backslash to escape the dollar sign and the double quotes in the printf command
# Also notice the use of double percentage symbols to escape the percentage symbol in the part where you need to pad 
# with zeroes
# https://unix.stackexchange.com/questions/519315/using-printf-to-print-variable-containing-percent-sign-results-in-bash-p
printf "#!/bin/bash
# -*- coding: utf-8 -*-

cd "$INDIR02"
# make a list that holds the names of the fastq files
LSSMPL=\$(ls | awk 'BEGIN { FS = \"_\" } ; {print \$1\"_\"\$2}')

#make the list of samples an array you can iterate over
declare -a SMPLARRAY=(\$LSSMPL)
	
# Iterate over sequence numbers
# but pad the number with zeroes: https://stackoverflow.com/questions/8789729/how-to-zero-pad-a-sequence-of-integers-in-bash-so-that-all-have-the-same-width

for smp in \${SMPLARRAY[@]}
 	do
		#define a directory name for the NGS library
		BDR=\$(echo \"b\"\${smp}\"\")
		cd "${PATH01}"/\"\${BDR}\"
		sbatch part01B_sbatch_run_dada2_demultiplexing_v3_b\"\${smp}\".sh
		cd "${WD}"
	done
	 " > "${WD}"/part01B_bash_start_all_demultiplexing_v3.sh

#change back to the working directory
cd "${WD}"
#make it executable
chmod 755 part01B_bash_start_all_demultiplexing_v3.sh

# Instructions:
# now use these commands locally:
# $ rm -rf part01.tar.gz 
# $ tar -zcvf part01.tar.gz part01*
# $ scp part01.tar.gz phq599@fend01.hpc.ku.dk:/groups/hologenomics/phq599/data/EBIODIV_2021jun25/.

# On the remote server execute this command:
# $ tar -zxvf part01.tar.gz 

# Once uncompressed then first execute:

# $ ./part01A_bash_make_batch_lists_ebiodiv01.sh 

echo " 
Instructions:

After you have run ./part01A_bash_make_batch_lists_ebiodiv01.sh 
Then execute:
./part01B_bash_start_all_demultiplexing_v3.sh 

  "

#Line to use for cancelling multiple jobs
#NJOBS=$(seq 30590490 30590959); for i in $NJOBS; do scancel $i; done
#30584709 30585116
#Line to use for checking how jobs perform
#sacct | grep p04_bW | grep 48G | grep CANCE


#