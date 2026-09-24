#!/bin/bash
set -e
# Variable declarations
name=spice-vdagent
version=$(spice_ver $name)
docs="COPYING CHANGELOG.md README.md"
direname="$name-$version"
filename="$direname.tar.bz2"
depends=(alsa-lib at-spi2-core bash brotli bzip2 cairo coreutils dbus dbus expat fontconfig freetype fribidi gcc gdk-pixbuf glib glib2 glibc glycin graphite2 gtk3 gtk3 harfbuzz lcms2 libdrm libepoxy libffi libpciaccess libpng libseccomp libx11 libX11 libxau libxcb libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libxinerama libXinerama libxkbcommon libxrandr libXrandr libXrender libXres make pango pcre2 pixman sed spice-protocol systemd tar util-linux wayland wget zlib)
# Fetch and unpack source
spice_download "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
# Set proper paths
sed -i 's|/etc/sysconfig/spice-vdagentd|/etc/conf.d/spice-vdagentd|
' data/spice-vdagentd.service
sed -i 's|/etc/sysconfig/spice-vdagentd|/etc/conf.d/spice-vdagentd|' data/spice-vdagentd.1.in
sed -i 's/strstr(addr, "\/pci");/(char *)strstr(addr, "\/pci");/' src/vdagent/device-info.c
sudo autoreconf -fi
sudo chown $USER -R .
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
echo $version | sudo tee /var/lib/custom-packages/$name
