#!/bin/bash
set -e
# Variable declarations
name=libfabric
version=$(gh_ver "ofiwg/libfabric")
filename="$name-$version.tar.bz2"
direname=${filename/.tar.bz2/}
depends=(autoconf bash brotli bzip2 coreutils dbus double-conversion expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz libdrm libelf libffi libpciaccess libpng libX11 libXau libxcb libXdmcp libXext libxkbcommon libxml2 libxshmfence libXxf86vm llvm lm-sensors make mesa numactl pcre2 qt6 sed spirv-tools systemd tar util-linux wayland wget xz zlib zstd)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/ofiwg/libfabric/releases/download/v$version/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
sudo autoreconf -fvi
sudo chown $USER -R .
CLFAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
./configure --prefix=/usr
sed -i -e 's/ -shared / -Wl,-O1,--as-needed\0/g' libtool
maki
# Cleanup and add to database
cd ..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
