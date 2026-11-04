#!/bin/bash
set -e
name=reshiki-git
_name=ReShiki
repo=Ameyanagi/$_name
homepage="https://reshiki.com/"
description="Vibe-coded skeletal formula sketching app written in Rust -- git."
version=$(gh_com $repo)
depends=(acl at-spi2-core brotli bzip2 cairo dbus expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gtk3 harfbuzz libcanberra libepoxy libffi libice libogg libpng libseccomp libselinux libsm libtool libvorbis libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxrandr libxrender libxres libxt ncurses pango pcre2 pixman systemd util-linux wayland zlib)
download_git "https://github.com/$repo.git"
cd $_name
git checkout $version
sed -i -e "s|application_id: \"reshiki\".into(),|application_id: \"$name\".into(),|g" src/main.rs
sed -i -e "s|{name}{} — ReShiki|{name}{} — ReShiki (git)|g" src/app.rs
cargo build --release
if [[ -f target/release/reshiki ]]; then
	sudo cp -r target/release/reshiki /usr/bin/$name
fi
sudo cp -r website/public/favicon.png /usr/share/pixmaps/$name.png
sudo tee /usr/share/applications/$name.desktop << EOF
[Desktop Entry]
Name=ReShiki (git)
Type=Application
Exec=/usr/bin/$name %U
TryExec=/usr/bin/$name
Icon=$name
MimeType=chemical/x-mdl-molfile;chemical/x-mdl-rxnfile;chemical/x-smiles;chemical/x-cml;chemical/x-inchi;
StartupNotify=true
Categories=Education;Science;Chemistry;
StartupWMClass=$name
EOF
sudo rm -rf target/release/reshiki
cd ../
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
