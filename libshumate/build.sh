#!/bin/bash
set -e
name=libshumate
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 e2fsprogs elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz icu json-glib keyutils libX11 libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXxf86vm libepoxy libffi libgudev libidn2 libpciaccess libpng libpsl libunistring libxkbcommon libxml2 libxshmfence mesa mitkrb nghttp2 orc pango pcre2 sqlite systemd util-linux vulkan-loader wayland xz zlib zstd)
blfs_depends=(cairo lcms2 libXau libXdmcp libdrm libjpeg-turbo libseccomp libsoup libtiff libunwind libwebp libxcb llvm lm-sensors pixman protobuf-c spirv-tools)
lfs_depends=(libelf)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/$name/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr --buildtype=release --wrap-mode=nodownload \
            -D gtk_doc=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
