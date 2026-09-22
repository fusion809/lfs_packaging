#!/bin/bash
set -e
name=vte
get_version() {
	local ver=$(gn_ver $name)
	if [[ $ver == "2.91" ]]; then
		ver=$(pkgver $name)
	fi
}
version=$(get_version)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(fast_float fmt glib2 gnutls gtk3 gtk4 icu libxml2 simdutf vala)
gng_download "$name" "$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
sudo rm -v /etc/profile.d/vte.*
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
