#!/bin/bash
set -e
name=avahi
repo=lathiat/$name
version=$(gh_ver $repo | sed -E 's/^version=([0-9.]+)(rc[0-9]+)$/version=\1-\2/')
depends=(brotli bzip2 dbus expat fontconfig freetype fribidi gcc gdbm gdk-pixbuf glib2 glibc glycin graphite2 gtk3 harfbuzz libX11 libXau libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libXrandr libXrender libXres libcap libdaemon libepoxy libffi libpng libxcb libxkbcommon pango pcre2 systemd util-linux wayland zlib)
blfs_depends=(at-spi2-core cairo lcms2 libseccomp pixman)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/archive/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
gap_patches "$name"
options=(--prefix=/usr        \
    --sysconfdir=/etc    \
    --localstatedir=/var \
    --disable-static     \
    --disable-libevent   \
    --disable-mono       \
    --disable-monodoc    \
    --disable-manpages   \
    --disable-python     \
    --disable-qt3        \
    --disable-qt4        \
    --disable-qt5        \
    --enable-core-docs   \
    --with-distro=none   \
    --with-dbus-system-address='unix:path=/run/dbus/system_bus_socket')
sudo autoreconf -fiv
sudo chown $USER -R .
cmi "${options[@]}"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
