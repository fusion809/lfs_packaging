#!/bin/bash
set -e
name=spidermonkey
homepage=""
description="Mozilla's JavaScript and WebAssembly engine written in C++ and Rust."
version=$(wget -cqO- -T 5 -t 1 https://www.linuxfromscratch.org/blfs/view/git/general/spidermonkey.html | grep firefox | head -n 1 | cut -d '-' -f 2)
filename="firefox-${version}esr.source.tar.xz"
direname="firefox-$version"
download_src "https://archive.mozilla.org/pub/firefox/releases/${version}esr/source/$filename"
unpk_enter "$filename" "$direname"
gap_patches "$name"
cat > mozconfig << "EOF"
ac_add_options --prefix=/usr
ac_add_options --enable-project=js
ac_add_options --disable-debug-symbols
ac_add_options --disable-jemalloc
ac_add_options --enable-readline
ac_add_options --enable-rust-simd
ac_add_options --with-intl-api
ac_add_options --with-system-icu
ac_add_options --with-system-zlib
EOF
export MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE=none &&
export MOZBUILD_STATE_PATH=$(pwd)/mozbuild          &&
./mach build
sudo rm -rfv /usr/lib/libmozjs-140.so
MACH_BUILD_PYTHON_NATIVE_PACKAGE_SOURCE=none sudo ./mach install
sudo su -c "rm -v /usr/lib/libjs_static.ajs &&
sed -i '/@NSPR_CFLAGS@/d' /usr/bin/js140-config
sed '$i#define XP_UNIX' -i /usr/include/mozjs-140/js-config.h"
cd ../
sudo rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
