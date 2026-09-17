#!/bin/bash
set -e
name=shared-mime-info
repo=xdg/$name
version=$(gfd_ver $repo $name)
depends=(gcc glib2 glibc icu libxml2 pcre2)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gfd_download $repo "$version" "$filename"
unpk_enter "$filename" "$direname"
options=(
	--prefix=/usr         \
    --buildtype=release   \
	-D update-mimedb=true \
    -D build-tests=false  \
	-D build-spec=false
)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
