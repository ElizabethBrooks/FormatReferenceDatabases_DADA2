#!/bin/bash
#$ -M ebrooks5@nd.edu
#$ -m abe
#$ -r n
#$ -N taxonDriver_jobOutput

# creator: Elizabeth Brooks
# e-mail: ebrooks5@nd.edu
# date: 26 May 2023

# BASH script to split the input fasta file and run a separate BASH script to
# parse CO1_.fasta and CO1_taxonomy.txt and create 
# a fasta file with the sequence ID replaced with the 
# taxonomic assignment (column 2) from CO1_taxonomy.txt
# https://benjjneb.github.io/dada2/training.html
# https://ucedna.com/reference-databases-for-metabarcoding 

# usage: qsub formattingCustomDatabases_driver.sh

# set working directory with input files
workingDir="/scratch365/ebrooks5/taxonAssign_DADA2"

# change to the working directory
cd $workingDir

# set input file names
inRef="CO1_.fasta"
inDB="CO1_taxonomy.txt"

# set output fasta file name
outRef="CO1_taxonomyAssignment.fasta"

# set temporary file names
tmpRef="tmp_CO1_.fasta"
tmpDB="tmp_CO1_taxonomy.txt"

# prepare a temporary CO1_taxonomy.txt file by replacing white spaces with tabs
# since the third column of taxonomic assignment is space separated
cat $inDB | tr ' ' '\t' > $tmpDB

# create temporary singleline fasta by 
# opening the CO1_.fasta file, add a ^ tag to the end of each line, 
# remove all new lines, and add newlines back just before each sequence >
cat $inRef | sed -e 's/$/@/' | tr -d '\n' | sed 's/>/\n>/g' > $tmpRef

# split the temporary singleline fasta into smaller subsets
# of sequences for each job run
# total seqeunces / 8 jobs = number of sequences per job
# 2017311/8 = 252163
split -l 253000 $tmpRef $tmpRef"."

# loop over each segment
for i in $tmpRef"."*; do
	# retrieve subset tag
	subsetTag=$(basename $i | sed 's/CO1\_\.fasta\.//g')
	# output status message
	echo "Starting analysis for subset $subsetTag ..."
	# generate Ka and Ks values for protein sequences
	qsub -N "taxonAssign_"$subsetTag formattingCustomDatabases_assignTaxonomy.sh $workingDir $subsetTag
done

# wait for the jobs to finish running
# using the current working directory
qsub -hold_jid "taxonAssign_"* -cwd

# combine the subsets of fasta files
cat $tmpRef"."* > $outRef

# output a status message
echo "Analysis complete!"
