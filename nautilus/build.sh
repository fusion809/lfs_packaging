#!/bin/bash
set -e
name=nautilus
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(acl brotli bzip2 curl cyrus-sasl elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin gnome-autoar gnome-desktop graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz icu inih jansson json-glib libX11 libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXxf86vm libadwaita libarchive libcloudproviders libepoxy libffi libfyaml libgudev libidn2 libpciaccess libpng libportal libpsl libunistring libxkbcommon libxml2 libxmlb libxshmfence lz4 mesa nghttp2 openldap openssl orc pango pcre2 sqlite systemd tinysparql util-linux vulkan-loader wayland webkitgtk xz zlib zstd)
blfs_depends=(cairo gexiv2 lcms2 libXau libXdmcp libdrm libjpeg-turbo libseccomp libtiff libunwind libwebp libxcb llvm lm-sensors pixman spirv-tools)
lfs_depends=(libelf)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
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
