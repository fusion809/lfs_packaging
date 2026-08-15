#!/bin/bash
set -e
# Variable declarations
name=appstream
version=$(gh_ver "ximion/appstream")
docs="AUTHORS CHANGELOG.md COPYING README"
depends=()
lfs_depends=(freetype2 gcc glibc)
blfs_depends=(curl itstool libfyaml libxml2 libxmlb libxslt docbook-xsl-nons qt6)
pip_depends=()
upName=AppStream;
direname="$upName-$version"
filename="$direname.tar.xz"
# Fetch and unpack source
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://www.freedesktop.org/software/appstream/releases/$filename
fi
tar xvf $filename
# Compile and install
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
# sed no longer needed for 1.1.4+ (xsl-ns -> xsl change was for older versions)
mkdir build
cd build
meson setup --prefix=/usr            \
            --buildtype=release      \
            -D apidocs=false         \
            -D bash-completion=false \
            -D stemming=false        \
            -D man=false        .. &&
ninja -j$(nproc)
sudo ninja install
sudo mv -v /usr/share/doc/appstream{,-$version}
# Cleanup and add to database
cd ..
rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
