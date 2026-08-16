#!/bin/bash
name=wayland
version=$(way_ver $name)
blfs_depends=(libxml2)
lfs_depends=(coreutils expat gcc glibc libffi meson ninja tar wget xz)
filename="$name-$version.tar.xz"
direname="$name-$version"
URL="https://gitlab.freedesktop.org/wayland/$name/-/releases/$version/downloads/$filename"
if ! [[ -f "$filename" ]]; then
	wget -c $URL 
fi

tar xf $filename
cd $direname
meson_options=(
    --prefix=/usr       \
    --buildtype=release \
    -D documentation=false
)
mni "${meson_options[@]}"
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
