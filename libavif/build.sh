#!/bin/bash
set -e
name=libavif
repo=AOMediaCodec/$name
version=$(gh_ver $repo)
depends=(glibc libaom)
blfs_depends=(dav1d svt-av1)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/archive/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(-D CMAKE_INSTALL_PREFIX=/usr \
      -D CMAKE_BUILD_TYPE=Release  \
      -D AVIF_CODEC_AOM=SYSTEM     \
      -D AVIF_CODEC_DAV1D=SYSTEM   \
      -D AVIF_CODEC_SVT=SYSTEM     \
      -D AVIF_BUILD_GDK_PIXBUF=OFF \
      -D AVIF_LIBYUV=OFF           \
      -G Ninja)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
