#!/bin/bash
set -e
name=alsa-lib
repo=alsa-project/$name
version=$(gh_ver $repo)
depends=(glibc)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
# Kernel config options required
if ! [[ -f $filename ]]; then
	wget -c https://www.alsa-project.org/files/pub/lib/$filename
fi
conf_filename="alsa-ucm-conf-$version.tar.bz2"
if ! [[ -f $conf_filename ]]; then
	wget -c https://www.alsa-project.org/files/pub/lib/$conf_filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr
sudo su -c "tar -C /usr/share/alsa --strip-components=1 -xf ../$conf_filename"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
