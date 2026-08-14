#!/bin/bash
name=dhcpcd
get_version() {
	local up_ver=$(wget -c https://github.com/NetworkConfiguration/dhcpcd/releases -qO- | grep "tag/" | cut -d '/' -f 6 | cut -d '"' -f 1 | sed 's/v//g' | head -n 1)
	if echo "$up_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$up_ver"
		return 0
	fi

	local git_ver=$(git ls-remote --tags --refs https://github.com/NetworkConfiguration/dhcpcd.git | grep "refs/tags/v" | cut -d  '/' -f 3 | sed 's/^v//g' | sort -V | tail -n 1)
	if echo "$git_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$git_ver"
		return 0
	fi

	local arch_ver=$(aver $name)
	if echo "$arch_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$arch_ver"
		return 0
	fi
}

version=$(get_version)
direname="$name-$version"
filename="$direname.tar.xz"
lfs_depends=(glibc openssl bash systemd)

if ! [[ -f $filename ]]; then
	wget -c https://github.com/NetworkConfiguration/$name/releases/download/v$version/$filename
fi
if ! [[ -f "dhcpcd.service" ]]; then
	wget -c "https://gitlab.archlinux.org/archlinux/packaging/packages/dhcpcd/-/raw/main/dhcpcd.service?ref_type=heads" -O "dhcpcd.service"
	wget -c "https://gitlab.archlinux.org/archlinux/packaging/packages/dhcpcd/-/raw/main/dhcpcd_.service?ref_type=heads" -O "dhcpcd_.service"
fi

tar xf "$filename"
cd "$direname"
local configure_options=(
	--dbdir=/var/lib/$name
	--libexecdir=/usr/lib/$name
	--prefix=/usr
	--privsepuser=$name
	--runstatedir=/run
	--sbindir=/usr/bin
	--sysconfdir=/etc
)

./configure "${configure_options[@]}"
make -j$(nproc)
sudo make install
sudo strip /usr/bin/dhcpcd
sudo strip /usr/lib/dhcpcd/dev/udev.so
cd ..
sudo install -Dm644 "$name.service" "/usr/lib/systemd/system"
sudo install -Dm644 "${name}_.service" "/usr/lib/systemd/system/${name}@.service"
rm -rf "$direname" "$filename"
echo "$version" > /var/lib/custom-packages/$name
