#!/bin/bash
# Oddly seems necessary to launch GNOME via SDDM
set -e
name=gdm
description="Display manager and login screen"
homepage="https://wiki.gnome.org/Projects/GDM"
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(accountsservice glib2 glibc json-glib keyutils libffi libgudev libxau libxcrypt linux-pam pcre2 polkit systemd util-linux zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(
      --prefix=/usr        \
      --buildtype=release  \
      -D gdm-xsession=true \
      -D run-dir=/run/gdm)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
