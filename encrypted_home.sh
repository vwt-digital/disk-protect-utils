#!/bin/bash

if [[ $(id -u) -ne 0 ]]
then 
    echo "Please run as root"
    exit 1
fi

if mount | grep -q "\\son /home\\s";
then
    echo "/home is expected to be a directory instead of a mounted volume"
    exit 1
fi

data_file=/encrypted_home
homedir_size=100   # GB to allocate for /home
mount_dir=/home

# Allocate file to store encrypted home data
echo "Creating file ${data_file} to store ${homedir_size} GB home dir space (this might take a few minutes)..."
if [ ! -f ${data_file} ]
then
    count=$(( 16 * homedir_size ))
    dd if=/dev/urandom of=${data_file} iflag=fullblock bs=64M count=${count} || exit 1
fi

# Setting up luks file container
echo "luksFormat: creating new encrypted storage"
cryptsetup luksFormat -y ${data_file} || exit 1

echo "luksOpen: opening encrypted storage for formatting"
cryptsetup luksOpen ${data_file} crypthome || exit 1

echo "mkfs.ext4: format encrypted storage"
mkfs.ext4 /dev/mapper/crypthome || exit 1

echo "luksClose: closing encrypted storage"
cryptsetup luksClose crypthome || exit 1

# Add crypthome encrypted device to /etc/crypttab
{
    grep -v "^crypthome\\s" /etc/crypttab
    echo "crypthome ${data_file} none luks"
} > /tmp/newcrypttab

mv /tmp/newcrypttab /etc/crypttab || exit 1

# Start the encrypted device
echo "Starting encrypted device"
cryptdisks_start crypthome || exit 1

# Move current home dir as a backup
mv ${mount_dir} /home_backup || exit 1

# Mount new encrypted home
mkdir -p ${mount_dir}

{
    grep -v "\\s${mount_dir}\\s" /etc/fstab
    echo "/dev/mapper/crypthome ${mount_dir} ext4 defaults 0 2"
} > /tmp/newfstab

mv /tmp/newfstab /etc/fstab || exit 1

# Enable newly configured encrypted home mount (and any other mount in fstab)
mount -a || exit 1

# Copy data to new encrypted home
echo "Copying data from /home_backup to ${mount_dir}..."
rsync -av /home_backup/* ${mount_dir}/
result=$?
if [ ${result} -eq 0 ]
then
    echo "OK"
else
    echo "FAILED"
    exit 1
fi

