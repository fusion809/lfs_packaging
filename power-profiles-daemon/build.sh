#!/bin/bash
set -e
name=power-profiles-daemon
repo=upower/power-profiles-daemon
get_ver() {
      local inst_ver=$(pkgver $name)
      local up_ver=$(wget --timeout=5 -cqO- https://gitlab.freedesktop.org/$repo/-/tags | grep "/tags/" | head -n 1 | cut -d '"' -f 2 | cut -d '/' -f 6)
      ver_check "$up_ver" "$inst_ver" && return
      local git_ver=$(timeout 5 git ls-remote --tags --refs https://gitlab.freedesktop.org/$repo.git | cut -d '/' -f 3 | sort -V | tail -n 1)
      ver_check "$git_ver" "$inst_ver" && return
      local vat_ver=$(vatver $name)
      ver_check "$vat_ver" "$inst_ver" && return

      local arch_ver=$(aver $name)
      ver_check "$arch_ver" "$inst_ver" && return
      local lfs_vers=$(lfs_ver $name)
      ver_check "$lfs_vers" "$inst_ver" && return
      fver "$name" "$inst_ver"
}
version=$(get_ver)
filename="$name-$version.tar.gz"
direname="$name-$version"
depends=(glib2 glibc libffi libgudev pcre2 polkit polkit pygobject systemd upower util-linux zlib)
gfd_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
meson_options=(
      --prefix=/usr        \
      --buildtype=release  \
      -D gtk_doc=false     \
      -D tests=false
)
mni "${meson_options[@]}"
cd ../..
rm -rf "$direname" "$filename"

echo "$version" | sudo tee /var/lib/custom-packages/$name
