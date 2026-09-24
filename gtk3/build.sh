#!/bin/bash
# Originally a book package, but this script was written to fix a XSL stylesheet build failure
set -e
# Variable declarations
name=gtk3
version=$(gn_ver $name)
depends=(at-spi2-core avahi bash brotli bzip2 cairo colord coreutils cups dbus expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 harfbuzz lcms2 libepoxy libeproxy libffi libpng libseccomp libX11 libxau libxcb libXcomposite libxcrypt libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libXrandr libXrender libXres make meson openssl pango pango pcre2 pixman sed systemd tar util-linux wayland zlib)
direname="gtk-$version"
filename="$direname.tar.bz2"
# Fetch and unpack source
ggn_download "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
meson_options=(
      --prefix=/usr       \
      --buildtype=release \
      -D man=true         \
      -D broadway_backend=true
)
mni "${meson_options[@]}"
cd ../..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
