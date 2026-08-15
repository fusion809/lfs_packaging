#!/bin/bash
set -e
# Variable declarations
name=flatpak
version=$(gh_ver $name/$name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
depends=(gcab ostree socat)
lfs_depends=(bash coreutils gcc glibc meson ninja python systemd tar xz zstd)
blfs_depends=(appstream bubblewrap curl dbus dconf fuse gdk-pixbuf glib gpgme json-glib libarchive libseccomp libxau # Xorg lib
polkit wayland xdg-dbus-proxy xdg-utils)
pip_depends=(gobject)
# libmalcontent is listed for Arch, but seems to run for my uses without it
# Fetch and unpack source
sudo rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c https://github.com/flatpak/flatpak/releases/download/${version}/$filename
fi
tar xvf $filename
cd $direname
# Compile and install
mkdir build
cd build
  CFLAGS="-O2 -fPIC"
  CXXFLAGS="-O2 -fPIC"
  meson setup .. \
    --bindir=/usr/bin \
    --datadir=/usr/share \
    --includedir=/usr/include \
    --infodir=/usr/info \
    --libdir=/usr/lib \
    --libexecdir=/usr/libexec \
    --localstatedir=/var \
    --mandir=/usr/man \
    --prefix=/usr \
    --sbindir=/usr/sbin \
    --sysconfdir=/etc \
    -D man=disabled \
    -D gtkdoc=disabled \
    -D docbook_docs=disabled \
    -Ddocdir=/usr/share/doc/$name-$version \
    -Dstrip=true
  "${NINJA:=ninja}" -j$(nproc)
  DESTDIR=/ sudo $NINJA install
cd ..
sudo chmod +x /etc/profile.d/flatpak.sh
sudo mkdir -p /usr/share/doc/$direname
sudo cp -a \
  COPYING NEWS \
  /usr/share/doc/$direname
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
