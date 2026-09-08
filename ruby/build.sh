#!/bin/bash
set -e
name=ruby
repo=$name/$name
version=$(gh_ver $repo)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
depends=(gcc glibc gmp libffi libxcrypt libyaml openssl zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://cache.ruby-lang.org/pub/ruby/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
./configure --prefix=/usr --disable-rpath       \
            --enable-shared       \
            --without-valgrind    \
            --without-baseruby    \
            ac_cv_func_qsort_r=no \
            --docdir=/usr/share/doc/$direname
make -j$(nproc)
sudo su -c "XDG_DATA_HOME=/tmp make install"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
