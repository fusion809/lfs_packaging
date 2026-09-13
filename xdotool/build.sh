#!/bin/bash
set -e
name=xdotool
repo=jordansissel/$name
version=$(gh_ver $repo)
depends=(glibc libX11 libXau libXdmcp libXext libXi libXinerama libXtst libxcb libxkbcommon)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/archive/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
make WITHOUT_RPATH_FIX=1 -j$(nproc)
sudo make PREFIX=/usr INSTALLMAN=/usr/share/man install
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
