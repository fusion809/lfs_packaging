#!/bin/bash
set -e
name=fltk
repo=$name/$name
version=$(gh_ver $repo)
depends=(alsa-lib at-spi2-core brotli bzip2 cairo dbus elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glu glycin graphite2 gtk3 harfbuzz icu lcms2 libdrm libepoxy libffi libice libjpeg-turbo libpciaccess libpng libseccomp libSM libX11 libxau libxcb libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXft libXi libXinerama libxkbcommon libxml2 libXrandr libXrender libXres libxshmfence libXxf86vm llvm lm-sensors mesa pango pcre2 pixman spirv-tools systemd util-linux wayland xz zlib zstd)
filename="$name-$version-source.tar.gz"
direname="${filename/-source.tar.*/}"
ghr_download "$repo" "release-$version" "$filename"
unpk_enter "$filename" "$direname"
sed -i -e '/cat./d' documentation/Makefile &&
./configure --prefix=/usr --enable-shared
make -j$(nproc)
sudo su -c "make docdir=/usr/share/doc/$direname install &&
rm -fv /usr/lib/libfltk*.a"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
