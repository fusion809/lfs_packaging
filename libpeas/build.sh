#!/bin/bash
set -e 
name=libpeas
version=$(gn_ver libpeas)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(glib2 glibc gtk3)
gn_download "$filename"
unpk_enter "$filename" "$direname"
meson_options=(
    --prefix=/usr          \
    --buildtype=release    \
    --wrap-mode=nofallback \
	-D python3=false)
mni "${meson_options[@]}"
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
