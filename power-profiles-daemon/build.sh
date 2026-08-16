#!/bin/bash
set -e
name=power-profiles-daemon
get_ver() {
      up_ver=$(wget --timeout=15 -cqO- https://gitlab.freedesktop.org/upower/power-profiles-daemon/-/tags | grep "/tags/" | head -n 1 | cut -d '"' -f 2 | cut -d '/' -f 6)
	  ver_check "$up_ver" && return
      git_ver=$(git ls-remote --tags --refs https://gitlab.freedesktop.org/upower/power-profiles-daemon.git | cut -d '/' -f 3 | sort -V | tail -n 1)
	  ver_check "$git_ver" && return
      arch_ver=$(aver $name)
	  ver_check "$arch_ver" && return
}
version=$(get_ver)
filename="$name-$version.tar.gz"
direname="$name-$version"
blfs_depends=(libgudev polkit pygobject upower)
lfs_depends=(glibc libffi systemd util-linux zlib)
depends=(glib2 pcre2 polkit)
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.freedesktop.org/upower/power-profiles-daemon/-/archive/$version/$filename
fi

rm -rf "$direname"
tar xf "$filename"
cd "$direname"
mkdir build &&
cd build &&

meson setup                \
      --prefix=/usr        \
      --buildtype=release  \
      -D gtk_doc=false     \
      -D tests=false       \
      .. &&
      ninja -j$(nproc)
sudo ninja install
cd ../..
rm -rf "$direname" "$filename"

echo "$version" > /var/lib/custom-packages/$name
