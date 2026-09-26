#!/bin/bash
set -e
name=bluez
homepage="http://www.bluez.org/"
description="Daemons for the bluetooth protocol stack"
repo=$name/$name
version=$(gh_ver $repo)
depends=(dbus gcc glib2 glibc icu libical ncurses pcre2 readline systemd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
# Kernel config options required
download_src "https://www.kernel.org/pub/linux/bluetooth/$filename"
unpk_enter "$filename" "$direname"
options=(
    --prefix=/usr         \
    --sysconfdir=/etc     \
    --localstatedir=/var  \
    --enable-library
)
cmi "${options[@]}"
sudo su -c "ln -svf ../libexec/bluetooth/bluetoothd /usr/sbin
install -v -dm555 /etc/bluetooth &&
install -v -m644 src/main.conf /etc/bluetooth/main.conf"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
