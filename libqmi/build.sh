#!/bin/bash
set -e
name=libqmi
repo=mobile-broadband/$name
version=$(gfd_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(glib2 libgudev libmbim)
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.freedesktop.org/$repo/-/archive/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
meson_options=(--prefix=/usr            \
      --buildtype=release      \
      -D bash_completion=false \
      -D qrtr=false            \
      -D man=false)
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
