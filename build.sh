#!/bin/bash

# Iterates through all branches to pull verilog files into lib/

# make sure we are on the main branch
git switch main

# clean library
rm lib/* -r

# reads all branches on this machine into a list 
x=$(git branch -r --format="%(refname:short)" | egrep -v '^(origin/)?(main|HEAD)$') 
readarray -t x <<< "$x"

# loop through all the branches (including remote branches)
for v in ${x[*]}
do
	# Find files of the form <folder>/sim/<folder>/<name>.v
	f=$(git ls-tree -r $v --name-only | egrep ".+\.v$" | egrep -v "^lib/.+\.v$")

	echo -e "Reading files:
\033[0;32m$f\033[0m
from branch \033[0;31m$v\033[0m
"

	readarray -t f <<< "$f"

	# Loop through every file in the file list
	vstripped=$(egrep -o '[^/]+$' <<< $v)
	mkdir lib/$vstripped
	for file in ${f[*]}
	do
		# Calculate new path in the library directory
		npath="lib/$vstripped/$(egrep -o "[^/]+\.v" <<< $file)"
		git show $v:$file > $npath
	done
done
