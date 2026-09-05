#!/bin/bash
set -e
name=glycin
version=$(gn_ver $name)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(bubblewrap fontconfig glib2 lcms2 libseccomp rustc libheif libjxl librsvg vala)
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/glycin/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -e "s/get_option('libglycin-gtk4')/(& or get_option('glycin-thumbnailer'))/" \
    -i meson.build
meson_options=(--prefix=/usr           \
            --buildtype=release     \
            -D libglycin-gtk4=false \
	    -D tests=false)
export PATH=$PATH:/opt/rustc/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rustc/lib
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
