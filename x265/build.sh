#!/bin/bash
set -e
name=x265
repo=Multicorewareinc/$name
version=$(bb_ver $repo $name)
filename="${name}_$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(cmake nasm)
ghr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
sed -i 's/FORMAT_ELF/UNIX64 \&\& FORMAT_ELF/' source/common/x86/cpu-a.asm
mkdir bld &&
cd    bld &&

cmake -D CMAKE_INSTALL_PREFIX=/usr \
      -D GIT_ARCHETYPE=1           \
      -W no-author                 \
      ../source                    &&
maki
sudo rm -vf /usr/lib/libx265.a
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
