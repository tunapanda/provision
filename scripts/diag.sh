#!bin/bash

if [ $EUID -ne 0 ]
then
    (
        echo ""
        echo "ERROR: Please run this script as root"
        echo ""
    ) >&2
    exit 1
fi

T="/usr/local/tunapanda"
while D="/tmp/diag-$(date +%Y%m%d%H%M%S)" && [ -d $D ]
do
    sleep 1
done
mkdir $D

echo ""
echo '***'
echo "This script is gathering data about your system." 
echo "The data will be stored in $D and then compressed"
echo "into an archive you can send to others for analysis."
echo 'This may take a while, so please be patient! :)'
echo '***'
echo ""

cat <<EOF | bash -x &> $D/diag.log
echo "Started at $(date)" > $D/times
uptime &> $D/uptime
ps aufx &> $D/ps
fdisk -l &> $D/fdisk
df -h &> $D/df
dpkg -l &> $D/packages
find $T -ls &> $D/tp_files
blkid &> $D/blkid
dmesg &> $D/dmesg
mkdir $D/logs
cp -a /var/log/{syslog,auth.log,*php*,nginx} $D/logs
mkdir $D/etc
cp -a /etc/ssh/ $D/etc/
cp -a /etc/passwd /etc/group $D/etc/
cp -a /etc/nginx $D/etc/
ls -ld /edx &> $D/edx_root
for F in provisioning.txt provision/localconfig.yml provision/playbooks/ansible.log; \
do \
    [ -e $T/$F ] && cp $T/$F $D ; \
done
echo "Finished at $(date)" >> $D/times
EOF

echo ""
echo '***'
echo "Data collection has finished. Now compressing into an archive..."
echo '***'
echo ""
tar -jcf $D.tar.bz2 $D > /dev/null

echo ""
echo '***'
echo "Compression complete. Please send $D.tar.bz2 for further troubleshooting."
echo "You can now delete the $D directory if you want. It will be deleted automatically"
echo "if you reboot (so will the $D.tar.bz2 file, so either send it or move it now"'!)'
echo '***'
echo ""
