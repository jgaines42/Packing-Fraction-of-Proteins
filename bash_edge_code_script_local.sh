# Bash script for running edge code 

# Input :
# 1. name of a file with a list of pdb names. must be full path name
# 2. folder to save everything to
# 3. Number of pdbs to run

# Ouput:
# pdb file with hydrogen for each
# .txt file for each
# Task list for ./vor tasks

# Note:
# All pdb files must already be in the folder

#!/bin/bash 
rm tasklist.sh
rm process.sh

file1=$1 			#File containing list of PBDB codes
file2="tasklist.sh"
folder_name=$2		#Folder containing PDB files
num_pdb=$3			#Number of PDB to run
cluster_folder=$4	#Folder on cluster where code will be stored
cluster_data=$5		#Folder on cluster where PDBs and output will be
file3="process.sh"

file_ending1=".pdb"
file_ending2="_H.pdb"
file_ending3="_noH.pdb"
file_ending4=".txt"
file_ending5="_ordered.pdb"
space=" "

python make_ordered_pdb.py $folder_name $file1 $num_pdb

echo $file1

 while IFS='' read -r line || [[ -n "$line" ]];
	do
		run_loop=1
		echo $line
		line=$(echo "$line" | tr '[:upper:]' '[:lower:]')
		./reduce -Trim -quiet $folder_name$line$file_ending5>$folder_name$line$file_ending3
		./reduce -quiet $folder_name$line$file_ending3>$folder_name$line$file_ending2
	done<$file1

python preprocess_pdb_parameters.py $folder_name $file1 $num_pdb

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

python vor_size.py $folder_name $file1 $num_pdb
