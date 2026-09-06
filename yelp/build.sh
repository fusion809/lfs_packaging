#!/bin/bash
set -e
name=yelp
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 curl cyrus-sasl e2fsprogs elfutils enchant expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz highway icu keyutils libX11 libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXxf86vm libadwaita libaom libepoxy libffi libfyaml libgcrypt libgpg-error libgudev libidn2 libpciaccess libpng libpsl libtasn1 libunistring libxkbcommon libxml2 libxmlb libxshmfence libxslt mesa mitkrb nghttp2 openldap openssl orc pango pcre2 sqlite systemd util-linux vulkan-loader wayland xz zlib zstd)
blfs_depends=(cairo dav1d lcms2 libXau libXdmcp libavif libdrm libjpeg-turbo libjxl libseccomp libsecret libsoup libtiff libunwind libwebp libxcb llvm lm-sensors pixman spirv-tools svt-av1 webkitgtk)
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
options=(--prefix=/usr --buildtype=release)
mni "${options[@]}"
sudo update-desktop-database
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
