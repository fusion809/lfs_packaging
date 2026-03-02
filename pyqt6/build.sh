# Need to run sudo pip3 install pyopengl pyqt6-sip sip pyqt-builder first
# also need freeglut
set -e
depends=()
NAME=pyqt6
VERSION=$(wget -cqO- https://pypi.org/rss/project/pyqt6/releases.xml | grep "pyqt6/[0-9]" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '/' -f 6)
filename="$NAME-$VERSION.tar.gz"
direname="${filename/.tar.gz/}"
if ! [[ -f $filename ]]; then
	wget -c https://pypi.python.org/packages/source/P/PyQt6/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
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
cd ../..
sudo rm -rf $direname $filename
echo $VERSION > /var/lib/lfs-custom-packages/$NAME