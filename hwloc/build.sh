#!/bin/bash
set -e
# Variable declarations
name=hwloc
version=$(gh_ver "open-mpi/hwloc")
filename="$name-$version.tar.bz2"
direname=${filename/.tar.bz2/}
depends=(bash brotli bzip2 cairo coreutils expat fontconfig freetype gcc glibc libICE libpciaccess libpng libSM libtool libX11 libXau libxcb libXdmcp libXext libxml2 libXrender make ncurses pixman sed systemd tar util-linux wget zlib)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/open-mpi/hwloc/releases/download/hwloc-$version/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
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
