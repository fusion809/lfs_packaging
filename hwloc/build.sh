#!/bin/bash
set -e
# Variable declarations
name=hwloc
repo="open-mpi/hwloc"
version=$(gh_ver $repo)
filename="$name-$version.tar.bz2"
direname=${filename/.tar.bz2/}
depends=(bash brotli bzip2 cairo coreutils expat fontconfig freetype gcc glibc libice libpciaccess libpng libSM libtool libX11 libxau libxcb libXdmcp libXext libxml2 libXrender make ncurses pixman sed systemd tar util-linux wget zlib)
# Fetch and unpack source
ghr_download "$repo" "hwloc-$version" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
configure_options=(
    --prefix=/usr \
    --sbindir=/usr/bin \
    --enable-plugins \
    --sysconfdir=/etc
)
cmi "${configure_options[@]}"
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
