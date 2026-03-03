# Need to run sudo pip3 install pyopengl pyqt6-sip sip pyqt-builder first
# also need freeglut
set -e
# Variable declarations
name=pyqt6
version=$(wget -cqO- https://pypi.org/rss/project/pyqt6/releases.xml | grep "pyqt6/[0-9]" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '/' -f 6)
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=()
lfs_depends=(bash coreutils glibc gcc make python sed tar)
blfs_depends=(dbus qt6 wget)
pip_depends=(pyopengl pyqt6-sip pyqt-builder sip)
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://pypi.python.org/packages/source/P/PyQt6/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
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
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version > /var/lib/lfs-custom-packages/$name