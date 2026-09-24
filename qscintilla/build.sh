#!/bin/bash
set -e
# Variable declarations
name=qscintilla
get_version() {
	local inst_ver=$(pkgver $name)
	local art_ver=$(artver $name)
	local up_ver=$(wget -T 5 -cqO- https://www.riverbankcomputing.com/software/qscintilla/download | grep ".tar.gz" | grep -v "alpha\|beta\|[0-9]rc" | head -n 1 | cut -d '/' -f 8 | sed 's/>.*//g' | cut -d '-' -f 2 | sed 's/.tar.gz//g')
    ver_check "$up_ver" "$inst_ver" "$art_ver" && return

    local vat_ver=$(vatver $name)
    ver_check "$vat_ver" "$inst_ver" "$art_ver" && return

    local arch_ver=$(aver $name)
    ver_check "$arch_ver" "$inst_ver" "$art_ver" && return

	fver "$name" "$inst_ver"
}
version=$(get_version)
archive=QScintilla_src-$version
depends=(bash brotli bzip2 coreutils dbus double-conversion expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz libdrm libelf libffi libpciaccess libpng libX11 libxau libxcb libXdmcp libXext libxkbcommon libxml2 libxshmfence libXxf86vm llvm lm-sensors make mesa pcre2 pyqt6 qt6 sed spirv-tools systemd tar wayland wget xz zlib zstd)
pip_depends=(sip pyqt-builder)
# Fetch and unpack source
download_src "https://www.riverbankcomputing.com/static/Downloads/QScintilla/$version/$archive.tar.gz"
unpk_enter "$archive.tar.gz" "$archive" "src"
# Compile and install
export QMAKEFEATURES=$PWD/features/
export QT6DIR=/opt/qt6
export PATH=$PATH:$QT6DIR/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$QT6DIR/lib
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
qmake6
maki
cd ../designer
qmake6 INCLUDEPATH+=../src QMAKE_LIBDIR+=../src
maki

sudo tee /opt/qt6/lib/pkgconfig/Qt6Scintilla.pc << 'EOF'
prefix=/opt/qt6
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: QScintilla2 for Qt6
Description: QScintilla code editor w
idget (Qt6)
Version: 2.14.1
Libs: -L\${libdir} -lqscintilla2_qt6
Cflags: -I\${includedir}
EOF
# Cleanup and add to database
cd ../..
sudo rm -rf $archive*
echo $version | sudo tee /var/lib/custom-packages/$name
