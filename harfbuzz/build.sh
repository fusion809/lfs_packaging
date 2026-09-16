#!/bin/bash
set -e
name=harfbuzz
repo="$name/$name"
version=$(gh_ver $repo)
depends=(brotli bzip2 cairo expat fontconfig freetype gcc glib2 glib2 glibc graphite2 icu libffi libpng libX11 libXau libxcb libXdmcp libXext libXrender pcre2 pixman zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/releases/download/$version/$filename
fi
sudo rm -rf $direname
tar xf $filename
cd $direname
meson_options=(--prefix=/usr        \
      --buildtype=release  \
      -D graphite2=enabled)
mni "${meson_options[@]}"
cd ../..
sudo rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
