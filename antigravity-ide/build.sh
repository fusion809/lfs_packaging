#!/bin/bash
set -e
name=antigravity-ide
homepage="https://antigravity.google/product/antigravity-ide"
description="Agentic development platform from Google based on VSCode."
depends=(alsa-lib at-spi2-core avahi bash brotli bzip2 cairo coreutils cups curl cyrus-sasl dav1d dbus e2fsprogs elfutils enchant expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gst-plugins-base gstreamer gtk3 harfbuzz highway icu keyutils lcms2 libaom libarchive libavif libdrm elfutils libepoxy libffi libgcrypt libglvnd libgpg-error libgudev libidn2 libjpeg-turbo libjxl libopenssl3 libpng libpsl libseccomp libsecret libsoup libtasn1 libunistring libunwind libwebp libx11 libxau libxcb libxcomposite libxcrypt libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxkbfile libxml2 libxrandr libxrender libxres libxslt mesa mitkrb nghttp2 nspr nss openldap openssl orc pango pcre2 pixman sed sqlite svt-av1 systemd tar util-linux wayland webkitgtk wget xz zlib zstd)
version=$(aurver $name)
_build=$(aurver $name "_build")
filename="Antigravity IDE.tar.gz"
direname="${filename/.tar.gz/}"
download_src "https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/$version-$_build/linux-x64/$filename"
unpk_enter "$filename" "$direname"
sudo mkdir -p /usr/share/$name
sudo ln -sf /usr/share/antigravity/bin/$name /usr/bin/
sudo cp -r * /usr/share/$name
sudo tee /usr/share/applications/$name.desktop << EOF
[Desktop Entry]
Name=Antigravity IDE
Comment=Experience liftoff
GenericName=Text Editor
Exec=/usr/share/$name/bin/$name %F
Icon=$name
Type=Application
StartupNotify=false
StartupWMClass=$name
Categories=TextEditor;Development;IDE;
MimeType=application/x-antigravity-workspace;
Actions=new-empty-window;
Keywords=vscode;

[Desktop Action new-empty-window]
Name=New Empty Window
Name[cs]=Nové prázdné okno
Name[de]=Neues leeres Fenster
Name[es]=Nueva ventana vacía
Name[fr]=Nouvelle fenêtre vide
Name[it]=Nuova finestra vuota
Name[ja]=新しい空のウィンドウ
Name[ko]=새 빈 창
Name[ru]=Новое пустое окно
Name[zh_CN]=新建空窗口
Name[zh_TW]=開新空視窗
Exec=/usr/share/$name/bin/$name --new-window %F
Icon=$name
EOF
sudo cp ../$name.png /usr/share/pixmaps/
cd ..
sudo rm -rf "$direname" "$filename"
echo $version | sudo tee /var/lib/custom-packages/$name
