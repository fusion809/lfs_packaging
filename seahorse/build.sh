#!/bin/bash
set -e
name=seahorse
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(at-spi2-core brotli bzip2 cairo cracklib cyrus-sasl dbus e2fsprogs expat fontconfig freetype fribidi gcc gcr3 gdk-pixbuf glib2 glibc glycin gpgme graphite2 gtk3 harfbuzz keyutils lcms2 libassuan libepoxy libffi libgcrypt libgpg-error libhandy libidn2 libpng libpsl libpwquality libseccomp libsecret libsoup libunistring libX11 libXau libxcb libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libXrandr libXrender libXres mitkrb nghttp2 openldap openssl p11-kit pango pcre2 pixman sqlite systemd util-linux wayland zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
sed -i "/GPGME_EVENT_NEXT_TRUSTITEM/d" pgp/seahorse-gpgme.c
sed -i -r 's:"(/apps):"/org/gnome\1:' data/*.xml &&
mni --prefix=/usr --buildtype=release
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
