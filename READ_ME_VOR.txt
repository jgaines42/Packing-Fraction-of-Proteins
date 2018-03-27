Running packing fraction code

Notes:
1. To change the atom sizes used, edit line 12 of preprocess_pdb_parameters.py to take a different list
	or change the values in asizes_9.csv
2. If errors occur during preprocessing, check for locations in the PDB where the columns run together
	This typically occurs between atom type and res name when their is a B type (BASP, etc)
3. tasklist.sh and process.sh will be rewritten every time you run the script



Variables:
c1_folder: folder on the cluster with code. ex: /Users/folder1/
c2_folder: folder on the cluster with PDB files. ex: /Users/folder2/
folder1: local folder containing PDB files. ex: /Users/folder3/
X: number of PDBS to run
pdb_list.txt: list of PDBS ids. should be stored in same folder as local code



Steps to set up locally (and then run on cluster):

For initial run:
1. Install Tesselation package (https://github.com/wackywendell/tess/blob/master/README.rst)
	pip install --user tess
2. Transfer volume_10to8_regular_quadrants.cxx to c1_folder on the cluster. Compile:
	g++ volume_10to8_regular_quadrants.cxx -o vor

For all runs, local tasks:
1. Download PDB files to folder1
2. Create list of PDB codes, 1 per row: pdb_list.txt, stored in same folder as this code
3. Make sure that preprocess_pdb_parameters.py will use the correct atom sizes
4. Run bash_edge_code_script_local.sh
	bash bash_edge_code_script_local.sh pdb_list.txt folder1 X c1_folder c2_folder
	- pdb_list.txt: list of PDB codes, in same folder as this code
	- folder1: folder containing PDBs
	- X: replace by integer stating number of PDBS in PDB file list
	- c1_folder: full path to cluster folder that will contain volume code
	- c2_folder: full path to cluster folder that will contain PDB data
5. Step 4 will produce tasklist.sh as well as *_H.pdb, *.txt and *_vor.txt files for each PDB
	- Transfer *.txt files to c2_folder on the cluster
	- Transfer tasklist.sh to your home directory on the cluster. 
	- tasklist.sh contains 100 tasks for each PDB. Each will take about 20 minutes to run

7. Submit tasks to cluster using whatever method you prefer
8. After the tasks are finished, process by submitting process.sh (should only need 1-5 CPUs)
	- first need to transfer process_volume_output.m to the cluster
	- End result will be *_vol.txt file for each PDB
	- If the output looks good, you can delete the other 100 files created for each PDB
9. To calculate packing fraction, *_vor.txt has the voronoi volume and *_vol.txt has the actual volume
	- column 1 in *_vol.txt is 1 if the atom is solvent exposed

The following files will also be created and can be deleted after the bash script finishes:
 *ordered.pdb
 *ordered1.pdb
 *ordered2.pdb
 *noH.pdb
