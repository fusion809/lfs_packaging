#!/bin/bash
set -e
name=power-profiles-daemon
get_ver() {
      local inst_ver=$(pkgver $name)
      local up_ver=$(wget --timeout=5 -cqO- https://gitlab.freedesktop.org/upower/power-profiles-daemon/-/tags | grep "/tags/" | head -n 1 | cut -d '"' -f 2 | cut -d '/' -f 6)
      ver_check "$up_ver" "$inst_ver" && return
      local git_ver=$(timeout 5 git ls-remote --tags --refs https://gitlab.freedesktop.org/upower/power-profiles-daemon.git | cut -d '/' -f 3 | sort -V | tail -n 1)
      ver_check "$git_ver" "$inst_ver" && return
      local arch_ver=$(aver $name)
      ver_check "$arch_ver" "$inst_ver" && return
      local lfs_vers=$(lfs_ver $name)
      ver_check "$lfs_vers" "$inst_ver" && return
      fver "$name" "$inst_ver"
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
meson_options=(
      --prefix=/usr        \
      --buildtype=release  \
      -D gtk_doc=false     \
      -D tests=false
)
mni "${meson_options[@]}"
cd ../..
rm -rf "$direname" "$filename"

echo "$version" > /var/lib/custom-packages/$name
