#!/bin/bash
set -e
source $HOME/lfs_packaging/shared-funcs.sh
name=ibus
version=$(github_ver "ibus/ibus")
filename="$name-$version.tar.gz"
direname="$name-$version"
blfs_depends=(iso-codes vala dconf glib2 gtk3 gtk4 libnotify)
lfs_depends=(wget python zip coreutils bash tar gzip)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/ibus/ibus/archive/$version/$filename
fi
if ! [[ -f "UCD.zip" ]]; then
	wget -c $(wget -cqO- https://www.linuxfromscratch.org/blfs/view/systemd/general/ibus.html | grep zip | cut -d '"' -f 2 | head -n 1)
fi
sudo rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sudo python3 -m zipfile -e ../UCD.zip /usr/share/unicode/ucd
sed -e 's@/desktop/ibus@/org/freedesktop/ibus@g' \
    -i data/dconf/org.freedesktop.ibus.gschema.xml
export SAVE_DIST_FILES=1
export NOCONFIGURE=1
#sudo ./autogen.sh --disable-gtk2 --disable-python2 --disable-emoji-dict --disable-appindicator &&
sudo autoreconf -fi

sudo ./configure --prefix=/usr          \
            --sysconfdir=/etc      \
            --disable-python2      \
            --disable-appindicator \
            --disable-gtk2         \
            --disable-emoji-dict   &&
sudo make -j$(nproc)
sudo make install
sudo gtk-query-immodules-3.0 --update-cache
cd ..
sudo rm -rf "$direname" "$filename" "UCD.zip"
echo "$version" > /var/lib/custom-packages/$name
