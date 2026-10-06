#!/bin/bash
set -e
name=glycin
description="Sandboxed and extendable image decoding."
homepage="https://gitlab.gnome.org/GNOME/glycin"
version=$(gn_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(brotli bubblewrap bzip2 cairo dav1d elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz highway icu lcms2 libaom libde265 libdrm libepoxy libffi libglvnd libgudev libheif libjpeg-turbo libjxl libogg libpng librsvg libseccomp libunwind libwebp libx11 libxau libxcb libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxrandr libxrender mesa numactl orc pango pcre2 pixman rust systemd tiff util-linux vala vulkan-loader wayland x264 x265 xz zlib zstd)
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
