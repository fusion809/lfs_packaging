#!/bin/bash
set -e
name=pycairo
repo="pygobject/$name"
version=$(gh_ver $repo)
majVer=$(echo $version | sed 's/.[0-9]$//g')
depends=(cairo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "pygobject/pycairo" "v$version" "$filename"

unpk_enter "$filename" "$direname"
options=(--prefix=/usr \
	--buildtype=release)
mni "${options[@]}"
cd ../..
rm -rf $direname $filename
echo "$version" | sudo tee /var/lib/custom-packages/$name
