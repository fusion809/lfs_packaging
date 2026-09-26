#!/bin/bash
set -e
name=wireplumber
homepage="https://pipewire.pages.freedesktop.org/wireplumber/"
description="Session / policy manager implementation for PipeWire"
repo="pipewire/wireplumber"
version=$(gfd_ver $repo)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
depends=(glib2 lua pipewire systemd)
gfd_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release -D system-lua=true
sudo su -c "mv -v /usr/share/doc/wireplumber{,-$version}"
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
