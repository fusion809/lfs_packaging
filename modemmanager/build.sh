#!/bin/bash
set -e
name=modemmanger
repo=linux-mobile-broadband/ModemManager
version=$(gh_ver $repo)
depends=(glib2 glibc libffi libgudev libmbim libqmi pcre2 polkit systemd util-linux zlib)
filename="ModemManager-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/releases/download/$direname/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr            \
      --buildtype=release      \
      -D bash_completion=false \
      -D qrtr=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
