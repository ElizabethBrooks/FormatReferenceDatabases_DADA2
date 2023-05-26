#!/bin/bash
#$ -M ebrooks5@nd.edu
#$ -m abe
#$ -r n
#$ -N taxonAssign_jobOutput

# creator: Elizabeth Brooks
# e-mail: ebrooks5@nd.edu
# date: 26 May 2023

# BASH script to parse CO1_.fasta and CO1_taxonomy.txt and create 
# a fasta file with the sequence ID replaced with the 
# taxonomic assignment (column 2) from CO1_taxonomy.txt
# https://benjjneb.github.io/dada2/training.html
# https://ucedna.com/reference-databases-for-metabarcoding 

# usage: qsub formattingCustomDatabases_assignTaxonomy.sh workingDir subsetTag

# set working directory with input files
workingDir=$1

# set the subset tag for the split fasta file
subsetTag=$2

# set output fasta file name
outRef=$workingDir"/CO1_taxonomyAssignment.fasta."$subsetTag

# set temporary file names
tmpRef=$workingDir"/tmp_CO1_.fasta."$subsetTag
tmpDB=$workingDir"/tmp_CO1_taxonomy.txt."$subsetTag

# make a coppy of the temporary CO1_taxonomy.txt file for the current subset
# in order to avoid conflicts between the scripts running on each subset
cp $workingDir"/tmp_CO1_taxonomy.txt" $tmpDB

# make sure a previous output fasta does not exsist
rm $outRef

# loop over each line (sequence) in the temporary singleline fasta
while IFS= read -r line; do
	# retrieve the current sequence ID
	# and remove the > tag
	seqID=$(echo $line | cut -d '@' -f1 | sed 's/>//g')
	# output a status message
	echo "Processing $seqID ..."
	# open the CO1_taxonomy.txt file and search for the current ID word,
	# retrieve the taxonomy assignment,
	# add the > tag, and append to the output fasta
	cat $tmpDB | grep -w "$seqID" | cut -f2 | sed 's/^/>/g' >> $outRef
	# retrieve the current sequence, replace the ^ tags with newlines,
	# and append to the output fasta
	echo $line | cut -d '@' -f2 >> $outRef
done < $tmpRef

# remove empty lines from the output fasta
sed -i.bak '/^$/d' $outRef

# clean up and remove temporary files
rm $tmpRef
rm $tmpDB

# output a status message
echo "Analysis complete for $subsetTag !"
