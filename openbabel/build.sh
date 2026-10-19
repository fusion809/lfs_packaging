#!/bin/bash
set -e
name=openbabel
repo=$name/$name
homepage="https://openbabel.org/"
description="Library to convert between multiple chemical file formats."
version=$(gh_ver $repo)
_version=$(echo $version | tr '.' '-')
filename="$name-$_version.tar.gz"
direname="$name-${filename/.tar.*/}"
depends=(at-spi2-core boost brotli bzip2 cairo coordgen dbus eigen enchant expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gspell gtk3 harfbuzz icu inchi libepoxy libffi libice libjpeg-turbo libnotify libpng libseccomp libselinux libsm libwebp libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxrandr libxrender libxres libxtst maeparser nanosvg pango pcre2 pixman python rapidjson sdl3 systemd tiff util-linux wayland wxwidgets-gtk3 xz zlib zstd)
gha_download "$repo" "$name-$_version" "$filename"
unpk_enter "$filename" "$direname"
sed -i 's/wxwxMenuItemListNode [*]node/auto node/' src/GUI/OBGUI.cpp
cmake_options=(-DCMAKE_INSTALL_PREFIX=/usr \
    -DRUN_SWIG=ON \
    -DPYTHON_BINDINGS=ON \
    -DOPENBABEL_USE_SYSTEM_INCHI=ON)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
