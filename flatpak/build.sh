#!/bin/bash
set -e
# Variable declarations
name=flatpak
version=$(gh_ver $name/$name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
depends=(gcab glib2 libarchive mitkrb openldap ostree pcre2 polkit socat wayland)
lfs_depends=(acl bash bzip2 coreutils dbus e2fsprogs expat gcc glibc libcap libffi lz4 meson ninja openssl python sqlite systemd tar util-linux xz zlib zstd)
blfs_depends=(appstream avahi brotli bubblewrap curl cyrus-sasl dbus dconf fontconfig freetype fuse gdk-pixbuf glib glycin gpgme json-glib keyutils lcms2 libXau libarchive libassuan libfyaml libgpg-error libidn2 libpng libpsl libseccomp libsoup libunistring libxau libxml2 libxmlb llvm nghttp2 polkit wayland webkitgtk xdg-dbus-proxy xdg-utils)
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
