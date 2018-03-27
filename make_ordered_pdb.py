#--------------------------------------------------------------------------------
# make_ordered_pdb.py folder_name file1 num_pdb
# Input:
# folder_name: full path to folder containing PDB files. ex) /Users/folder1/
# file1: file containing list of all PDB codes. Must be full path ex) /Users/folder1/data.txt
# num_pdb: The number of PDBs to run
# 
# Output:
# *_ordered.pdb: a file for each PDB with disordered atoms and heteroatoms removed
#--------------------------------------------------------------------------------

#! /Users/jennifergaines/anaconda/bin/python
from Bio.PDB import*
import Bio.PDB as pdb
import numpy as np

#Determines if atom is disordered or not
class NotDisordered(Select):
	def accept_atom(self, atom):
		if (not atom.is_disordered()) or atom.get_altloc() == 'A':
			atom.set_altloc(' ')  # Eliminate alt location ID before output.

			return True
		else:  # Alt location was not one to be output.
			return False


#Determines if atom is heteroatom or not		
class NonHetSelect(Select):
    def accept_residue(self, residue):
        return 1 if residue.id[0] == " " else 0				

import sys
hiq = open(sys.argv[2], 'r')
		
parser=PDBParser()
folder_name = str(sys.argv[1])

# Loop over all PDBS and save ordered file
for hiq_files in range(0,int(sys.argv[3])):
	file_name = hiq.readline().rstrip()
	s = parser.get_structure("my_pdb", folder_name + file_name + ".pdb")
	io=PDBIO()

	io.set_structure(s)
	io.save(folder_name + file_name + "_ordered2.pdb", select=NotDisordered())
	
	s = parser.get_structure("my_pdb", folder_name + file_name + "_ordered2.pdb")
	io = PDBIO()
	io.set_structure(s)
	io.save(folder_name + file_name + "_ordered1.pdb",  NonHetSelect())

	s = parser.get_structure("my_pdb", folder_name + file_name + "_ordered1.pdb")
	model = s[0]
	chain = model
	atoms = [a for a in chain.get_atoms() if pdb.is_aa(a.parent)]

	parents = []
	counter = 0;
	for  a in chain.get_atoms() :
		if pdb.is_aa(a.parent):
			parents.append(a.parent)
			counter = counter + 1;
	xyzs = [(a.coord) for a in atoms]
	xyzarr = np.array(xyzs)
	f = open(folder_name+file_name + '_ordered.pdb', 'w')
	id_counter = 0

	for i in range (0, len(atoms)):
		new_res = parents[i].get_id()[1];
		if atoms[i].get_name() == 'N':
			id_counter = id_counter+1
		if len(atoms[i].get_name())<4:
			f.write('{:6s}{:5d}  {:<4}{:3s} {:1s}{:4d}{:1s}   {:8.3f}{:8.3f}{:8.3f}{:6.2f}{:6.2f}          {:>2s} \n'.format('ATOM', i, atoms[i].get_name(), parents[i].get_resname(),atoms[i].get_full_id()[2],  id_counter, '',xyzarr[i][0], xyzarr[i][1], xyzarr[i][2], atoms[i].get_occupancy(), atoms[i].get_bfactor(),atoms[i].get_name()[0] ))
		else:
			f.write('{:6s}{:5d} {:<4} {:3s} {:1s}{:4d}{:1s}   {:8.3f}{:8.3f}{:8.3f}{:6.2f}{:6.2f}          {:>2s} \n'.format('ATOM', i, atoms[i].get_name(), parents[i].get_resname(),atoms[i].get_full_id()[2],  id_counter, '',xyzarr[i][0], xyzarr[i][1], xyzarr[i][2], atoms[i].get_occupancy(), atoms[i].get_bfactor(),atoms[i].get_name()[0] ))
					
	f.close()
hiq.close()
