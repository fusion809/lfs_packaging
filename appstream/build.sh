#!/bin/bash
set -e
# Variable declarations
name=appstream
version=$(gh_ver "ximion/appstream")
docs="AUTHORS CHANGELOG.md COPYING README"
depends=(glib2 openldap pcre2)
lfs_depends=(freetype2 gcc glibc libffi openssl systemd util-linux xz zlib zstd)
blfs_depends=(brotli curl cyrus-sasl docbook-xsl-nons itstool libfyaml libidn2 libpsl libunistring libxml2 libxmlb libxslt llvm nghttp2 qt6 webkitgtk)
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
