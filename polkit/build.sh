#!/bin/bash
set -e
# Variable declaration
name=polkit
version=$(gh_ver "$name-org/$name")
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
blfs_depends=(duktape glib2 libxslt linux-pam systemd)
lfs_depends=(expat glibc libffi systemd util-linux zlib)
depends=(glib2 linux-pam pcre2)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c https://github.com/polkit-org/polkit/archive/$version/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
#sudo groupadd -fg 27 polkitd &&
#sudo useradd -c "PolicyKit Daemon Owner" -d /etc/polkit-1 -u 27 \
#        -g polkitd -s /bin/false polkitd
mkdir build
cd build
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
meson setup ..                     \
      --prefix=/usr                \
      --buildtype=release          \
      -D man=false                 \
      -D session_tracking=logind
ninja -j$(nproc)
sudo ninja install
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
