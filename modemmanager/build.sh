#!/bin/bash
set -e
name=modemmanager
homepage="https://www.freedesktop.org/wiki/Software/ModemManager/"
description="Mobile broadband modem management service"
repo=linux-mobile-broadband/ModemManager
version=$(gh_ver $repo)
depends=(glib2 glibc libffi libgudev libmbim libqmi pcre2 polkit systemd util-linux zlib)
filename="ModemManager-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
options=(--prefix=/usr            \
      --buildtype=release      \
      -D bash_completion=false \
      -D qrtr=false)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
