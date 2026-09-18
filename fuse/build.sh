#!/bin/bash
set -e
name=fuse
repo=lib$name/lib$name
version=$(gh_ver $repo)
depends=(glibc)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "$direname" "$filename"
unpk_enter "$filename" "$direname"
meson_options=(
    --prefix=/usr \
    --buildtype=release
)
mni "${meson_options[@]}"
sudo su -c "chmod u+s /usr/bin/fusermount3 &&

cd ..                          &&
cp -Rv doc/html -T /usr/share/doc/$direname  &&
install -v -m644   doc/{README.NFS,kernel.txt} \
                   /usr/share/doc/$direname"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
