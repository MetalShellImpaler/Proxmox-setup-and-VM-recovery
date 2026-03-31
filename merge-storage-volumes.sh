# reconfigure storage (single disk, ext4)
lvremove /dev/pve/data

lvresize -l +100%FREE /dev/pve/root
resize2fs /dev/mapper/pve-root

pvesm remove local-lvm
