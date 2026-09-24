#!/bin/bash
set -e
# Variable declaration
name=gnome-terminal
version=$(gn_ver $name)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
depends=(at-spi2-core brotli bzip2 cairo dbus dconf expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin gmp gnome-shell gnutls graphite2 gsettings-desktop-schemas gtk3 harfbuzz itstool lcms2 libepoxy libffi libhandy libidn2 libpng libseccomp libtasn1 libunistring libx11 libxau libxcb libxcomposite libxcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libXrandr libXrender libXres lz4 nautilus nettle p11-kit pango pcre2 pixman simdutf systemd util-linux vte wayland webkitgtk zlib)
# Fetch source and unpack it
ggd_download "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
sed -i -r 's:"(/system):"/org/gnome\1:g' src/external.gschema.xml
meson_options=(
	--prefix=/usr       \
    --buildtype=release \
	-D docs=false
)
mni "${meson_options[@]}"
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
