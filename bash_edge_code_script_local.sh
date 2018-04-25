# Bash script for running edge code 

# Input :
# 1. name of a file with a list of pdb names. must be full path name
# 2. folder to save everything to
# 3. Number of pdbs to run

# Ouput:
# .txt file for each protein
# Task list for ./vor tasks

# Note:
# All pdb files must already be in the folder
# You must run download_preprocess_pdb.py first to remove heteroatoms and add hydrogens to the proteins

#!/bin/bash 
rm tasklist.sh
rm process.sh

file1=$1 		#File containing list of PBDB codes
file2="tasklist.sh"
folder_name=$2		#Folder containing PDB files
num_pdb=$3		#Number of PDB to run
cluster_folder=$4	#Folder on cluster where code will be stored
cluster_data=$5		#Folder on cluster where PDBs and output will be
file3="process.sh"

file_ending4=".txt"
space=" "

# Create text files for the proteins
python preprocess_pdb_parameters.py $folder_name $file1 $num_pdb

# Make task list for getting atomic volumes and surface/core designation
while IFS='' read -r line || [[ -n "$line" ]];
	do
		run_loop=1
		echo $line
		line=$(echo "$line" | tr '[:upper:]' '[:lower:]')

		a=($(wc $folder_name$line$file_ending4))
		num_lines=${a[0]}
		
		while [ $run_loop -le 100 ]
			do
				echo -n "source ~/.bashrc; cd " >> $file2
				echo -n $cluster_folder >> $file2
				echo -n "; ./vor " >> $file2
				echo -n $cluster_data >> $file2
				echo -n $line >> $file2
				echo -n "$space" >> $file2
				echo -n $num_lines >> $file2
				echo -n "$space" >> $file2
				echo -n $run_loop >> $file2
				echo ";" >> $file2
				run_loop=$((run_loop+1))
			done
	done<$file1

#Create processing tasks
while IFS='' read -r line || [[ -n "$line" ]];
	do
		run_loop=1
		echo $line
		line=$(echo "$line" | tr '[:upper:]' '[:lower:]')

		a=($(wc $folder_name$line$file_ending4))
		num_lines=${a[0]}
		
		echo -n "source ~/.bashrc; cd " >> $file3
		echo -n $cluster_folder >> $file3
		echo -n '; module load MATLAB/2016b; matlab -nosplash -nodisplay -nojvm -r "process_volume_output(' >> $file3
		echo -n "'" >> $file3
		echo -n $line >> $file3
		echo -n "'" >> $file3
		echo -n ",'" >> $file3
		echo -n $cluster_data >> $file3
		echo -n "'," >> $file3
		echo -n $num_lines >> $file3
		echo -n ')"' >> $file3
		echo ";" >> $file3
		run_loop=$((run_loop+1))

	done<$file1

#run voronoi calculations
python vor_size.py $folder_name $file1 $num_pdb
