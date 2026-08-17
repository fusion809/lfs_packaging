#!/bin/bash
set -e
# Variable declaration
name=dconf
function pkgver {
	wget -cqO- https://gitlab.gnome.org/GNOME/$1/-/tags | grep "tags/" | cut -d '/' -f 6 | sed 's/".*//g' | grep -v "alpha\|beta\|\.rc" | head -n 1 | sed 's/^v//g'
}
version="$(pkgver $name)"
edVersion="$(pkgver $name-editor)"
filename="$name-$version.tar.xz"
edFilename="$name-editor-$edVersion.tar.xz"
direname="${filename/.tar.xz/}"
edDirename="${edFilename/.tar.xz/}"
blfs_depends=(at-spi2-core brotli cairo dconf fontconfig freetype fribidi gdk-pixbuf glycin gnome-shell graphite2 gsettings-desktop-schemas harfbuzz itstool lcms2 libXau libXdmcp libepoxy libhandy libpng libseccomp libsoup libxcb libxkbcommon nautilus pixman vte webkitgtk)
lfs_depends=(bzip2 dbus expat gcc glibc libffi systemd util-linux zlib)
depends=(glib2 gtk3 libX11 libXcomposite libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXres pango pcre2 wayland)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/dconf/$(echo "${version}" | sed 's/.[0-9]$//g')/$filename
fi

if ! [[ -f $edFilename ]]; then
	wget -c https://download.gnome.org/sources/dconf-editor/$(echo $edVersion | sed 's/.[0-9]$//g')/$edFilename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
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
echo $version > /var/lib/custom-packages/$name
