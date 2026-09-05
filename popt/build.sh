#!/bin/bash
set -e
name=popt
repo=rpm-software-management/$name
majVer=$(echo $version | sed -E 's/.[0-9]+$//g')
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://ftp.osuosl.org/pub/rpm/popt/releases/popt-$majVer.x/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr --disable-static
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
