#!/bin/bash
set -e
name=valgrind
version=$(wsw_ver $name)
depends=(glibc hwloc libevent libfabric numactl openmpi systemd)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
sw_download "$name" "$filename"
unpk_enter "$filename" "$direname"
sed -i 's|/doc/valgrind||' docs/Makefile.in
cmi --prefix=/usr --datadir=/usr/share/doc/$direname
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
