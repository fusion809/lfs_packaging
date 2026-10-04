#!/bin/bash
set -e
name=emacs
repo=$name/$name
homepage="http://www.gnu.org/software/emacs/"
description="The Emacs package contains an extensible, customizable, self-documenting real-time display editor."
version=$(gh_ver $repo)
depends=(acl alsa-lib at-spi2-core attr brotli bzip2 dav1d dbus expat fontconfig freetype fribidi gcc gdk-pixbuf giflib glib2 glibc glycin gmp gnutls graphite2 gtk3 harfbuzz icu lcms2 libepoxy libffi libice libidn2 libjpeg-turbo libpng librsvg libseccomp libselinux libsm libtasn1 libunistring libwebp libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxpm libxrandr libxrender libxres ncurses nettle p11-kit pango pcre2 pixman sqlite systemd tiff util-linux wayland xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gnu_download "$name" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
sudo su -c "chown -v -R root:root /usr/share/emacs/$version &&
rm -vf /usr/lib/systemd/user/emacs.service"
cd ../
sudo rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
