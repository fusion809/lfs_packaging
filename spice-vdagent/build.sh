#!/bin/bash
set -e
# Variable declarations
name=spice-vdagent
version=$(spice_ver $name)
docs="COPYING CHANGELOG.md README.md"
direname="$name-$version"
filename="$direname.tar.bz2"
depends=(glib2 gtk3 libX11 libXcomposite libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXres libpciaccess pango pcre2 spice-protocol wayland)
lfs_depends=(bash bzip2 coreutils dbus expat gcc glibc libffi make sed systemd tar util-linux zlib)
blfs_depends=(alsa-lib at-spi2-core brotli cairo dbus fontconfig freetype fribidi gdk-pixbuf glib glycin graphite2 gtk3 harfbuzz lcms2 libXau libXdmcp libdrm libepoxy libpng libseccomp libx11 libxcb libxinerama libxkbcommon libxrandr pixman wget)
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
configure_options=(
  --prefix=/usr \
  --libdir=/usr/lib \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --mandir=/usr/man \
  --with-init-script=systemd \
  --docdir=/usr/share/doc/$direname
)
cmi "${configure_options[@]}"
# Install an init script and an X.org configuration file
sudo install -m 0644 -D $HOME/lfs_packaging/spice-vdagent/06-spice-vdagent.conf \
  /usr/share/X11/xorg.conf.d/06-spice-vdagent.conf.new

sudo mkdir -p /usr/share/doc/$direname
sudo cp -a $docs /usr/share/doc/$direname
# Cleanup and add to database
cd ..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
