#!/bin/bash
set -e
name=reshiki
_name=ReShiki
repo=Ameyanagi/$_name
homepage="https://reshiki.com/"
description="Vibe-coded skeletal formula sketching app written in Rust."
version=$(gh_ver $repo)
depends=(acl at-spi2-core brotli bzip2 cairo dbus expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gtk3 harfbuzz libcanberra libepoxy libffi libice libogg libpng libseccomp libselinux libsm libtool libvorbis libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxrandr libxrender libxres libxt ncurses pango pcre2 pixman systemd util-linux wayland zlib)
filename="$_name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
wget -c https://github.com/Ameyanagi/ReShiki/pull/598.patch
wget -c https://github.com/Ameyanagi/ReShiki/pull/599.patch
patch -Np1 -i 598.patch || echo "Patching partially failed"
patch -Np1 -i 599.patch || echo "Patching partially failed"
cargo build --release
if [[ -f target/release/reshiki ]]; then
	sudo cp -r target/release/reshiki /usr/bin/
fi
sudo cp -r website/public/favicon.png /usr/share/pixmaps/$name.png
sudo tee /usr/share/applications/$name.desktop << EOF
[Desktop Entry]
Name=ReShiki
Type=Application
Exec=/usr/bin/reshiki %U
TryExec=/usr/bin/reshiki
Icon=reshiki
MimeType=chemical/x-mdl-molfile;chemical/x-mdl-rxnfile;chemical/x-smiles;chemical/x-cml;chemical/x-inchi;
StartupNotify=true
Categories=Education;Science;Chemistry;
StartupWMClass=reshiki
EOF
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
