#!/bin/bash

# this script must be used to finalize a Testbox for IO-Testing

# fill /etc/hosts with correct hostname
HOSTNAME=`cat /etc/hostname`
echo "127.0.0.1 $HOSTNAME.lab.linutronix.de $HOSTNAME" >/etc/hosts

# ensure correct permissions on keys
chown -R as-jenkins-prod:as-jenkins-prod /home/as-jenkins-prod
chown -R as-jenkins-int:as-jenkins-int /home/as-jenkins-int
chmod 600 /home/as-jenkins-prod/.ssh
chmod 600 /home/as-jenkins-int/.ssh
chmod 644 /home/as-jenkins-prod/.ssh/auth*
chmod 644 /home/as-jenkins-int/.ssh/auth*

# handle the external disk
# label the disk for automatic mounting
e2label /dev/sda1 SSD-HOME
# mount the disk to /mnt and move the data in /home to it
mount /dev/sda1 /mnt
mv /home/* /mnt
umount /mnt

# resize root partition to full sd card size
# there is no error handling or sanity checking because the layout
# is fixed and defined by the ELBE recipes
# partition 3 is the root partition which should be resized to
# the full size of the sd card

# use sfdisk to change the size of root partition to maximum space
echo ", +"|sfdisk -N 3 /dev/mmcblk0
# inform the kernel about the partition change
partx -u /dev/mmcblk0p3
# enhance the fs to the new size
resize2fs /dev/mmcblk0p3

# change password for user root
echo "set new password for root"
passwd root

# finalize snmp configuration

# gen passwords for snmp v3 access
echo "SNMPD Configuration"
AES=`pwgen 20 1`
SHA=`pwgen 20 1`
# add user with passwords to snmp config
service snmpd stop
net-snmp-create-v3-user -ro -a SHA -x AES -A $SHA -X $AES librenms
service snmpd start
echo "the following data must be forwarded to the IT to add the host to monitoring"
echo "PW AES: $AES"
echo "PW SHA: $SHA"
echo "IP Address: `ip address show dev br1 |grep 'inet '`"
echo "Hostname: $HOSTNAME"

# everything finished, remind user to reboot the machine
echo "finalizing setup done - pls reboot and test"
