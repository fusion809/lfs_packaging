#!/bin/bash
set -e
name=wayland
repo=$name/$name
version=$(way_ver $name)
depends=(coreutils expat gcc glibc libffi libxml2 meson ninja tar wget xz)
filename="$name-$version.tar.gz"
direname="$name-$version"
gfd_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
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
echo "$version" | sudo tee /var/lib/custom-packages/$name
