#!/bin/bash
set -e
name=konsole
version=$(curl -sL https://download.kde.org/stable/release-service/ | perl -nle 'while (m{href="\K[0-9]+\.[0-9]+\.[0-9]+}g) { print $& }' | sort -V | tail -n 1)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.kde.org/stable/release-service/$version/src/$filename
fi

if ! [[ -f "konsole-adjust_scrollbar-1.patch" ]]; then
	wget -c https://www.linuxfromscratch.org/patches/blfs/svn/konsole-adjust_scrollbar-1.patch
fi

export KF6_PREFIX=/usr
export QT6DIR=/opt/qt6
export QT6PREFIX=/opt/qt6
export PATH=$PATH:$QT6DIR/bin
export CMAKE_PREFIX_PATH=$QT6PREFIX:$KF6_PREFIX:$CMAKE_PREFIX_PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$QT6DIR/lib
tar xf $filename
cd $direname
( patch -N -f  -Np1 -i ../konsole-adjust_scrollbar-1.patch ) || echo "[WARNING] Patch application failed, continuing build..."
cmake_options=(
	-D CMAKE_INSTALL_LIBDIR=lib
	-D CMAKE_INSTALL_PREFIX=$KF6_PREFIX  
	-D CMAKE_BUILD_TYPE=Release
	-D BUILD_TESTING=OFF
	-W no-author
	-D libssh_DIR=/usr/lib/cmake/libssh
)
cmaki "${cmake_options[@]}"
cd ../..
#rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
