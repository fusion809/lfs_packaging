#!/bin/bash
set -e
name=at-spi2-core
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(dbus glib2 glibc libffi libX11 libXau libxcb libXdmcp libXext libXi libXres libXtst pcre2 systemd util-linux zlib)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
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
