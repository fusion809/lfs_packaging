#!/bin/bash
name=pkgconf
version=$(gh_ver pkgconf/pkgconf)
lfs_depends=(bash coreutils glibc meson ninja tar xz)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"

if ! [[ -f $filename ]]; then
	wget -c https://github.com/pkgconf/pkgconf/releases/download/$direname/$filename
fi

tar xf $filename
cd "$direname"
mni --prefix=/usr --buildtype=release
sudo mv /usr/share/doc/pkgconf{,-$version}
if ! [[ -f /usr/bin/pkg-config ]]; then
	sudo ln -sv pkgconf /usr/bin/pkg-config
fi
if ! [[ -f /usr/share/man/man1/pkg-config.1 ]]; then
	sudo ln -sf pkgconf.1 /usr/share/man/man1/pkg-config.1
fi
cd ../..
rm -rf $filename $direname $mfilename
echo "$version" > /var/lib/custom-packages/$name
