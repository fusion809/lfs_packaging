#!/bin/bash
set -e
# Variable declarations
name=orc
get_version() {
  local inst_ver=$(pkgver $name)
  local up_ver=$(wget -T 2 -cqO- https://gstreamer.freedesktop.org/src/orc/ | grep ".tar.xz\"" | grep -v "alpha\|beta\|\.rc" | cut -d '"' -f 2 | sed 's/.tar.xz//g' | cut -d '-' -f 2 | tail -n 1)
  ver_check "$up_ver" "$inst_ver" && return
  local git_ver=$(git ls-remote --tags --refs git://anongit.freedesktop.org/gstreamer/orc.git | grep "refs/tags/[0-9.]*$" | cut -d '/' -f 3 | sort -V | tail -n 1)
  ver_check "$git_ver" "$inst_ver" && return
  local arch_ver=$(aver $name)
  ver_check "$arch_ver" "$inst_ver" && return
  fver "$name" "$inst_ver"
}
version=$(get_version)
direname="$name-$version"
filename="$direname.tar.xz"
depends=()
lfs_depends=(bash coreutils meson ninja pkgconf sed tar xz)
blfs_depends=(wget)
optional_depends=(libcacard) # Provides smartcard support
docs="CONTRIBUTING.md COPYING README RELEASE ROADMAP.md"
# check if libcacard is there
if pkg-config --exists libcacard ; then
  with_cacard="--enable-smartcard"
else
  with_cacard="--disable-smartcard"
fi
# Fetch and unpack source
rm -rf $direname
if ! [[ -f $filename ]]; then
	wget -c http://gstreamer.freedesktop.org/src/$name/$filename
fi
tar xvf $filename
# Compile and install
cd $direname
mni --prefix=/usr --buildtype=release .. &&
cd ..
sudo mkdir -p /usr/share/doc/$direname
for i in $docs
do
	sudo cp -a $i /usr/share/doc/$direname
done
sudo rm -f /usr/lib*/*.la
# Cleanup and add to database
cd ..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
