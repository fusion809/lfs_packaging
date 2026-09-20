# Need to run sudo pip3 install pyopengl pyqt6-sip sip pyqt-builder first
# also need freeglut
set -e
# Variable declarations
name=pyqt6
get_version() {
  local inst_ver=$(pkgver $name)
  local art_ver=$(artver $name)
  local up_ver=$(wget -T 5 -cqO- https://pypi.org/rss/project/pyqt6/releases.xml | grep "pyqt6/[0-9]" | grep -v "alpha\|beta\|rc" | head -n 1 | cut -d '/' -f 6)
  ver_check "$up_ver" "$inst_ver" "$art_ver" && return
  local vat_ver=$(vatver $name)
  ver_check "$vat_ver" "$inst_ver" "$art_ver" && return

  local arch_ver=$(aver $name)
  ver_check "$arch_ver" "$inst_ver" "$art_ver" && return
  fver "$name" "$inst_ver"
}
version=$(get_version)
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(bash brotli bzip2 coreutils dbus dbus double-conversion e2fsprogs expat flac fontconfig freetype gcc glib2 glibc graphite2 harfbuzz keyutils lame libdrm libelf libffi libogg libpciaccess libpng libsndfile libvorbis libX11 libXau libxcb libXdmcp libXext libxkbcommon libxml2 libxshmfence libXxf86vm llvm lm-sensors make mesa mitkrb mpg123 openssl opus pcre2 pulseaudio python qt6 sed spirv-tools systemd tar wayland wget xz zlib zstd)
pip_depends=(pyopengl pyqt6-sip pyqt-builder sip)
# Fetch and unpack source
download_src "https://pypi.python.org/packages/source/P/PyQt6/$filename"
unpk_enter "$filename" "$direname"
# Compile and install
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
#sudo python3 -m compileall -d / /usr/lib
#sudo python3 -O -m compileall -d / /usr/lib
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
