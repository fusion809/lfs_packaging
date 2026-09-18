#!/bin/bash
set -e
name=gnome-keyring
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(gcr glib2 glibc libffi libgcrypt libgpg-error linux-pam p11-kit pcre2 systemd util-linux zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(
	--prefix=/usr \
	--buildtype=release)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
