#!/bin/bash
set -e
name=libsecret
description="Library for storing and retrieving passwords and other secrets"
homepage="https://wiki.gnome.org/Projects/Libsecret"
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(glib2 glibc libffi libgcrypt libgpg-error pcre2 systemd util-linux zlib)
majVer=$(echo $version | cut -d '.' -f1-2)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(--prefix=/usr --buildtype=release -D gtk_doc=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
