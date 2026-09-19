#!/bin/bash
set -e
name=libpwquality
repo=$name/$name
version=$(gh_ver $repo)
depends=(cracklib glibc linux-pam zlib)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
ghr_download "$repo" "$direname" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr --disable-static --with-securedir=/usr/lib/security --disable-python-bindings
pip3 wheel -w dist --no-build-isolation --no-deps --no-cache-dir $PWD/python
sudo pip3 install --no-index --find-links dist --no-user pwquality
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
