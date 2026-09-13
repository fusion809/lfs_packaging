#!/bin/bash
set -e
name=fltk
repo=$name/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 dbus elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glu glycin graphite2 gtk3 harfbuzz icu libICE libSM libX11 libXau libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXft libXi libXinerama libXrandr libXrender libXres libXxf86vm libepoxy libffi libjpeg-turbo libpciaccess libpng libxcb libxkbcommon libxml2 libxshmfence mesa pango pcre2 systemd util-linux wayland xz zlib zstd)
blfs_depends=(alsa-lib at-spi2-core cairo lcms2 libdrm libseccomp llvm lm-sensors pixman spirv-tools)
filename="$name-$version-source.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/releases/download/release-$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -i -e '/cat./d' documentation/Makefile &&
./configure --prefix=/usr --enable-shared
make -j$(nproc)
sudo su -c "make docdir=/usr/share/doc/$direname install &&
rm -fv /usr/lib/libfltk*.a"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
