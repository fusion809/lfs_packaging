#!/bin/bash
set -e
name=lm-sensors
repo=hramrach/$name
version=$(gh_ver $repo | sed 's/-/\./g')
_version=$(echo $version | sed 's/\./-/g')
depends=(glibc)
filename="$name-$_version.tar.gz"
direname="${filename/.tar.*/}"
# Kernel config options required, too
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/archive/V${_version}/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
make -j$(nproc) PREFIX=/usr        \
     BUILD_STATIC_LIB=0 \
     MANDIR=/usr/share/man
sudo su -c "make PREFIX=/usr        \
     BUILD_STATIC_LIB=0 \
     MANDIR=/usr/share/man install &&

install -v -m755 -d /usr/share/doc/lm-sensors-${version/./-} &&
cp -rv              README INSTALL doc/* \
                    /usr/share/doc/lm-sensors-${version/./-}"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
