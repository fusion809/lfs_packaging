#!/bin/bash
set -e
name=psmisc
homepage="https://gitlab.com/psmisc/psmisc"
description="Miscellaneous procfs tools"
version=$(gl_ver "$name/$name")
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(coreutils gcc make ncurses tar xz)
sf_download "$name" "" "$filename"
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
cd ..
echo $version | sudo tee /var/lib/custom-packages/$name
