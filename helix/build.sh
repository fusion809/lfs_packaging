#!/bin/bash
set -e
name=helix
repo=$name-editor/$name
homepage="https://helix-editor.com/"
description="A post-modern modal text editor."
version=$(gh_ver $repo)
depends=(gcc glibc rust)
filename="$name-$version-source.tar.xz"
direname="$name-$version"
ghr_download "$repo" "$version" "$filename"
mkdir -p $direname
cd $direname
tar xf ../$filename
sed -i 's/dannylongeuay/ngalaiko/g' languages.toml
HELIX_DEFAULT_RUNTIME=/usr/lib/helix \
  cargo build --release
sudo su -c "install -vDm755  target/release/hx        \
        -t       /usr/bin/               &&
install -vdm755  /usr/lib/helix          &&
cp -vR runtime/* /usr/lib/helix          &&
rm -rf /usr/lib/helix/grammars/sources   &&

install -vDm644 contrib/Helix.desktop     \
        -t /usr/share/applications/      &&
sed -i -e 's|ConsoleOnly;$|ConsoleOnly;Development;|g' \
	/usr/share/applications/Helix.desktop
install -vDm644 contrib/Helix.appdata.xml \
        -t /usr/share/metainfo/          &&
install -vDm644 contrib/helix.png         \
        -t /usr/share/icons/hicolor/256x256/apps/"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
