#!/bin/bash
set -e
name=at-spi2-core
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(dbus glib2 glibc libffi libX11 libxau libxcb libXdmcp libXext libXi libXres libxtst pcre2 systemd util-linux zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(
	--prefix=/usr \
	--buildtype=release \
	-D gtk2_atk_adaptor=false
)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
