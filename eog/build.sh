#!/bin/bash
set -e
# Variable declaration
name=eog
version=$(gn_ver $name)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
depends=(at-spi2-core brotli bzip2 cairo dav1d dbus dconf exempi expat fontconfig freetype fribidi gcc gdk-pixbuf glib glib2 glibc glycin gnome-desktop graphite2 gtk3 gtk3 harfbuzz hicolor-icon-theme lcms lcms2 libepoxy libexif libffi libhandy libjpeg-turbo libpeas libpng libportal librsvg libseccomp libx11 libX11 libXau libxcb libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxml2 libXrandr libXrender libXres meson pango pcre2 pixman systemd util-linux wayland webkitgtk zlib)
# Fetch source and unpack it
ggn_download "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
meson_options=(
    --prefix=/usr       \
    --buildtype=release
)
mni "${meson_options[@]}"
# Cleanup and add to database
cd ../..
sudo rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
