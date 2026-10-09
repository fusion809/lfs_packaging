#!/bin/bash
set -e
# Variable declarations
name=pcre2
homepage="https://www.pcre.org"
description="Library that implements Perl 5-style regular expressions. 2nd version."
repo=PCRE2Project/pcre2
version=$(gh_ver $repo)
filename="$name-$version.tar.bz2"
direname="$name-$name-$version"
depends=(bash bzip2 coreutils glibc gzip make ncurses readline sed tar wget zlib)
# Fetch and unpack source
gha_download "$repo" "${filename/.tar.*/}" "$filename"
gha_download "zherczeg/sljit" "master" "sljit-master.tar.gz"
unpk_enter "$filename" "$direname"
rm -rf deps/sljit
tar xf ../sljit-master.tar.gz
mv sljit-master sljit 
mv sljit deps/sljit
# Compile and install
sudo systemctl restart ntpd
sudo ./autogen.sh
configure_options=(
    --enable-jit
    --enable-pcre2-16
    --enable-pcre2-32
    --enable-pcre2grep-libbz2
    --enable-pcre2grep-libz
    --enable-pcre2test-libreadline
    --prefix=/usr
  )
CFLAGS+="-O2 -fPIC -ffat-lto-objects"
CXXFLAGS+="-O2 -fPIC -ffat-lto-objects"
cmi "${configure_options[@]}"
# Cleanup and add to database
cd ..
sudo rm -rf ${filename} $direname
echo $version | sudo tee /var/lib/custom-packages/$name
