#!/bin/bash
set -e
name=alsa-lib
repo=alsa-project/$name
version=$(gh_ver $repo)
depends=(glibc)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
# Kernel config options required
download_src "https://www.alsa-project.org/files/pub/lib/$filename"
conf_filename="alsa-ucm-conf-$version.tar.bz2"
download_src "https://www.alsa-project.org/files/pub/lib/$conf_filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
sudo su -c "tar -C /usr/share/alsa --strip-components=1 -xf ../$conf_filename"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
