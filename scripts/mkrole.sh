#!/bin/bash

if [ $# -eq 0 ]
then
	echo "USAGE: $(basename $0) ROLENAME..." >&2
	exit 1
fi

for r in $*
do
	for d in tasks defaults meta
	do 
		mkdir -p $r/$d
		(echo "---" ; echo "") >> $p/$d/main.yml
	done
done
