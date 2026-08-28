# Need to run sudo pip3 install pyopengl pyqt6-sip sip pyqt-builder first
# also need freeglut
set -e
# Variable declarations
name=pyqt6
get_version() {
  local inst_ver=$(pkgver $name)
  local up_ver=$(wget -T 5 -cqO- https://pypi.org/rss/project/pyqt6/releases.xml | grep "pyqt6/[0-9]" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '/' -f 6)
  ver_check "$up_ver" "$inst_ver" && return
  local arch_ver=$(aver $name)
  ver_check "$arch_ver" "$inst_ver" && return
  fver "$name" "$inst_ver"
}
version=$(get_version)
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(glib2 libX11 libXext libXxf86vm libpciaccess libxshmfence mesa mitkrb pcre2 wayland)
lfs_depends=(bash bzip2 coreutils dbus e2fsprogs expat gcc glibc libelf libffi make openssl python sed systemd tar xz zlib zstd)
blfs_depends=(brotli dbus double-conversion flac fontconfig freetype graphite2 harfbuzz keyutils lame libXau libXdmcp libdrm libogg libpng libsndfile libvorbis libxcb libxkbcommon libxml2 llvm lm-sensors mpg123 opus pulseaudio qt6 spirv-tools wget)
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
maki
sudo python3 -m compileall -d / /usr/lib
sudo python3 -O -m compileall -d / /usr/lib
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name