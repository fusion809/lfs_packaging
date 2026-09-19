#!/bin/bash
set -e
name=popt
repo=rpm-software-management/$name
version=$(gh_ver $repo)
majVer=$(echo $version | cut -d '.' -f 1)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://ftp.osuosl.org/pub/rpm/popt/releases/popt-$majVer.x/$filename
fi
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
