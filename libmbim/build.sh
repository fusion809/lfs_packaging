#!/bin/bash
set -e
name=libmbim
repo=mobile-broadband/$name
version=$(gfd_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(glib2)
gfd_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
meson_options=(--prefix=/usr            \
      --buildtype=release      \
      -D bash_completion=false \
      -D man=false)
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
