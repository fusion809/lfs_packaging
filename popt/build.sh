#!/bin/bash
set -e
name=popt
repo=rpm-software-management/$name
majVer=$(echo $version | cut -d '.' -f 1)
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://ftp.osuosl.org/pub/rpm/popt/releases/popt-$majVer.x/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr --disable-static
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
