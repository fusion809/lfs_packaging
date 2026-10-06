#!/bin/bash
set -e
name=graphviz
description="Graph visualization software."
homepage="https://www.graphviz.org"
repo=$name/$name
version=$(gl_ver $repo)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
depends=(avahi brotli bzip2 cairo cmake cups curl cyrus-sasl dav1d dbus double-conversion expat fontconfig freetype fribidi gcc gdk-pixbuf ghostscript glib2 glibc glycin gmp gpgme gpgmepp graphite2 gtk3 harfbuzz icu java lcms2 libassuan libepoxy libffi libglvnd libgpg-error libice libidn2 libjpeg-turbo libpaper libpng libpsl librsvg libseccomp libsm libtool libunistring libwebp libx11 libxau libxcb libxcomposite libxcrypt libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxrandr libxrender libxt libxtst lua nghttp2 nspr nss openjpeg openldap openssl pango pcre2 perl pixman python qt6 ruby systemd texlive tiff util-linux wayland webkitgtk xorg-libs xz zlib zstd)
gla_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
sed '/ORIGIN/d' -i lib/CMakeLists.txt
mkdir -p build &&
cd    build &&

cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      ..                           &&

sed -i '/GZIP/s/:.*$/=/' CMakeCache.txt &&

make -j$(nproc)
sudo make install
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
