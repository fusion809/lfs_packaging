#!/bin/bash
set -e
name=freetype
repo="$name/$name"
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(brotli bzip2 gcc glibc harfbuzz hdf5 libaec libpng zlib)
if ! [[ -f $filename ]]; then
	wget -c https://downloads.sourceforge.net/freetype/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -ri "s:.*(AUX_MODULES.*valid):\1:" modules.cfg &&

sed -r "s:.*(#.*SUBPIXEL_RENDERING) .*:\1:" \
    -i include/freetype/config/ftoption.h   &&

configure_options=(--prefix=/usr            \
            --disable-static         \
            --enable-freetype-config \
            --with-harfbuzz=dynamic)
cmi "${configure_options[@]}"
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
