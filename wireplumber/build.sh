#!/bin/bash
set -e
name=wireplumber
repo="pipewire/wireplumber"
version=$(gfd_ver $repo)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
blfs_depends=(lua pipewire)
depends=(glib2 systemd)
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.freedesktop.org/pipewire/wireplumber/-/archive/$version/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
mni --prefix=/usr --buildtype=release -D system-lua=true
sudo su -c "mv -v /usr/share/doc/wireplumber{,-$version}"
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
