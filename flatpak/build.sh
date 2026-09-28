#!/bin/bash
set -e
# Variable declarations
name=flatpak
homepage="https://flatpak.org"
description="Cross-distribution Linux package manager."
repo=$name/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
depends=(acl appstream avahi bash brotli bubblewrap bzip2 coreutils curl cyrus-sasl dbus dbus dconf e2fsprogs expat fontconfig freetype fuse gcab gcc gdk-pixbuf glib glib2 glibc glycin gpgme json-glib keyutils lcms2 libarchive libarchive libassuan libcap libffi libfyaml libgpg-error libidn2 libpng libpsl libseccomp libsoup libunistring libxau libxau libxml2 libxmlb llvm lz4 meson mitkrb nghttp2 ninja openldap openssl ostree pcre2 polkit polkit python socat sqlite systemd tar util-linux wayland wayland webkitgtk xdg-dbus-proxy xdg-utils xz zlib zstd)
pip_depends=(gobject)
# libmalcontent is listed for Arch, but seems to run for my uses without it
# Fetch and unpack source
ghr_download "$repo" "${version}" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
meson_options=(
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
)
mni "${meson_options[@]}"
cd ..
sudo chmod +x /etc/profile.d/flatpak.sh
sudo mkdir -p /usr/share/doc/$direname
sudo cp -a \
  COPYING NEWS \
  /usr/share/doc/$direname
# Cleanup and add to database
cd ..
sudo rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
