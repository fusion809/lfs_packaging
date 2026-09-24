#!/bin/bash
set -e
name=gcr3
repo=GNOME/${name}
version=$(gh_ver $repo)
depends=(at-spi2-core brotli bzip2 cairo dbus expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gtk3 harfbuzz lcms2 libepoxy libffi libgcrypt libgpg-error libpng libseccomp libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxrandr libxrender libxres p11-kit pango pcre2 pixman systemd util-linux wayland zlib)
filename="${name/3/}-$version.tar.xz"
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
