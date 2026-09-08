#!/bin/bash
set -e
name=qtkeychain
repo=frankosterfeld/$name
version=$(gh_ver $repo)
depends=(dbus double-conversion gcc glib2 glibc icu libffi libgcrypt libgpg-error libsecret pcre2 qt6 systemd util-linux zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/archive/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
export QT6DIR=/opt/qt6
options=(-D CMAKE_INSTALL_PREFIX=$QT6DIR \
      -D CMAKE_BUILD_TYPE=Release     \
      -D BUILD_WITH_QT6=ON            \
      -D BUILD_TESTING=OFF            \
      -W no-author)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
