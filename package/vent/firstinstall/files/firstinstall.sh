#!/bin/sh

# This script is part of a SD (or USB) bootable system containing the
# eMMC images (<2GB) for the Visible Energy ntop target.

# TODO:EXTEND: At the moment this script is simplistic in just
# installing the boot and root to explicit partitions. We need to
# extend the script to be used for early development updates (until we
# have a working OTA solution) so allow installation to the
# alternative partition and boot from them. We need a mechanism to
# identify the active boot/root world though.

# If eMMC NOT our partition format then copy eMMC onto SDcard for
# backup and re-partition eMMC to our partition scheme.
#      16MB boot0
#      16MB boot1
#      512MB root0
#      512MB root1
#      2.7G for future user state

# We expect mmcblk0 from the factory to be:
# NR START     END SECTORS SIZE NAME UUID
#  1  2048 7733247 7731200 3.7G      89708921-01
SIZEP1=`/usr/sbin/partx -rgo SIZE -n 1:1 /dev/mmcblk0`
echo "SIZEP1="$SIZEP1
if [ $SIZEP1 == "3.7G" ]; then
 # Backup factory images:
 echo "Backing up eMMC and SPI images to /root ..."
 dd if=/dev/mmcblk0 of=/root/mmcblk0.bin
 dd if=/dev/mtdblock0 of=/root/mtdblk0.bin
 echo "Back up completed"

 # Re-partition eMMC
 echo "Re-partitioning eMMC ..."
 /usr/sbin/sfdisk /dev/mmcblk0 < /root/vent.layout
 echo "Partition table now:"
 /usr/sbin/partx -s /dev/mmcblk0
fi

IMGFILE=/root/emmc-ext4.img
# $ partx -s emmc-ext4.img
# NR START     END SECTORS   SIZE NAME UUID
#  1  2048   35327   33280  16.3M      15673648-01
#  2 36864 1085951 1049088 512.3M      15673648-02

# TODO: Add code to validate image matches partition sizes we expect

# TODO: Write the eMMC images to the next available partition set. So
# we toggle between the partitions used every time.

# Copy the relevant partition images to the eMMC
echo "Copying BOOT partition ..."
dd if=$IMGFILE of=/dev/mmcblk0p1 bs=512 skip=2048 count=33280

echo "Copying ROOT partition ..."
dd if=$IMGFILE of=/dev/mmcblk0p5 bs=512 skip=36864 count=1049088

echo "Updating U-Boot env to boot from /dev/mmcblk0p1 with root on /dev/mmcblk0p5"

fw_setenv image_name 'Image'
fw_setenv fdt_name 'armada-3720-espressobin-v7-emmc.dtb'
fw_setenv bootcmd 'mmc dev 1; ext4load mmc 1:1 $kernel_addr $image_name; ext4load mmc 1:1 $fdt_addr $fdt_name; setenv bootargs $console root=PARTUUID=15672461-05 rw rootwait net.ifnames=0 biosdevname=0; booti $kernel_addr - $fdt_addr'

echo "Re-booting ..."
reboot

exit 0
