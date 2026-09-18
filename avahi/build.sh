#!/bin/bash
set -e
name=avahi
repo=lathiat/$name
version=$(gh_ver $repo | sed -E 's/^version=([0-9.]+)(rc[0-9]+)$/version=\1-\2/')
depends=(at-spi2-core brotli bzip2 cairo dbus expat fontconfig freetype fribidi gcc gdbm gdk-pixbuf glib2 glibc glycin graphite2 gtk3 harfbuzz lcms2 libcap libdaemon libepoxy libffi libpng libseccomp libX11 libXau libxcb libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libXrandr libXrender libXres pango pcre2 pixman systemd util-linux wayland zlib)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
gap_patches "$name" || echo "Applying patches failed... Continuing with build anyway"
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
