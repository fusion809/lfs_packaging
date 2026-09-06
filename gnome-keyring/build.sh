#!/bin/bash
set -e
name=gnome-keyring
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(glib2 glibc libffi libgcrypt libgpg-error linux-pam p11-kit pcre2 systemd util-linux zlib)
blfs_depends=(gcr)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/$name/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr --buildtype=release)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
