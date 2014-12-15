#!/bin/bash

cd `dirname $0` > /dev/null
SCRIPTDIR=$(pwd)
SCRIPTNAME="$(basename $0)"
SCRIPTFULLNAME="${SCRIPTDIR}/${SCRIPTNAME}"

[ -e rules.d ] && mkdir rules.d
for s in rules.d/*
do
    source $s
done
