#!/bin/bash
set -e
name=qca
repo=KDE/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(cmake make-ca qt6 which)
if ! [[ -f $filename ]]; then
	wget -c https://download.kde.org/stable/$name/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -i 's@cert.pem@certs/ca-bundle.crt@' CMakeLists.txt
cmake_options=(-D CMAKE_INSTALL_PREFIX=/opt/qt6            \
      -D CMAKE_BUILD_TYPE=Release                \
      -D QT6=ON                                  \
      -D QCA_INSTALL_IN_QT_PREFIX=ON             \
      -D QCA_MAN_INSTALL_DIR:PATH=/usr/share/man)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
