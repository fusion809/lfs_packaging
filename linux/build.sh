#!/bin/bash
set -e
name=linux
#version=$(wget -cqO- https://kernel.org/ | grep "linux/kernel/v" | head -n 1 | cut -d '"' -f 2 | cut -d '/' -f 8 | sed 's/.tar.xz//g' | sed 's/linux-//g')
get_version() {
	local up_ver=$(wget -T 5 -cqO- https://www.kernel.org/releases.json | grep -A 2 '"latest_stable":' | grep '"version":' | head -n 1 | cut -d '"' -f 4)
	ver_check "$up_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" && return
}

base_version=$(get_version)
if [[ $base_version =~ ^[0-9]+\.[0-9]+$ ]]; then
    version="${base_version}.0"
fi

remote_filename="$name-${base_version}.tar.xz"
filename="$name-$version.tar.xz"
remote_direname="${remote_filename/.tar.xz/}"
direname="${filename/.tar.xz/}"

#if ! [[ -f $filename ]]; then
wget -c https://cdn.kernel.org/pub/linux/kernel/v$(echo ${base_version} | cut -d '.' -f 1).x/${remote_filename} -O $filename
#fi

function os-release {
	cat /etc/os-release | grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.venv,venv} "PRETTY_NAME" | cut -d '"' -f 2 | cut -d ' ' -f 4
}
sudo rm -rf $direname
tar xf $filename
mv $remote_direname $direname
cd $direname
make mrproper
sudo cp /boot/config-$(uname -r) .config
make -j$(nproc)
sudo make headers_install
sudo make modules_install
sudo cp -v arch/x86/boot/bzImage /boot/vmlinuz-$version-lfs-$(os-release)
sudo cp -v System.map /boot/System.map-$version
sudo cp .config /boot/config-$version
sudo cp -r Documentation -T /usr/share/doc/$direname
if [[ "$version" != $(uname -r) ]]; then
	sudo rm -rf /usr/share/doc/$(uname -r)
fi
sudo grub-mkconfig -o /boot/grub/grub.cfg
cd ..
sudo rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
