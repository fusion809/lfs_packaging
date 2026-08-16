#!/bin/bash
set -e
# Variable declaration
name=gnome-tweaks
version=$(gn_ver $name)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
blfs_depends=(gtk4
	gsettings-desktop-schemas
	libadwaita
	libgudev
	pygobject sound-theme-freedesktop)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.gnome.org/GNOME/$name/-/archive/$version/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
meson_options=(
	--prefix=/usr       \
    --buildtype=release
)
mni "${meson_options[@]}"
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
