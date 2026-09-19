#!/bin/bash
set -e
name=psmisc
version=$(gl_ver "$name/$name")
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(coreutils gcc make ncurses tar xz)
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://sourceforge.net/projects/psmisc/files/psmisc/$filename
fi
unpk_enter "$filename" "$direname"
cmi --prefix=/usr
cd ..
echo $version | sudo tee /var/lib/custom-packages/$name
