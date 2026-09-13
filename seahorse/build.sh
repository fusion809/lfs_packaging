#!/bin/bash
set -e
name=seahorse
repo=GNOME/$name
version=$(gh_ver $repo)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
depends=(at-spi2-core brotli bzip2 cairo cracklib cyrus-sasl dbus e2fsprogs expat fontconfig freetype fribidi gcc gcr gdk-pixbuf glib2 glibc glycin gpgme graphite2 gtk3 harfbuzz keyutils lcms2 libX11 libXau libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libXrandr libXrender libXres libassuan libepoxy libffi libgcrypt libgpg-error libhandy libidn2 libpng libpsl libpwquality libseccomp libsecret libsoup libunistring libxcb libxkbcommon mitkrb nghttp2 openldap openssl p11-kit pango pcre2 pixman sqlite systemd util-linux wayland zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://download.gnome.org/sources/seahorse/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -i "/GPGME_EVENT_NEXT_TRUSTITEM/d" pgp/seahorse-gpgme.c
sed -i -r 's:"(/apps):"/org/gnome\1:' data/*.xml &&
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
