#!/bin/bash
set -e
name=gcr
repo=GNOME/${name}3
version=$(gh_ver $repo gcr)
depends=(at-spi2-core brotli bzip2 cairo dbus expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gtk3 harfbuzz lcms2 libepoxy libffi libgcrypt libgpg-error libpng libseccomp libX11 libXau libxcb libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libXrandr libXrender libXres p11-kit pango pcre2 pixman systemd util-linux wayland zlib)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
sed -i 's:"/desktop:"/org:' schema/*.xml
options=(
    --prefix=/usr \
    --buildtype=release \
    -D gtk_doc=false \
    -D ssh_agent=false
)
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
