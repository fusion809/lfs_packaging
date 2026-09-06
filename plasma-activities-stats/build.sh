#!/bin/bash
set -e
name=plasma-activities-stats
repo=KDE/$name
version=$(gh_ver $repo)
depends=(double-conversion gcc glib2 glibc icu pcre2 plasma-activities systemd zlib zstd)
blfs_depends=(kconfig qt6)
lfs_depends=(dbus)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/archive/refs/tags/v$version.tar.gz -O $filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_LIBEXECDIR=libexec -D BUILD_QT5=OFF -D BUILD_TESTING=OFF
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
