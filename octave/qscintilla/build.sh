#!/bin/bash
set -e
NAME=qscintilla
VERSION=$(wget -cqO- https://www.riverbankcomputing.com/software/qscintilla/download | grep ".tar.gz" | head -n 1 | cut -d '/' -f 8 | sed 's/>.*//g' | cut -d '-' -f 2 | sed 's/.tar.gz//g')
archive=QScintilla_src-$VERSION
if ! [[ -f $archive.tar.gz ]]; then
	wget -c https://www.riverbankcomputing.com/static/Downloads/QScintilla/$VERSION/$archive.tar.gz
fi
rm -rf $archive
tar xf $archive.tar.gz
cd $archive/src
export QMAKEFEATURES=$PWD/features/
export QT6DIR=/opt/qt6
export PATH=$PATH:$QT6DIR/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$QT6DIR/lib
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

#cd ../Python
#mv pyproject{-qt6,}.toml
#sip-build \
#  --no-make \
#  --qsci-features-dir ../src/features \
#  --qsci-include-dir ../src \
#  --qsci-library-dir ../src \
#  --qmake=/opt/qt6/bin/qmake6
#cd build
#make -j$(nproc)
#sudo make install
cd ../..
rm $archive*
