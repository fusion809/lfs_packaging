#!/bin/bash
set -e
name=ruby
homepage="https://www.ruby-lang.org/en/downloads/branches/"
repo=$name/$name
version=$(gh_ver $repo)
majVer=$(echo $version | cut -d '.' -f1-2)
depends=(gcc glibc gmp libffi libxcrypt libyaml openssl zlib)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://cache.ruby-lang.org/pub/ruby/$majVer/$filename"
unpk_enter "$filename" "$direname"
./configure --prefix=/usr --disable-rpath       \
            --enable-shared       \
            --without-valgrind    \
            --without-baseruby    \
            ac_cv_func_qsort_r=no \
            --docdir=/usr/share/doc/$direname
make -j$(nproc)
oldVer=$(pkgver $name)
oldMajMinVer=$(echo $oldVer | cut -d '.' -f1-2)
if [[ $oldVer != $version ]]; then
	sudo rm -rf /usr/lib/ruby/$oldVer /usr/lib/ruby/gems/$oldVer
	sudo rm -rf /usr/lib/libruby.so.$oldMajMinVer
fi
sudo su -c "XDG_DATA_HOME=/tmp make install"
cd ../
sudo rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
