#!/bin/bash
SWAPFILE="${SWAPFILE:-/var/swapfile}"

if [ $EUID -ne 0 ]
then
	echo ""
	echo 'Please run me as root!'
	echo ""
fi

TOTAL_MEM=$(free -m | grep '^Mem:' | awk '{print $2}')
TOTAL_SWAP=$(free -m | grep '^Swap:' | awk '{print $2}')
if [ $[ $TOTAL_SWAP * 2 ] -ge $TOTAL_MEM ]
then
	echo ""
	echo "It looks like you already have $TOTAL_SWAP megabytes of swapspace for $TOTAL_MEM megabytes of RAM, which should be enough. Swapspace probably isn't your problem."
	echo ""
	exit
fi

NEEDED_SWAP=$[ $[ $TOTAL_MEM * 2 ] - $TOTAL_SWAP ]
echo ""
echo "It looks like you have $TOTAL_MEM megabytes of RAM, and could use $NEEDED_SWAP more megabytes of swapspace."
echo ""
echo "Let's make some swap"'!'

echo ""
echo "Creating swapfile... (this can take a while)"
if [ -f $SWAPFILE ]
then
	echo "It looks like a swapfile already exists at $SWAPFILE."
	echo "I'm going to assume it's a real swapfile of the correct size"
	echo "and just try to activate it. If this doesn't work, try"
	echo "re-naming or deleting the file and re-running this script"
else
	dd if=/dev/zero of=$SWAPFILE bs=1M count=$NEEDED_SWAP
fi

echo ""
echo "Adding swapfile to /etc/fstab..."
if grep "^$SWAPFILE" /etc/fstab &> /dev/null
then
	echo "It looks like there is already a line for your swapfile in /etc/fstab, so we won't add another one"
else
	echo "$SWAPFILE  none	swap	defaults 0 0" >> /etc/fstab
fi

echo ""
echo "Activating swapfile..."
swapon $SWAPFILE 2>/dev/null || ( mkswap $SWAPFILE && swapon $SWAPFILE )

# Just for good measure, and also to test the fstab entry...
swapon -a

NEW_TOTAL_SWAP=$(free | grep '^Swap:' | awk '{print $2}')
echo ""
echo "You now have $NEW_TOTAL_SWAP megabytes of swap space. Enjoy"'!'
echo ""
