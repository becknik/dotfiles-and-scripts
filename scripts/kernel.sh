#! /bin/bash

if [ "$EUID" != 0 ] ; then 
	echo "Please run this script again as root!"
	exit
fi

echo
echo "********************************************************************************"
echo "Current kernel version: " $(uname -r)
echo "Warning: release candidate or custom versioned kernels have to be compiled and installed manually"

equery list gentoo-sources
read -p "Kernel version-number to be build: " versionNumber

linuxdir="/usr/src/linux-$versionNumber-gentoo"
userConfDir="/home/jnnk/docs/linux/gentoo/kernel"
cd $linuxdir

echo
echo "Copying .config..."
cp /home/jnnk/docs/linux/gentoo/kernel/.config /usr/src/linux-$versionNumber-gentoo/.config
make olddefconfig
#$linuxdir/srips/config --enable $userConfDir/
#$linuxdir/srips/config --disbale $userConfDir/
#$linuxdir/srips/config --module $userConfDir/
#make defconfig

echo
echo "********************************************************************************"
echo "Starting compilation..."
make -j6
make modules_install
make install

dracut --zstd --early-microcode --force --kver $versionNumber-gentoo

echo
echo "********************************************************************************"
echo "DON'T FORGETT TO UPDATE \"/boot/refind_linux.conf\" INITRAMFS!"
echo "DON'T FORGETT TO CLEAN UP \"/boot\" and \"/usr/src/\" occasionally"
echo "DON'T FORGETT TO RUN \"emerge --oneshot @module-rebuild\" after reboot!"

# Cleanup... (TODO)
#cd /usr/src
