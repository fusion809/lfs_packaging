#!/bin/bash
set -e
name=artcraft
repo=storytold/$name
description="IDE for interactive AI image and video creation."
homepage="https://getartcraft.com/apps/artcraft"
version=$(gh_ver $repo)
depends=(at-spi2-core brotli bzip2 cairo cargo-tauri dav1d dbus e2fsprogs elfutils enchant expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gst-plugins-base gstreamer gtk3 harfbuzz highway icu keyutils lcms2 libaom libavif libdrm libepoxy libffi libgcrypt libglvnd libgpg-error libgudev libidn2 libjpeg-turbo libjxl libpng libpsl libseccomp libsecret libselinux libsoup libtasn1 libunistring libunwind libwebp libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxrandr libxrender libxres libxslt mesa mitkrb nghttp2 orc pango pcre2 pixman sqlite svt-av1 systemd util-linux wayland webkitgtk xz zlib zstd)
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
export NX_DAEMON=false
export NX_ISOLATE_PLUGINS=false

# Patch unix_build.sh to skip ALL postinstalls (nx deadlocks on LFS scanning project graph)
sed -i "s|npm install --verbose|npm install --verbose --ignore-scripts|" script/artcraft/unix_build.sh
# Bypass nx for the frontend build - it deadlocks on LFS (futex in native addon)
# Patch tauri.conf.json to call vite directly instead of "npx nx run artcraft:build"
python3 - << 'PYEOF2'
import json, os
p = "crates/desktop/artcraft/tauri.conf.json"
d = json.load(open(p))
frontend = os.path.abspath("frontend/apps/artcraft")
d["build"]["beforeBuildCommand"] = "cd " + frontend + " && npx vite build --config vite.config.ts"
json.dump(d, open(p, "w"), indent=2)
print("Patched tauri.conf.json:", d["build"]["beforeBuildCommand"])
PYEOF2
script/artcraft/unix_build.sh
sudo cp -r "crates/desktop/artcraft/target/release/$name" /usr/bin/
if [[ -f "frontend/apps/artcraft/app/public/$name.svg" ]]; then
	sudo cp -r "frontend/apps/artcraft/app/public/$name.svg" /usr/share/icons/hicolor/scalable/apps/ai.storyteller.$name.svg
else
	sudo wget -c https://github.com/storytold/artcraft/raw/refs/heads/main/frontend/apps/artcraft/app/public/artcraft-icon.svg -O /usr/share/icons/hicolor/scalable/apps/ai.storyteller.$name.svg
fi
sudo magick -background none /usr/share/icons/hicolor/scalable/apps/ai.storyteller.$name.svg -resize 1024x /usr/share/pixmaps/ai.storyteller.$name.png
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
