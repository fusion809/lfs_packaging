#!/bin/bash
set -e 
name=dhcpcd
homepage="https://roy.marples.name/projects/dhcpcd/"
description="DHCP/ IPv4LL/ IPv6RA/ DHCPv6 client"
repo="NetworkConfiguration/dhcpcd"
version=$(gh_ver "$repo")
direname="$name-$version"
filename="$direname.tar.xz"
depends=(bash glibc openssl systemd)
ghr_download "$repo" "v$version" "$filename"
download_src "https://gitlab.archlinux.org/archlinux/packaging/packages/dhcpcd/-/raw/main/dhcpcd.service?ref_type=heads" "dhcpcd.service"
download_src "https://gitlab.archlinux.org/archlinux/packaging/packages/dhcpcd/-/raw/main/dhcpcd_.service?ref_type=heads" "dhcpcd_.service"
unpk_enter "$filename" "$direname"
configure_options=(
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
echo "$version" | sudo tee /var/lib/custom-packages/$name
