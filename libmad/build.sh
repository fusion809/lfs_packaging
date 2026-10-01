#!/bin/bash
set -e
name=libmad
homepage="https://www.underbit.com/products/mad/"
description="A high-quality MPEG audio decoder."
repo="tenacityteam/libmad"
version=$(cb_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
cbr_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$name"
cmaki -D CMAKE_INSTALL_PREFIX=/usr -D CMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5
sudo su -c '
cat > /usr/lib/pkgconfig/mad.pc << "EOF"
prefix=/usr
exec_prefix=${prefix}
libdir=${exec_prefix}/lib
includedir=${prefix}/include

Name: mad
Description: MPEG audio decoder
Requires:
Version: 0.15.1b
Libs: -L${libdir} -lmad
Cflags: -I${includedir}
EOF'
cd ../..
rm -rf "$filename" "$name"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
