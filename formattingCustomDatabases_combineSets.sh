#!/bin/bash

# creator: Elizabeth Brooks
# e-mail: ebrooks5@nd.edu
# date: 27 May 2023

# BASH script to combine split the input fasta file outputs 

# usage: bash formattingCustomDatabases_combineSets.sh

# set working directory with input files
workingDir="/scratch365/ebrooks5/taxonAssign_DADA2"

# set output fasta file name
outRef=$workingDir"/CO1_taxonomyAssignment.fasta"

# combine the subsets of fasta files
cat $outRef"."* > $outRef
