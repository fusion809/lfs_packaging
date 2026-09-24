#!/bin/bash
set -e
name=pinentry
repo="gpg/$name"
version=$(gh_ver $repo)
depends=(at-spi2-core brotli bzip2 cairo dbus elfutils expat fltk fontconfig freetype fribidi gcc gcr4 gdk-pixbuf glib2 glibc glycin graphite2 gtk3 harfbuzz icu lcms2 libassuan libdrm libepoxy libffi libgcrypt libgpg-error libice libpciaccess libpng libseccomp libsecret libSM libX11 libXau libxcb libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXft libXi libXinerama libxkbcommon libxml2 libXrandr libXrender libXres libxshmfence llvm lm-sensors mesa ncurses p11-kit pango pcre2 pixman spirv-tools systemd util-linux wayland xz zlib zstd)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
download_src "https://www.gnupg.org/ftp/gcrypt/$name/$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --enable-pinentry-tty
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
