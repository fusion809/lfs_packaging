#!/bin/bash
set -e
# Variable declaration
name=colord
get_version() {
      local up_ver=$(wget --timeout=5 -cqO- https://www.freedesktop.org/software/colord/releases/ | grep "colord-[0-9.]*.tar.xz\"" | tail -n 1 | cut -d '"' -f 2 | sed 's/.tar.xz//g' | sed 's/colord-//g')
      ver_check "$up_ver" && return

      local git_ver=$(git ls-remote --tags --refs https://github.com/hughsie/colord.git | grep "refs/tags" | cut -d '/' -f 3 | sort -V | tail -n 1)
      ver_check "$git_ver" && return

      local arch_ver=$(aver $name)
      ver_check "$arch_ver" && return
}
version=$(get_version)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
blfs_depends=(dbus glib2 lcms2 libgudev libgusb polkit systemd vala)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c https://www.freedesktop.org/software/colord/releases/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
sudo groupadd -g 71 colord &&
sudo useradd -c "Color Daemon Owner" -d /var/lib/colord -u 71 \
        -g colord -s /bin/false colord
mkdir build
cd build
CFLAGS="-O2 -fPIC"
CXXFLAGS="-O2 -fPIC"
meson setup ..                  \
      --prefix=/usr             \
      --buildtype=release       \
      -D daemon_user=colord     \
      -D vapi=true              \
      -D systemd=true           \
      -D libcolordcompat=true   \
      -D argyllcms_sensor=false \
      -D bash_completion=false  \
      -D docs=false             \
      -D man=false              &&
ninja -j$(nproc)
sudo ninja install
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
