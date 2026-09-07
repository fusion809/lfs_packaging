#!/bin/bash
set -e
name=kdsoap-ws-discovery-client
repo=KDE/$name
version=$(gh_ver $repo)
depends=(brotli double-conversion e2fsprogs gcc glib2 glibc icu kdsoap keyutils mitkrb openssl pcre2 systemd zlib zstd)
blfs_depends=(qt6)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.kde.org/stable/$name/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(-D CMAKE_INSTALL_PREFIX=/usr       -D CMAKE_BUILD_TYPE=Release -D CMAKE_SKIP_INSTALL_RPATH=ON  \
      -D QT_MAJOR_VERSION=6           \
      -W no-author)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
