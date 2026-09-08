#!/bin/bash
set -e
name=slang
repo=shader-$name/$name
version=$(gh_ver $repo)
depends=(gcc glibc glslang)
blfs_depends=(spirv-tools)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.jedsoft.org/releases/slang/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr       \
            --sysconfdir=/etc   \
	    --with-readline=gnu)
cmi "${options[@]}"
make -j1 RPATH=
sudo su -c "make install_doc_dir=/usr/share/doc/$direname   \
     SLSH_DOC_DIR=/usr/share/doc/$direname/slsh \
     RPATH= install"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
