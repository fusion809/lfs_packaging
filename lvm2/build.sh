#!/bin/bash
set -e
name=lvm2
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://sourceware.org/ftp/lvm2/ | grep -oE "LVM2.[0-9.]+" | sed 's/\.$//g' | sed 's/LVM2\.//g' | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 5 git ls-remote --tags https://sourceware.org/git/lvm2.git | cut -d '/' -f 3 | grep -oE "[0-9]+_[0-9]+_[0-9]+" | sed 's/_/\./g' | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(glibc json-c keyutils libaio libnvme ncurses openssl readline systemd util-linux)
filename="$name.$version.tgz"
direname="${filename/.tar.*/}"
# Has kernel config deps, too
if ! [[ -f $filename ]]; then
	wget -c https://sourceware.org/ftp/lvm2/$filename
fi
export PATH+=:/usr/sbin
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
./configure --prefix=/usr       \
            --enable-cmdlib     \
            --enable-pkgconfig  \
            --enable-udev_sync  &&
	    make -j$(nproc)
sudo su -c "make -C tools install_tools_dynamic &&
make -C udev  install               &&
make -C libdm install
make install
make install_systemd_units
sed -e '/locking_dir =/{s/#//;s/var/run/}' \
    -i /etc/lvm/lvm.conf"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
