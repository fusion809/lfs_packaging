#!/bin/bash
name=dhcpcd
repo="NetworkConfiguration/dhcpcd"
version=$(gh_ver "$repo")
direname="$name-$version"
filename="$direname.tar.xz"
lfs_depends=(glibc openssl bash systemd)

if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/releases/download/v$version/$filename
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

cmi "${configure_options[@]}"
sudo strip /usr/bin/dhcpcd
sudo strip /usr/lib/dhcpcd/dev/udev.so
cd ..
sudo install -Dm644 "$name.service" "/usr/lib/systemd/system"
sudo install -Dm644 "${name}_.service" "/usr/lib/systemd/system/${name}@.service"
rm -rf "$direname" "$filename"
echo "$version" > /var/lib/custom-packages/$name
