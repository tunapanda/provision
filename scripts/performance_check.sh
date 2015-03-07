#!/bin/bash

echo "*** UPTIME AND LOAD AVERAGE ***"
uptime
echo ""

echo "*** TOP 10 PROCESSES BY CPU (avg %cpu, total cpu d:h:m, running since, pid, command)"
ps axo '%cpu,cputime,etime,pid,comm' | sort -nr | head
echo ""

echo "*** TOP 10 PROCESSES BY MEMORY (current %mem, pid, command)"
ps axo '%mem,pid,comm' | sort -nr | head
echo ""

echo "*** IOSTAT (cumulative usage, then 5-second samples)"
iostat -x 5 3
echo ""

echo "*** LISTENING PROCESSES"
netstat -tlpn | sort -nk4
echo ""

echo "*** NETWORK CONNECTIONS"
netstat -tpn | sort -nk4
echo ""
