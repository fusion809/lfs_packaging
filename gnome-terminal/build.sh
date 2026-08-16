#!/bin/bash
set -e
# Variable declaration
name=gnome-terminal
version=$(gn_ver $name)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
blfs_depends=(at-spi2-core brotli cairo dconf fontconfig freetype fribidi gdk-pixbuf glycin gnome-shell gnutls graphite2 gsettings-desktop-schemas harfbuzz itstool lcms2 libXau libXdmcp libepoxy libhandy libidn2 libpng libseccomp libtasn1 libunistring libxcb libxkbcommon nautilus nettle p11-kit pixman simdutf vte webkitgtk)
lfs_depends=(bzip2 dbus expat gcc glibc gmp libffi lz4 systemd util-linux zlib)
depends=(glib2 gtk3 libX11 libXcomposite libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXres pango pcre2 wayland)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.gnome.org/GNOME/$name/-/archive/$version/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
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
echo $version > /var/lib/custom-packages/$name
