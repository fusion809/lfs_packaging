#!/bin/bash
name=wayland
version=$(wget -cqO- https://wayland.freedesktop.org/releases.html | grep "$name-[0-9].*.tar.xz" | grep -v ".9[0-9].tar.xz" | head -n 1 | cut -d '/' -f 8)
blfs_depends=(libxml2)
filename="$name-$version.tar.xz"
direname="$name-$version"
echo "filename=$filename"
URL="https://gitlab.freedesktop.org/wayland/wayland/-/releases/$version/downloads/$filename"
if ! [[ -f "$filename" ]]; then
	wget -c $URL 
fi

tar xf $filename
cd $direname
mkdir build &&
cd    build &&

meson setup ..            \
      --prefix=/usr       \
      --buildtype=release \
      -D documentation=false &&
ninja -j$(nproc)
sudo ninja install
cd ../..
rm -rf $direname $filename
for link in /usr/lib/libwayland*.so.[01]; do
    target=$(readlink -f "$link")
    dir=${target%/*}
    file=${target##*/}
    stem=${file%.so.*}.so

    find "$dir" -maxdepth 1 -type f -name "${stem}.*" ! -name "$file" -delete
done
echo "$version" > /var/lib/custom-packages/$name
