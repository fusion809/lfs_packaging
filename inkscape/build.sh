#!/bin/bash
set -e
name=inkscape
repo=$name/$name
homepage="https://inkscape.org"
description="Open-source vector graphics editing software."
version=$(gl_ver $repo)
depends=(at-spi2-core atkmm bdwgc blas-lapack boost brotli bzip2 cairo cairomm curl cyrus-sasl dbus double-conversion enchant expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glibmm24 glycin gpgme gpgmepp graphicsmagick graphite2 gsl gspell gtk3 gtkmm3 harfbuzz icu imagemagick lcms2 libassuan libcanberra libepoxy libffi libgpg-error libice libidn2 libjpeg-turbo libpng libpsl libseccomp libselinux libsigcpp2 libsm libtool libunistring libwebp libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxrandr libxrender libxres libxslt ncurses nghttp2 nspr nss openblas openjpeg openldap openssl pango pangomm pcre2 pixman poppler popt potrace readline sagemath systemd texlive tiff util-linux wayland xz zlib zstd)
_version=$(echo $version | tr '.' '_')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
_direname=$(wget -cqO- $homepage/release/$direname/source/archive/xz/dl/ | 
grep "href=\"https://media.inkscape.*$version_.*.tar.xz" -oE | rev | 
cut -d '/' -f 1 | rev | sed 's/.tar.xz//g')
src=$homepage/$(wget -cqO- $homepage/release/$direname/source/archive/xz/dl/ | 
grep "href.*$version.tar.xz" | cut -d '"' -f 2)
download_src "$src"
unpk_enter "$filename"
gap_patches "$name"
cmake_options=(-D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D WITH_INTERNAL_2GEOM=ON    \
      -W no-author)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$_direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
