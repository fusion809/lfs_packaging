#!/bin/bash
set -e
# Variable declaration
name=eog
version=$(gn_ver $name)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
lfs_depends=(bzip2 dbus expat gcc glibc libffi systemd util-linux zlib)
depends=(glib2 gtk3 libX11 libXcomposite libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXres pango pcre2 wayland)
blfs_depends=(at-spi2-core brotli cairo dav1d dconf exempi fontconfig freetype fribidi gdk-pixbuf glib glycin gnome-desktop graphite2 gtk3 harfbuzz hicolor-icon-theme lcms lcms2 libXau libXdmcp libepoxy libexif libhandy libjpeg-turbo libpeas libpng libportal librsvg libseccomp libx11 libxcb libxkbcommon libxml2 meson pixman webkitgtk)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.gnome.org/GNOME/$name/-/archive/$version/$filename
fi
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
sudo rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
