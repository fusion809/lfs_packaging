#!/bin/bash
set -e
# Variable declarations
name=spice-vdagent
version=$(spice_ver $name)
docs="COPYING CHANGELOG.md README.md"
direname="$name-$version"
filename="$direname.tar.bz2"
depends=(libpciaccess spice-protocol)
lfs_depends=(bash coreutils glibc make sed systemd tar)
blfs_depends=(alsa-lib dbus glib gtk3 libdrm
libx11 libxinerama libxrandr # Xorg libraries
wget)
# Fetch and unpack source
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://www.spice-space.org/download/releases/$filename
fi
tar xvf $filename
# Compile and install
cd $direname
  # Set proper paths
  sed -i 's|/etc/sysconfig/spice-vdagentd|/etc/conf.d/spice-vdagentd|
' data/spice-vdagentd.service
  sed -i 's|/etc/sysconfig/spice-vdagentd|/etc/conf.d/spice-vdagentd|' data/spice-vdagentd.1.in
  sed -i 's/strstr(addr, "\/pci");/(char *)strstr(addr, "\/pci");/' src/vdagent/device-info.c
autoreconf -fi
export CFLAGS="-O2 -fPIC -Wno-error"
export CXXFLAGS="-O2 -fPIC -Wno-error"
./configure \
  --prefix=/usr \
  --libdir=/usr/lib \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --mandir=/usr/man \
  --with-init-script=systemd \
  --docdir=/usr/share/doc/$direname

make -j$(nproc)
sudo make install DESTDIR=/
# Install an init script and an X.org configuration file
sudo install -m 0644 -D $HOME/lfs_packaging/spice-vdagent/06-spice-vdagent.conf \
  /usr/share/X11/xorg.conf.d/06-spice-vdagent.conf.new

sudo mkdir -p /usr/share/doc/$direname
sudo cp -a $docs /usr/share/doc/$direname
# Cleanup and add to database
cd ..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
