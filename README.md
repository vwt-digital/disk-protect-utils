# disk-protect-utils

This repository contains some scripts to protect an Ubuntu system by encryption of file storage and storing on volatile memory.

## Usage

The protection measures are applied on a computer system by executing the shell scripts in this repository.
Available scripts:

 - [encrypted_home.sh](encrypted_home.sh): Copies the contents of /home to a newly created encrypted device, contained in a file. Then moves /home to /home_backup and mounts the new encrypted device as /home. This script expects /home to be a normal directory on the root file system, behaviour if /home is a mount point is unspecified.
 - [encrypted_swap.sh](encrypted_swap.sh): If swap space is enabled, will create a 32GB encrypted swapfile in root and maps swap space to this encrypted file.
 - [tmp_on_tmpfs.sh](tmp_on_tmpfs.sh): Mounts /tmp to tmpfs.
 - [check.sh](check.sh): Shows if above measures have been applied to the host.

## Password (or key) management

The user data (/home) will be stored in a device contained in the file /encrypted_home. The computer system will prompt for a password (which is referred to as a _key_) on start-up. This key unlocks the encrypted_home file.
Multiple keys can be added to an encrypted device, each of them will give access to the device. This can be used to add a backup password to the device to mitigate the risk of forgetting a password.

##### Add a key
This will prompt for an existing key and ask for a new key to be added:
```
sudo cryptsetup luksAddKey /encrypted_home
```
##### Change a key
This will prompt for the key to be changed and then ask for a new key, which will replace the original key:
```
cryptsetup luksChangeKey /dev/sdb2
```
##### Remove a key
This will prompt for the key to be removed:
```
cryptsetup luksRemoveKey /dev/sdb2
```
