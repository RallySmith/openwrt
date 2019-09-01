#!/bin/sh

echo "TODO: script to perform first time install"

# TODO: Provide SD (or USB) bootable system that will contain the eMMC image (<2GB)
# - and can re-partition the eMMC (if not already done) to 2 x 2GB partitions
# - write the eMMC image to the next available partition
# - set any boot configuration (if possible) to select which partition is booted
# - - uboot-envtools
#    root@OpenWrt:/# cat /etc/config/ubootenv
#    config ubootenv
#  	option dev '/dev/mtd0'
#	option offset '0x3f0000'
#	option envsize '0x10000'
#	option secsize '0x10000'
#	option numsec '1'
# - - use "uci show" to see settings
# - - In /usr/sbin
#	root@OpenWrt:/# ls -l /usr/sbin/fw_*
#	-rwxr-xr-x    1 root     root         25379 Aug 21 12:59 /usr/sbin/fw_printenv
#	lrwxrwxrwx    1 root     root            11 Aug 21 12:59 /usr/sbin/fw_setenv -> fw_printenv
# - - - fw_printenv fdt_name
# - - - fw_setenv testvar somevalue

# TODO: We need an installer script to:
# 1) If eMMC NOT our partition format then copy eMMC onto SDcard for backup
# 2) Re-partition eMMC to our format
#      16MB boot0
#      16MB boot1
#      512MB root0
#      512MB root1
#      3040MB user? (just under due to partition table)
# 3) Copy the relevant partition images to the eMMC
# 4) Update U-Boot config to boot from first eMMC partition (boot0 and root0)

# /usr/sbin/partx -P /dev/mmcblk0
# /usr/sbin/partx -P -n 1 /dev/mmcblk0

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

echo "TODO: Copy BOOT partition to /dev/mmcblk0p1"

echo "TODO: Copy ROOT partition to /dev/mmcblk0p5"

echo "TODO: Update U-Boot env to boot from /dev/mmcblk0p1 with root on /dev/mmcblk0p5"
#setenv bootcmd 'mmc dev 1; ext4load mmc 1:1 $kernel_addr $image_name; ext4load mmc 1:1 $fdt_addr $fdt_name; setenv bootargs $console root=PARTUUID=15672461-05 rw rootwait net.ifnames=0 biosdevname=0; booti $kernel_addr - $fdt_addr'
#saveenv

exit 0
