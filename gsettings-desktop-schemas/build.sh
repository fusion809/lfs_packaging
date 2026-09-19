#!/bin/bash
set -e
name=gsettings-desktop-schemas
repo=GNOME/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
sed -i -r 's:"(/system):"/org/gnome\1:g' schemas/*.in
options=(
	--prefix=/usr \
	--buildtype=release)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
