#!/bin/bash
name=dhcpcd
version=10.3.2
direname="$name-$version"
filename="$direname.tar.xz"

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
