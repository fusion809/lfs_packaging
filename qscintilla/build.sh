#!/bin/bash
set -e
# Variable declarations
name=qscintilla
version=$(wget -cqO- https://www.riverbankcomputing.com/software/qscintilla/download | grep ".tar.gz" | grep -v "alpha\|beta\|[0-9]rc" | head -n 1 | cut -d '/' -f 8 | sed 's/>.*//g' | cut -d '-' -f 2 | sed 's/.tar.gz//g')
archive=QScintilla_src-$version
depends=(pyqt6)
lfs_depends=(bash coreutils make sed tar)
blfs_depends=(qt6 wget)
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
make -j$(nproc)
sudo make install
cd ../designer
qmake6 INCLUDEPATH+=../src QMAKE_LIBDIR+=../src
make -j$(nproc)
sudo make install

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
echo $version > /var/lib/lfs-custom-packages/$name