#!/bin/bash
set -e
name=sassc
repo=sass/$name
version=$(gh_ver $repo)
librepo=sass/libsass
libver=$(gh_ver $librepo)
depends=(gcc glibc)
filename="$name-$version.tar.gz"
libfilename="libsass-$libver.tar.gz"
libdirename="${libfilename/.tar.*/}"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/archive/$version/$filename
fi
if ! [[ -f $libfilename ]]; then
	wget -c https://github.com/$librepo/archive/$version/$libfilename
fi
rm -rf "$libdirename"
tar xf "$libfilename"
cd "$libdirename"
sudo autoreconf -fi
sudo chown $USER -R .
cmi --prefix --disable-static
cd ..
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sudo autoreconf -fi
sudo chown $USER -R .
cmi --prefix=/usr
cd ../
rm -rf "$filename" "$direname" "$libfilename" "$libdirename"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
