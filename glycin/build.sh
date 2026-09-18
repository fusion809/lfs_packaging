#!/bin/bash
set -e
name=glycin
version=$(gn_ver $name)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(bubblewrap fontconfig glib2 lcms2 libheif libjxl librsvg libseccomp rustc vala)
gn_download "$filename"
unpk_enter "$filename" "$direname"
sed -e "s/get_option('libglycin-gtk4')/(& or get_option('glycin-thumbnailer'))/" \
    -i meson.build
# Build without GTK4 support
meson_options=(
    --prefix=/usr           \
    --buildtype=release     \
    -D libglycin-gtk4=false \
	-D tests=false)
export PATH=/opt/rustc/bin:$PATH
export LD_LIBRARY_PATH=/opt/rustc/lib:$LD_LIBRARY_PATH
for pkg in rustc cargo rustdoc
do
	sudo ln -sf /opt/rustc/bin/$pkg /usr/bin/
done
PATH=/opt/rustc/bin:$PATH mni "${meson_options[@]}"
cd ../..
# Build with GTK4 support
unpk_enter "$filename" "$direname"
options=(
    --prefix=/usr               \
    --buildtype=release         \
    -D libglycin=false          \
    -D libglycin-gtk4=true      \
    -D glycin-loaders=false     \
	-D glycin-thumbnailer=false)
mni "${options[@]}"
for pkg in rustc cargo rustdoc
do
	sudo rm /usr/bin/$pkg
done
cd ../..
rm -rf $direname $filename
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
