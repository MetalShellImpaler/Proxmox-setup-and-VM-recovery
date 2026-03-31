# Proxmox Disaster Recovery: Restoring VMs from LVM disks

# Storage Discovery & LVM Conflict Resolution
# identify the drive
lsblk
# check UUID
vgs -o +vg_uuid

# if needed Rename the old Volume to avoid conflict with the current OS:
vgrename [UUID] old_pve
vgchange -ay old_pve

# Mount the old root partition to a temporary directory
mkdir -p /mnt/old_ssd
mount /dev/old_pve/root /mnt/old_ssd

ls /mnt/old_ssd/var/lib/vz/images

# List and View VM Configs

sqlite3 /mnt/old_ssd/var/lib/pve-cluster/config.db "SELECT name FROM tree WHERE name LIKE '%.conf';"

sqlite3 /mnt/old_ssd/var/lib/pve-cluster/config.db "SELECT data FROM tree WHERE name = '100.conf';"

# Restore VMS manually [ Example with 100.conf and vm-100-disk-0.qcow2 ]
# On the new system, create a new configuration file and paste the data retrieved from the SQLite query.
touch /etc/pve/qemu-server/100.conf

# Paste the data from the old database:
nano /etc/pve/qemu-server/100.conf
cat /etc/pve/qemu-server/100.conf

# Migrate the Virtual Disk
mkdir -p /var/lib/vz/images/100
cp /mnt/old_ssd/var/lib/vz/images/100/vm-100-disk-0.qcow2 /var/lib/vz/images/100/
# Some VMs have more than 1 file\disk, you will need to copy all of them.

#Check the file:
ls -l /var/lib/vz/images/100/

# Scan for the disk
qm rescan --vmid 100

# If even one line in your configuration mentions the old storage, it will try to Boot it and fail.
# In the database file the info should be the info of the new install
# Make sure that the right disk is set to boot from.
# for example:
virtio0: local:100/vm-100-disk-0.qcow2,size=52G

# If there is an ISO location from the old config, remove it or write this:
ide2: none,media=cdrom


# Storage Permissions (GUI or CLI)
# CLI Method:
pvesm set local --content images,rootdir,vztmpl,iso,backup

#    In the Web GUI, go to Datacenter -> Storage.

#    Select local and click Edit.

#    In the Content dropdown, make sure Disk image is selected (it should be highlighted/checked).

#    Click OK.
