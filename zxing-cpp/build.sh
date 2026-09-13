#!/bin/bash
set -e
name=zxing-cpp
repo=$name/$name
version=$(gh_ver $repo)
depends=(gcc glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/releases/download/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(-D CMAKE_INSTALL_PREFIX=/usr \
      -D ZXING_C_API=OFF           \
      -D ZXING_EXAMPLES=OFF        \
      -D ZXING_WRITERS=BOTH        \
      -W no-author)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
