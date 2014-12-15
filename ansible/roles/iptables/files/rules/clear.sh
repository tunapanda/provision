#!/bin/bash

IPTABLES=/sbin/iptables

for chain in PREROUTING POSTROUTING INPUT OUTPUT FORWARD
do
	$IPTABLES -P $chain ACCEPT 
done

$IPTABLES -F
