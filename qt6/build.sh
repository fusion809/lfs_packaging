#!/bin/bash
set -e
name=qt6
repo=qt/qtbase
version=$(gh_ver $repo)
majMinVer=$(echo $version | cut -d '.' -f1-2)
depends=(at-spi2-core avahi bluez brotli bzip2 cairo cups dav1d dbus double-conversion e2fsprogs elfutils expat fdk-aac ffmpeg flac fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gtk3 harfbuzz icu jasper keyutils lame lcms2 libaom libde265 libdrm libepoxy libevdev libffi libheif libice libinput libjpeg-turbo libmng libogg libpciaccess libpng libseccomp libSM libsndfile libtiff libva libvorbis libvpx libwebp libx11 libxau libxcb libxcomposite libxcrypt libxcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxml2 libXrandr libXrender libXres libxshmfence libXxf86vm llvm lm-sensors mesa mitkrb mpg123 mtdev numactl openssl opus pango pcre2 pixman pulseaudio spirv-tools sqlite svt-av1 systemd util-linux wayland x264 x265 xcb-util xcb-util-cursor xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm xz zlib zstd)
filename="qt-everywhere-src-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://download.qt.io/archive/qt/$majMinVer/$version/single/$filename"
unpk_enter "$filename" "$direname"
export QT6PREFIX=/opt/qt6
rm -rf qtwebengine qt3d qtquick3dphysics qtopcua
./configure -prefix $QT6PREFIX   \
            -release             \
            -sysconfdir /etc/xdg \
            -dbus-linked         \
            -openssl-linked      \
            -system-sqlite       \
            -nomake examples     \
            -no-rpath            \
            -no-sbom             \
            -journald            &&
	    ninja -j$(nproc)
sudo ninja install
sudo su -c "find $QT6PREFIX/ -name \*.prl \
   -exec sed -i -e '/^QMAKE_PRL_BUILD_DIR/d' {} \;
pushd qttools/src &&

install -v -Dm644 assistant/assistant/images/assistant-128.png       \
                  /usr/share/pixmaps/assistant-qt6.png               &&

install -v -Dm644 designer/src/designer/images/designer.png          \
                  /usr/share/pixmaps/designer-qt6.png                &&

install -v -Dm644 linguist/linguist/images/icons/linguist-128-32.png \
                  /usr/share/pixmaps/linguist-qt6.png                &&

install -v -Dm644 qdbus/qdbusviewer/images/qdbusviewer-128.png       \
                  /usr/share/pixmaps/qdbusviewer-qt6.png             &&
popd &&


cat > /usr/share/applications/assistant-qt6.desktop << EOF
[Desktop Entry]
Name=Qt6 Assistant
Comment=Shows Qt6 documentation and examples
Exec=$QT6PREFIX/bin/assistant
Icon=assistant-qt6.png
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;Documentation;
EOF

cat > /usr/share/applications/designer-qt6.desktop << EOF
[Desktop Entry]
Name=Qt6 Designer
GenericName=Interface Designer
Comment=Design GUIs for Qt6 applications
Exec=$QT6PREFIX/bin/designer
Icon=designer-qt6.png
MimeType=application/x-designer;
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;
EOF

cat > /usr/share/applications/linguist-qt6.desktop << EOF
[Desktop Entry]
Name=Qt6 Linguist
Comment=Add translations to Qt6 applications
Exec=$QT6PREFIX/bin/linguist
Icon=linguist-qt6.png
MimeType=text/vnd.trolltech.linguist;application/x-linguist;
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;
EOF

cat > /usr/share/applications/qdbusviewer-qt6.desktop << EOF
[Desktop Entry]
Name=Qt6 QDbusViewer
GenericName=D-Bus Debugger
Comment=Debug D-Bus applications
Exec=$QT6PREFIX/bin/qdbusviewer
Icon=qdbusviewer-qt6.png
Terminal=false
Encoding=UTF-8
Type=Application
Categories=Qt;Development;Debugger;
EOF"
cd ..
sudo rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
