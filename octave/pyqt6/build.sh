# Need to run sudo pip3 install pyopengl pyqt6-sip sip pyqt-builder first
# also need freeglut
pkgname=pyqt6
pkgver=6.10.2
wget -c https://pypi.python.org/packages/source/P/PyQt6/pyqt6-$pkgver.tar.gz
rm -rf pyqt6-$pkgver
tar xf pyqt6-$pkgver.tar.gz
cd pyqt6-$pkgver
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
