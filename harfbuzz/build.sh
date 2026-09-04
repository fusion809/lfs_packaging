#!/bin/bash
set -e
name=harfbuzz
repo="$name/$name"
version=$(gh_ver $repo)
blfs_depends=(freetype glib2 graphite2 icu)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/releases/download/$version/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
meson_options=(--prefix=/usr        \
      --buildtype=release  \
      -D graphite2=enabled)
mni "${meson_options[@]}"
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
