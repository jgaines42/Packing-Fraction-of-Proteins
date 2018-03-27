#! /Users/jennifergaines/anaconda/bin/python
#/Library/Frameworks/Python.framework/Versions/2.7/bin/python
#import matplotlib.pyplot as plt
import Bio.PDB as pdb
import tess
import numpy as np


import csv
with open('atypes.csv') as f:
    atypes = dict([((res,aname), atype) for res,aname,atype in csv.reader(f)])
with open('asizes_7.csv', 'rU') as f:
    asizes = dict([(atype, float(sz)) for atype, sz in csv.reader(f)])
 
def get_size(atom):
	
	rname, aname = atom.parent.resname, atom.name
	if (rname, aname) not in atypes and ('X',aname) in atypes :
		rname = 'X'
	atype = atypes.get((rname, aname), None)
	return asizes.get(atype, None)
	
def find_overlaps(xyzarr, sizes, atoms):
	d_over = 0
	s_over = 0
	print(len(sizes))
	print(xyzarr[0])
	print(xyzarr[1])
	for i in range(0, len(sizes)):
		print(atoms[i])
		print(s_over)
		for j in range(i+1, len(sizes)):
			print(atoms[j].parent)
			dist1 = xyzarr[i] - xyzarr[j]
			dist = np.sqrt(np.dot(dist1.T , dist1))

			if dist < sizes[i]:
				if dist < sizes[j]:
					d_over = d_over + 1
					print(atoms[i])
					print(atoms[j])
					print(xyzarr[i])
					print(xyzarr[j])
					print(dist)
					print(sizes[i])
					print(sizes[j])
					if i > 0:
						aerews
				else:
					s_over = s_over + 1
			elif dist < sizes[j]:
				s_over = s_over + 1
		
	print("done")
	print(d_over)
	print(s_over)
	return d_over, s_over
			
				
def get_voronoi(struc, size_func = get_size):
	"Calculate the Voronoi structure for a structure."
	model = spdb[0]
	chain = model
	#atoms = [a for a in chain.get_atoms() ]
	atoms1 = [a for a in chain.get_atoms() if pdb.is_aa(a.parent)]
	#.disorderd_select('A')
	parents = []
	atoms = []
	for  a in chain.get_atoms() :
		if pdb.is_aa(a.parent):
			if a.parent.get_id()[2] == ' ' :
				parents.append(a.parent)
				atoms.append(a)


	print(len(parents))
	print(len(atoms))
	
	sizes = [size_func(a) for a in atoms]
	
	# f = open('sizes.txt', 'w')
# 	
#   	for i in range(0, len(sizes)) :
# 		if type(sizes[i])is float:
# 			f.write('{:3f} \n'.format( sizes[i]))
# 		else:
# 			print(atoms[i].get_name() + " " + atoms[i].parent.get_resname())
# 	f.close()
	
	xyzs = [(a.coord) for a in atoms]
	xyzarr = np.array(xyzs)
	# subtract off the center of mass
	com = np.mean(xyzarr, axis=0)
	xyzarr = xyzarr - com
	# the maximum "coordinate", so we know how big to make the box
	maxcoord = np.amax(abs(xyzarr))
	lowerlim = tuple([-maxcoord-3]*3) #normal *2*3 #tight: -3, +3
	upperlim = tuple([maxcoord+3]*3)

	# Calculate the Voronoi tesselation
	#d_over, s_over = find_overlaps(xyzarr, sizes, atoms)
	#print(d_over + " " + s_over)

  	#f.close()
# 	
	cntr = tess.Container(xyzarr, limits=(lowerlim, upperlim), periodic=False, radii=sizes)
	print("Here\n")
	return atoms, cntr, parents
	
def get_core(atoms, cntr):
	"""
	Given a set of atoms and a Voronoi tesselation, calculate which atoms are in the core.
	"""
	all_res = set()
	edge_ix = set()
	edge_res = set()
	near_edge_res = set()
	for n,(c,a) in enumerate(zip(cntr, atoms)):
		all_res.add(a)
		if min(c.neighbors()) < 0:
			edge_res.add(a)
			edge_ix.add(n)
		
	for c,a in zip(cntr, atoms):
		if a in edge_res: continue
		if any([n in edge_ix for n in c.neighbors()]):
			near_edge_res.add(a)
	
	core_res = (all_res - edge_res) - near_edge_res
	return core_res, edge_res, near_edge_res
	
parser = pdb.PDBParser()


import sys
print sys.argv[1:]

hiq = open(sys.argv[2], 'r')


for hiq_files in range(0,int(sys.argv[3])):
	file_name = hiq.readline().rstrip()

	spdb = parser.get_structure("new_file", sys.argv[1] + file_name + "_H.pdb")
	print(file_name)

	model =  spdb[0]

	chain = model
	atoms = [a for a in chain.get_atoms() if pdb.is_aa(a.parent)]


	atoms, cntr, parents = get_voronoi(spdb)
	print(cntr[1].vertices())

	core, edge, near_edge_res = get_core(atoms, cntr)

	f = open(sys.argv[1] + file_name + '_vor_extended4.txt', 'w')
		#if ends in 1, then it is just neighbors of the sidechain
	#if doesn't end in one, then it is neighbors of entire residue


	for i in range(0, len(cntr)) :
		neigh_list = cntr[i].neighbors();
		f.write('{:5s} {:4s} {:1d} {:3f} '.format(atoms[i].get_name(), parents[i].get_resname(), parents[i].get_id()[1], cntr[i].volume()))


		if  atoms[i] in core:
			f.write(" core \n")
		if atoms[i] in edge:
			f.write(" edge \n")
		if atoms[i] in near_edge_res:
			f.write(" nearedge \n")
	f.close()
	
hiq.close()
