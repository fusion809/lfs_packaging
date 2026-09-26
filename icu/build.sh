#!/bin/bash
set -e
name=icu
homepage="https://icu.unicode.org"
description="International Components for Unicode library"
repo="unicode-org/$name"
version=$(gh_ver $repo)
filename="${name}4c-$version-sources.tgz"
direname="${filename/.tgz/}"
ghr_download "$repo" "release-$version" "$filename"
unpk_enter "$filename" "$name" "source"
oldVer=$(pkgver $name)
cmi --prefix=/usr
if [[ $oldVer != $version ]]; then
	sudo rm -rf /usr/lib/icu/$oldVer /usr/lib/libicu*.so.$oldVer /usr/share/icu/$oldVer
fi
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
