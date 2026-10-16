#!/bin/bash
set -e
name=gexiv2
repo=GNOME/$name
homepage="https://wiki.gnome.org/Projects/gexiv2"
DESCRIPTION="Gexiv2 is a GObject-based wrapper around the Exiv2 library."
version=$(gh_ver $repo)
depends=(brotli curl cyrus-sasl exiv2 expat gcc glib2 glibc inih libffi libidn2 libpsl libselinux libunistring nghttp2 openldap openssl pcre2 systemd util-linux zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release

# Compatibility symlinks for consumers expecting unversioned gexiv2 (e.g. GEGL, GIMP)
api_ver=$(echo "$version" | cut -d. -f1,2)
if [[ -f "/usr/lib/libgexiv2-$api_ver.so" ]]; then
	sudo ln -sfn "libgexiv2-$api_ver.so" /usr/lib/libgexiv2.so
fi
if [[ -f "/usr/lib/pkgconfig/gexiv2-$api_ver.pc" ]]; then
	sudo ln -sfn "gexiv2-$api_ver.pc" /usr/lib/pkgconfig/gexiv2.pc
fi
if [[ -d "/usr/include/gexiv2-$api_ver/gexiv2" ]]; then
	sudo rm -rf /usr/include/gexiv2
	sudo ln -sfn "gexiv2-$api_ver/gexiv2" /usr/include/gexiv2
fi

cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
