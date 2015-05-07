#!/bin/bash

if [ $# -eq 0 ]
then
	echo "USAGE: $(basename $0) ROLENAME..." >&2
	exit 1
fi

vim -p $(find $* -type f | grep '\.yml\|\.j2\|\.html\|\.css\|\.js\|\.php')
