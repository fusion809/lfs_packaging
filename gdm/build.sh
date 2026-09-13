#!/bin/bash
# Oddly seems necessary to launch GNOME via SDDM
set -e
name=gdm
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(accountsservice glib2 glibc json-glib keyutils libXau libffi libgudev libxcrypt linux-pam pcre2 polkit systemd util-linux zlib)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://download.gnome.org/sources/$name/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr        \
      --buildtype=release  \
      -D gdm-xsession=true \
      -D run-dir=/run/gdm)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
