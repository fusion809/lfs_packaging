# Need to run sudo pip3 install pyopengl pyqt6-sip sip pyqt-builder first
# also need freeglut
NAME=pyqt6
VERSION=$(wget -cqO- https://pypi.org/rss/project/pyqt6/releases.xml | grep "pyqt6/[0-9]" | head -n 1 | cut -d '/' -f 6)
filename="$NAME-$VERSION.tar.gz"
if ! [[ -f $filename ]]; then
	wget -c https://pypi.python.org/packages/source/P/PyQt6/$filename
fi
rm -rf ${filename/.tar.gz/}
tar xf $filename
cd ${filename/.tar.gz/}
  sip-build \
    --confirm-license \
    --no-make \
    --qmake=/opt/qt6/bin/qmake6 \
    --api-dir /opt/qt6/qsci/api/python \
    --pep484-pyi
  cd build
  make -j$(nproc)
  sudo make install
  sudo python3 -m compileall -d / /usr/lib
  sudo python3 -O -m compileall -d / /usr/lib
