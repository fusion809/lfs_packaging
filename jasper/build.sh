#!/bin/bash
set -e
name=jasper
repo=$name-software/$name
version=$(gh_ver $repo)
depends=(gcc glibc libaom libde265 libheif libjpeg-turbo libwebp numactl x265)
blfs_depends=(x264)
filename="$name-version-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/archive/version-$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(-D CMAKE_INSTALL_PREFIX=/usr    \
      -D CMAKE_BUILD_TYPE=Release     \
      -D CMAKE_SKIP_INSTALL_RPATH=ON  \
      -D JAS_ENABLE_DOC=NO            \
      -D ALLOW_IN_SOURCE_BUILD=YES    \
      -D CMAKE_INSTALL_DOCDIR=/usr/share/doc/$direname)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
