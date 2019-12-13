#!/bin/bash

if [[ $(id -u) -ne 0 ]]
then 
    echo "Please run as root"
    exit 1
fi

# Unmount tmp (in case it is mounted)
umount /tmp

# Add or replace /tmp entry in fstab
{
    grep -v "\\s/tmp\\s" /etc/fstab
    echo "tmpfs /tmp tmpfs rw,nosuid,nodev"
} > /tmp/newfstab

mv /tmp/newfstab /etc/fstab

# Mount the new /tmp entry (and any other unmounted entry in fstab)
mount -a
