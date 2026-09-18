#!/bin/bash
set -e
# Variable declaration
name=dconf
version="$(gn_ver $name)"
edVersion="$(gn_ver $name-editor)"
filename="$name-$version.tar.xz"
edFilename="$name-editor-$edVersion.tar.xz"
direname="${filename/.tar.xz/}"
edDirename="${edFilename/.tar.xz/}"
depends=(at-spi2-core brotli bzip2 cairo dbus dconf expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin gnome-shell graphite2 gsettings-desktop-schemas gtk3 harfbuzz itstool lcms2 libepoxy libffi libhandy libpng libseccomp libsoup libX11 libXau libxcb libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libXrandr libXrender libXres nautilus pango pcre2 pixman systemd util-linux vte wayland webkitgtk zlib)
# Fetch source and unpack it
gn_download "$filename"
gn_download "$edFilename"
unpk_enter "$filename" "$direname"
meson_options=(
	--prefix=/usr       \
    --buildtype=release \
	-D man=false
)
mni "${meson_options[@]}"
cd ..              &&
tar -xf ../$edFilename &&
cd $edDirename                &&

mni "${meson_options[@]:0:2}"
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename $edFilename
echo $version | sudo tee /var/lib/custom-packages/$name
