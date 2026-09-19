#!/bin/bash
set -e
name=libwacom
repo=linuxwacom/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(glib2 glibc libevdev libffi libgudev libxml2 pcre2 systemd)
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/linuxwacom/libwacom/releases/download/$direname/$filename
fi
unpk_enter "$filename" "$direname"
sudo rm -rf /usr/share/libwacom
meson_options=(--prefix=/usr       \
      --buildtype=release \
      -D tests=disabled)
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
