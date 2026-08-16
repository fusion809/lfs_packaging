#!/bin/bash
set -e
# Variable declarations
name=qscintilla
get_version() {
    local up_ver=$(wget -T 5 -cqO- https://www.riverbankcomputing.com/software/qscintilla/download | grep ".tar.gz" | grep -v "alpha\|beta\|[0-9]rc" | head -n 1 | cut -d '/' -f 8 | sed 's/>.*//g' | cut -d '-' -f 2 | sed 's/.tar.gz//g')
    ver_check "$up_ver" && return

    local arch_ver=$(aver $name)
    ver_check "$arch_ver" && return
}
version=$(get_version)
archive=QScintilla_src-$version
depends=(glib2 libX11 libXext libXxf86vm libpciaccess libxshmfence mesa pcre2 pyqt6 wayland)
lfs_depends=(bash bzip2 coreutils dbus expat gcc glibc libelf libffi make sed systemd tar xz zlib zstd)
blfs_depends=(brotli double-conversion fontconfig freetype graphite2 harfbuzz libXau libXdmcp libdrm libpng libxcb libxkbcommon libxml2 llvm lm-sensors qt6 spirv-tools wget)
pip_depends=(sip pyqt-builder)
# Fetch and unpack source
if ! [[ -f $archive.tar.gz ]]; then
	wget -c https://www.riverbankcomputing.com/static/Downloads/QScintilla/$version/$archive.tar.gz
fi
rm -rf $archive
tar xf $archive.tar.gz
# Compile and install
cd $archive/src
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
echo $version > /var/lib/custom-packages/$name