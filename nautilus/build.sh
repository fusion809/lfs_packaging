#!/bin/bash
set -e
name=nautilus
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(acl brotli bzip2 cairo curl cyrus-sasl elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf gexiv2 glib2 glibc glycin gnome-autoar gnome-desktop graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz icu inih jansson json-glib lcms2 libadwaita libarchive libcloudproviders libdrm libelf libepoxy libffi libfyaml libgudev libidn2 libjpeg-turbo libpciaccess libpng libportal libpsl libseccomp libtiff libunistring libunwind libwebp libX11 libXau libxcb libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxml2 libxmlb libXrandr libXrender libxshmfence libXxf86vm llvm lm-sensors lz4 mesa nghttp2 openldap openssl orc pango pcre2 pixman spirv-tools sqlite systemd tinysparql util-linux vulkan-loader wayland webkitgtk xz zlib zstd)
majVer=$(echo $version | cut -d '.' -f 1)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://download.gnome.org/sources/$name/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr --buildtype=release -D selinux=disabled)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
