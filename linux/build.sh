#!/bin/bash
set -e
name=linux
get_base_version() {
	local up_ver=$(wget -T 5 -cqO- https://www.kernel.org/releases.json 2>/dev/null | grep -A 2 '"latest_stable":' | grep '"version":' | head -n 1 | cut -d '"' -f 4)
	if [[ -z "$up_ver" ]]; then
		up_ver=$(aver $name)
	fi
	echo "$up_ver"
}
get_version() {
	local base_ver=$(get_base_version)
	local inst_ver=$(pkgver $name)
	if [[ $base_ver =~ ^[0-9]+\.[0-9]+$ ]]; then
		ver_check "${base_ver}.0" "$inst_ver" && return
	elif [[ "$base_ver" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
		ver_check "$base_ver" "$inst_ver" && return
	else
		local arch_ver=$(aver $name)
		ver_check "$arch_ver" "$inst_ver" && return
		local lfs_ver=$(lfs_ver $name)
		ver_check "$lfs_ver" "$inst_ver" && return
		fver "$name" "$inst_ver"
	fi
}

version=$(get_version)
base_version=$(get_base_version)
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
if [[ $remote_direname != $direname ]]; then
	mv $remote_direname $direname
fi
cd $direname
make mrproper
sudo cp ../config .config
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
echo "$version" | sudo tee /var/lib/custom-packages/$name
