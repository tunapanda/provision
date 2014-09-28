#!/bin/bash

which gsettings || exit 0

for u in $(awk -F: '$3 < 5000 && $3 >= 1000 {print $1}' /etc/passwd)
do
	sudo -u $u dbus-launch --exit-with-session gsettings reset-recursively org.gnome.desktop.background 
done

touch /tmp/COMPLETED_artwork-post-install
