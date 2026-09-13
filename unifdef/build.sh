#!/bin/bash
set -e
name=unifdef
repo=fanf2/$name
version=$(gh_ver $repo)
depends=(glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://dotat.at/prog/unifdef/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -i 's/constexpr/unifdef_&/g' unifdef.c
sed -i 's/ln -s/ln -sf/' Makefile
make -j$(nproc)
sudo make prefix=/usr install
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
