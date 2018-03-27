# Bash script for running edge code 

# Input :
# 1. name of a file with a list of pdb names. must be full path name
# 2. folder to save everything to. ex) /Users/folder1/
# 3. Number of pdbs to run

# Ouput:
# pdb files with hydrogens
# .txt file for each protein containing coordinates and atom sizes
# Task list for ./vor tasks

# Note:
# All pdb files must already be in the folder

#!/bin/bash 
rm tasklist.sh			# Remove existing tasklist.s and process.sh
rm process.sh

file1=$1 			#File containing list of PBD codes
file2="tasklist.sh"
folder_name=$2			#Folder containing PDB files
num_pdb=$3			#Number of PDB to run
cluster_folder=$4		#Folder on cluster where code will be stored ex) /Users/folder1/
cluster_data=$5			#Folder on cluster where PDBs and output will be ex) /Users/folder2/
file3="process.sh"

file_ending1=".pdb"
file_ending2="_H.pdb"
file_ending3="_noH.pdb"
file_ending4=".txt"
file_ending5="_ordered.pdb"
space=" "

#Make files ordered
python make_ordered_pdb.py $folder_name $file1 $num_pdb

#Add hydrogen atoms
echo $file1
 while read -r line
	do
		run_loop=1
		echo $line
		line=$(echo "$line" | tr '[:upper:]' '[:lower:]')
		./reduce -Trim -quiet $folder_name$line$file_ending5>$folder_name$line$file_ending3
		./reduce -quiet $folder_name$line$file_ending3>$folder_name$line$file_ending2
	done<$file1

#Make *.txt files for each PDB
 python preprocess_pdb_parameters.py $folder_name $file1 $num_pdb

#Create tastlist file
while read -r line
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

# Create processing tasks
 while read -r line
 	do
 		run_loop=1
 		echo $line
 		line=$(echo "$line" | tr '[:upper:]' '[:lower:]')
 
 		a=($(wc $folder_name$line$file_ending4))
 		num_lines=${a[0]}
 		
 		echo -n "source ~/.bashrc; cd " >> $file3
 		echo -n $cluster_folder >> $file3
 		echo -n '; matlab -nosplash -nodisplay -nojvm -r "process_volume_output(' >> $file3
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


#Calculate Voronoi cells
python vor_size.py $folder_name $file1 $num_pdb
