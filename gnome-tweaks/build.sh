#!/bin/bash
set -e
# Variable declaration
name=gnome-tweaks
version=$(gn_ver $name)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
depends=()
	gsettings-desktop-schemas
	libadwaita
	libgudev
	pygobject sound-theme-freedesktop)
# Fetch source and unpack it
ggn_download "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
meson_options=(
	--prefix=/usr       \
    --buildtype=release
)
mni "${meson_options[@]}"
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
