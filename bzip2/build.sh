#!/bin/bash
set -e
name=bzip2
homepage="https://sourceware.org/bzip2/"
version=$(sw_ver $name)
depends=(coreutils gcc gzip make tar)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
sw_download "$name" "$filename"
unpk_enter "$filename" "$direname"
gap_patches "$name" || echo "Patching failed"
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
make -f Makefile-libbz2_so
make clean
make -j$(nproc)
sudo make PREFIX=/usr install
majVer=$(echo $version | cut -d '.' -f 1)
sudo su -c "cp -av libbz2.so.* /usr/lib
ln -sfv libbz2.so.$version /usr/lib/libbz2.so
ln -sfv libbz2.so.$version /usr/lib/libbz2.so.$majVer
cp -v bzip2-shared /usr/bin/bzip2
"
sudo su -c 'for i in /usr/bin/{bzcat,bunzip2}; do
  ln -sfv bzip2 $i
done
rm -fv /usr/lib/libbz2.a
'
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
