# disk-protect-utils

This repository contains some scripts to protect an Ubuntu system by encryption of file storage and storing on volatile memory.
The measures will be applied to the host on which the script is executed.

Available scripts:

 - [encrypted_home.sh](encrypted_home.sh): Copies the contents of /home to a newly created encrypted device, contained in a file. Then moves /home to /home_backup and mounts the new encrypted device as /home. This script expects /home to be a normal directory on the root file system, behaviour if /home is a mount point is unspecified.
 - [encrypted_swap.sh](encrypted_swap.sh): If swap space is enabled, will create a 32GB encrypted swapfile in root and maps swap space to this encrypted file.
 - [tmp_on_tmpfs.sh](tmp_on_tmpfs.sh): Mounts /tmp to tmpfs.
 - [check.sh](check.sh): Shows if above measures have been applied to the host.

