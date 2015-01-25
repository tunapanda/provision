#!/bin/bash

#IPTABLES=${IPTABLES:-{{ iptables__cmd }}}
IPTABLES=/sbin/iptables

$IPTABLES -t nat -P PREROUTING ACCEPT
$IPTABLES -t nat -P POSTROUTING ACCEPT
$IPTABLES -t filter -P INPUT ACCEPT
$IPTABLES -t filter -P OUTPUT ACCEPT
$IPTABLES -t filter -P FORWARD ACCEPT
$IPTABLES -t nat -F
$IPTABLES -t filter -F
$IPTABLES -t mangle -F
$IPTABLES -t nat -X
$IPTABLES -t filter -X
$IPTABLES -t mangle -X
