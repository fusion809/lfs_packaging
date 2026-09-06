#!/bin/bash
set -e
name=gnome-bluetooth
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 curl cyrus-sasl elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz icu libX11 libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXxf86vm libadwaita libepoxy libffi libfyaml libgudev libidn2 libnotify libpciaccess libpng libpsl libunistring libxkbcommon libxml2 libxmlb libxshmfence mesa nghttp2 openldap openssl orc pango pcre2 systemd util-linux vulkan-loader wayland xz zlib zstd)
blfs_depends=(cairo gsound lcms2 libXau libXdmcp libcanberra libdrm libjpeg-turbo libogg libseccomp libtiff libunwind libvorbis libwebp libxcb llvm lm-sensors pixman spirv-tools upower webkitgtk)
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
sed -i 's:"/desktop:"/org:' schema/*.xml &&
options=(--prefix=/usr --buildtype=release)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
