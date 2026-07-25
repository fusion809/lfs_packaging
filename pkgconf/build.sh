#!/bin/bash
name=pkgconf
version=$(wget -cqO- https://github.com/pkgconf/pkgconf/releases | grep "/tag/pkgconf" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6 | cut -d '-' -f 2)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
mversion=$(wget -cqO- https://github.com/mesonbuild/meson/releases | grep "/tag/" | grep -v "rc" | cut -d '"' -f 6 | cut -d '/' -f 6 | head -n 1)

if ! [[ -f $filename ]]; then
	wget -c https://github.com/pkgconf/pkgconf/releases/download/$direname/$filename
fi

mfilename="meson-$mversion.tar.gz"
if ! [[ -f $mfilename ]]; then
	wget -c https://github.com/mesonbuild/meson/releases/download/$mversion/$mfilename
fi

tar xf $filename
cd "$direname"
tar xf ../$mfilename
mkdir build
cd    build

python3 ../${mfilename/.tar.gz/}/meson.py setup --prefix=/usr --buildtype=release ..
ninja -j$(nproc)
sudo ninja install
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
