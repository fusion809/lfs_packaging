#!/bin/bash
set -e
name=qt6
repo=qt/qtbase
version=$(gh_ver $repo)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
depends=(brotli bzip2 cups dbus double-conversion e2fsprogs elfutils expat ffmpeg fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphite2 gtk3 harfbuzz icu keyutils libICE libSM libX11 libXau libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libXrandr libXrender libXres libXxf86vm libaom libde265 libepoxy libevdev libffi libheif libpciaccess libpng libvpx libxcb libxcrypt libxkbcommon libxml2 libxshmfence mesa mitkrb mtdev numactl openssl pango pcre2 pulseaudio sqlite systemd util-linux wayland x265 xcb-util xcb-util-cursor xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm xz zlib zstd)
blfs_depends=(at-spi2-core avahi bluez cairo dav1d fdk-aac flac jasper lame lcms2 libdrm libinput libjpeg-turbo libmng libogg libseccomp libsndfile libtiff libva libvorbis libwebp llvm lm-sensors mpg123 opus pixman spirv-tools svt-av1 x264)
filename="qt-everywhere-src-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://download.qt.io/archive/qt/$majVer/$version/single/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
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
find $QT6PREFIX/ -name \*.prl \
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
EOF
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
