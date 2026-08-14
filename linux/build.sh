#!/bin/bash
set -e
name=linux
#version=$(wget -cqO- https://kernel.org/ | grep "linux/kernel/v" | head -n 1 | cut -d '"' -f 2 | cut -d '/' -f 8 | sed 's/.tar.xz//g' | sed 's/linux-//g')
source ~/lfs_packaging/shared-funcs.sh
get_version() {
	local up_ver=$(wget -cqO- https://www.kernel.org/releases.json | grep -A 2 '"latest_stable":' | grep '"version":' | head -n 1 | cut -d '"' -f 4)
	if echo "$up_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$up_ver"
		return 0
	fi

	local arch_ver=$(aver $name)
	if echo "$arch_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$arch_ver"
		return 0
	fi
}

version=$(get_version)

filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"

#if ! [[ -f $filename ]]; then
	wget -c https://cdn.kernel.org/pub/linux/kernel/v$(echo $version | cut -d '.' -f 1).x/$filename
#fi

function os-release {
	cat /etc/os-release | grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.venv,venv} "PRETTY_NAME" | cut -d '"' -f 2 | cut -d ' ' -f 4
}
sudo rm -rf $direname
tar xf $filename
cd $direname
make mrproper
sudo cp /boot/config-$(uname -r) .config
make -j$(nproc)
sudo make headers_install
sudo make modules_install
sudo cp -iv arch/x86/boot/bzImage /boot/vmlinuz-$version-lfs-$(os-release)
sudo cp -iv System.map /boot/System.map-$version
sudo cp .config /boot/config-$version
sudo cp -r Documentation -T /usr/share/doc/$direname
sudo rm -rf /usr/share/doc/$(uname -r)
sudo grub-mkconfig -o /boot/grub/grub.cfg
cd ..
sudo rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
