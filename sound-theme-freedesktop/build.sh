#!/bin/bash
set -e
name=sound-theme-freedesktop
repo=deepin-community/$name
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -cqO- -T 5 -t 1 https://people.freedesktop.org/\~mccann/dist/ | grep "sound-theme-freedesktop-[0-9]+\.[0-9]+" -oE | sed 's/sound-theme-freedesktop-//g' | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	echop $(gh_ver $repo)
}
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://people.freedesktop.org/~mccann/dist/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
