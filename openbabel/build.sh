#!/bin/bash
set -e
name=openbabel
repo=$name/$name
homepage="https://openbabel.org/"
description="Library to convert between multiple chemical file formats."
version=$(gh_ver $repo)
_version=$(echo $version | tr '.' '-')
filename="$name-$_version.tar.gz"
direname="$name-${filename/.tar.*/}"
depends=(at-spi2-core boost brotli bzip2 cairo coordgen dbus eigen enchant expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gspell gtk3 harfbuzz icu inchi libepoxy libffi libice libjpeg-turbo libnotify libpng libseccomp libselinux libsm libwebp libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxrandr libxrender libxres libxtst maeparser nanosvg pango pcre2 pixman python rapidjson sdl3 systemd tiff util-linux wayland wxwidgets-gtk3 xz zlib zstd)
gha_download "$repo" "$name-$_version" "$filename"
unpk_enter "$filename" "$direname"
sed -i 's/wxwxMenuItemListNode [*]node/auto node/' src/GUI/OBGUI.cpp
cmake_options=(-DCMAKE_INSTALL_PREFIX=/usr \
    -DRUN_SWIG=ON \
    -DPYTHON_BINDINGS=ON \
    -DOPENBABEL_USE_SYSTEM_INCHI=ON)
cmaki "${cmake_options[@]}"
cat > /usr/share/applications/openbabel.desktop << EOF
[Desktop Entry]
Name=OpenBabel GUI
Icon=openbabel
Exec=/usr/bin/obgui %F
TryExec=/usr/bin/obgui
Type=Application
Version=1.0
MimeType=chemical/x-pdb;chemical/pdby;chemical/x-mol2;chemical/x-mdl-molfile;chemical/x-mdl-sdfile;chemical/x-xyz;chemical/x-macromodel-input;chemical/x-vmd;
Categories=Science;Chemistry;Education;
StartupWMClass=obgui
EOF
sudo wget -c "https://upload.wikimedia.org/wikipedia/commons/c/ce/Open_Babel_computer_icon.png" -O /usr/share/pixmaps/openbabel.png
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
