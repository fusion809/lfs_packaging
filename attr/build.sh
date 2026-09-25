#!/bin/bash
set -e
name=attr
homepage="https://savannah.nongnu.org/projects/attr"
version=$(ngnu_ver $name)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(gcc glibc make tar wget xz)
download_src "https://download.savannah.nongnu.org/releases/$name/$filename" || download_git "https://git.savannah.nongnu.org/git/$name.git"
if [[ -f $filename ]]; then
	unpk_enter "$filename" "$direname"
elif [[ -d $name ]]; then
	unpk_enter "$name" "$version"
fi

cmi --prefix=/usr --disable-static --sysconfdir=/etc --docdir=/usr/share/doc/$direname
cd ..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
