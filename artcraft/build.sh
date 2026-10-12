#!/bin/bash
set -e
name=artcraft
repo=storytold/$name
description="IDE for interactive AI image and video creation."
homepage="https://getartcraft.com/apps/artcraft"
version=$(gh_ver $repo)
depends=(cargo-tauri)
filename="$name-v$version.tar.gz"
direname="$name-${filename/.tar.*/}"
gha_download "$repo" "$name-v$version" "$filename"
unpk_enter "$filename" "$direname"
export CARGO_HOME="$PWD"
export CARGO_PROFILE_RELEASE_DEBUG=0
export CARGO_PROFILE_RELEASE_STRIP=debuginfo
export CARGO_PROFILE_RELEASE_LTO=thin
export CARGO_PROFILE_RELEASE_CODEGEN_UNITS=1
export CARGO_PROFILE_RELEASE_OPT_LEVEL=3
export CARGO_TARGET_DIR=target
export RUSTUP_TOOLCHAIN=stable
CFLAGS+=' -fno-lto'
RUSTFLAGS+=" --remap-path-prefix $PWD=/"
export SQLX_OFFLINE=true
./script/artcraft/unix_build.sh
sudo cp -r "target/release/$name" /usr/bin/
sudo cp -r "frontend/apps/artcraft/app/public/resources/images/services/$name.svg" /usr/share/icons/hicolor/scalable/ai.storyteller.$name.svg
cat > /usr/share/applications/ai.storyteller.$name.desktop << EOF
[Desktop Entry]
Type=Application
Name=ArtCraft
GenericName=Artwork creation
Comment=AI-powered artwork creation with canvas editing and 3D scene composition
Exec=artcraft %U
TryExec=artcraft
Icon=ai.storyteller.artcraft
Terminal=false
StartupNotify=true
StartupWMClass=artcraft
Categories=Graphics;AudioVideo;AudioVideoEditing;
Keywords=video;editor;film;timeline;color;grading;nle;graphics;
MimeType=image/openraster;image/vnd.adobe.photoshop;image/x-psd;image/x-psb;image/png;image/jpeg;image/tiff;image/webp;image/gif;image/bmp;image/x-tga;image/x-icon;image/vnd.microsoft.icon;image/x-portable-anymap;image/x-portable-bitmap;image/x-portable-graymap;image/x-portable-pixmap;image/x-exr;image/vnd.radiance;image/avif;image/qoi;
EOF
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
