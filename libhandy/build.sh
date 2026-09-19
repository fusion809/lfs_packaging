#!/bin/bash
set -e
# Variable declaration
name=libhandy
version=$(gn_ver libhandy)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
depends=(at-spi2-core brotli bzip2 cairo dbus expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gtk3 gtk3 harfbuzz lcms2 libepoxy libffi libpng libseccomp libX11 libXau libxcb libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libXrandr libXrender libXres pango pcre2 pixman systemd util-linux vala wayland webkitgtk zlib)
# Fetch source and unpack it
gn_download "$filename"
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
meson_options=(
	--prefix=/usr       \
    --buildtype=release
)
mni "${meson_options[@]}"
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
