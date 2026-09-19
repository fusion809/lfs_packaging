#!/bin/bash
set -e
name=libass
repo=$name/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 expat fontconfig freetype fribidi glib2 glibc graphite2 harfbuzz libpng pcre2 zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/releases/download/$version/$filename
fi
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
