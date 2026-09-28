#!/bin/bash
set -e
_name=PackageKit
name=$(echo $_name | tr '[:upper:]' '[:lower:]')
repo=$_name/$_name
version=$(gh_ver $repo)
depends=(brotli bzip2 elfutils expat fontconfig freetype fribidi glib2 glibc graphite2 gstreamer harfbuzz jansson libffi libpng libunwind libx11 libxau libxcb libxdmcp libxext libxrender pango pcre2 pixman polkit sqlite systemd util-linux xz zlib zstd)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release -D man_pages=false
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
