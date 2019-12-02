#!/bin/bash

if [[ $(id -u) -ne 0 ]]
then 
    echo "Please run as root"
    exit 1
fi

# Disable any existing swap
swapoff -a

# Allocate file to store encrypted swap data
if [ ! -f /swapfile ]
then
    fallocate -l 32G /swapfile
fi

# Add cryptswap encrypted device to /etc/crypttab
{
    grep -v "\s/swapfile\s" /etc/crypttab
    echo "cryptswap /swapfile /dev/urandom swap,offset=1024,cipher=aes-xts-plain64,size=256"
} > /tmp/newcrypttab

mv /tmp/newcrypttab /etc/crypttab

# Start the encrypted device
cryptdisks_start cryptswap

# Replace all swap entries in /etc/fstab
{
    grep -v "\sswap\s" /etc/fstab
    echo "#/swapfile                                 none            swap    sw              0       0"
    echo "/dev/mapper/cryptswap none swap sw 0 0"
} > /tmp/newfstab

mv /tmp/newfstab /etc/fstab

# Enable newly configured encrypted swap
swapon -a
