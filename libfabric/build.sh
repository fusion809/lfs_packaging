#!/bin/bash
set -e
# Variable declarations
name=libfabric
version=$(gh_ver "ofiwg/libfabric")
filename="$name-$version.tar.bz2"
direname=${filename/.tar.bz2/}
depends=(glib2 libX11 libXext libXxf86vm libpciaccess libxshmfence mesa numactl pcre2 wayland)
lfs_depends=(autoconf bash bzip2 coreutils dbus expat gcc glibc libelf libffi make sed systemd tar util-linux xz zlib zstd)
blfs_depends=(brotli double-conversion fontconfig freetype graphite2 harfbuzz libXau libXdmcp libdrm libpng libxcb libxkbcommon libxml2 llvm lm-sensors qt6 spirv-tools wget)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://github.com/ofiwg/libfabric/releases/download/v$version/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
autoreconf -fvi
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./configure --prefix=/usr
sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
maki
# Cleanup and add to database
cd ..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
