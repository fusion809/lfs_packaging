#!/bin/bash
set -e
name=libshumate
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 cairo e2fsprogs elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz icu json-glib keyutils lcms2 libdrm libelf libepoxy libffi libgudev libidn2 libjpeg-turbo libpciaccess libpng libpsl libseccomp libsoup libtiff libunistring libunwind libwebp libX11 libXau libxcb libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxml2 libXrandr libXrender libxshmfence libXxf86vm llvm lm-sensors mesa mitkrb nghttp2 orc pango pcre2 pixman protobuf-c spirv-tools sqlite systemd util-linux vulkan-loader wayland xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://download.gnome.org/sources/$name/$majVer/$filename
fi
unpk_enter "$filename" "$direname"
options=(--prefix=/usr --buildtype=release --wrap-mode=nodownload \
            -D gtk_doc=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
