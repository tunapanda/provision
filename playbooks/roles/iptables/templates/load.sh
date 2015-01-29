#!/bin/bash

cd `dirname $0` > /dev/null
SCRIPTDIR=$(pwd)
SCRIPTNAME="$(basename $0)"
SCRIPTFULLNAME="${SCRIPTDIR}/${SCRIPTNAME}"
RULESDIR="${SCRIPTDIR}/rules.d"

export IPTABLES=${IPTABLES:-{{ iptables__cmd }}}
[ -e $RULESDIR ] || mkdir $RULESDIR
cd $RULESDIR
for s in $(ls *.conf)
do
    source $s
done
cd -
