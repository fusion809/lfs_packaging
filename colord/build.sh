#!/bin/bash
set -e
# Variable declaration
name=colord
get_version() {
      local inst_ver=$(pkgver $name)
      local up_ver=$(wget --timeout=5 -t 1 -cqO- https://www.freedesktop.org/software/colord/releases/ | grep "colord-[0-9.]*.tar.xz\"" | tail -n 1 | cut -d '"' -f 2 | sed 's/.tar.xz//g' | sed 's/colord-//g')
      ver_check "$up_ver" "$inst_ver" && return

      local git_ver=$(timeout 5 git ls-remote --tags --refs https://github.com/hughsie/colord.git 2>/dev/null | grep "refs/tags" | cut -d '/' -f 3 | sort -V | tail -n 1)
      ver_check "$git_ver" "$inst_ver" && return

      local arch_ver=$(aver $name)
      ver_check "$arch_ver" "$inst_ver" && return

      local lfs_ver=$(lfs_ver $name)
      ver_check "$lfs_ver" "$inst_ver" && return;
}
version=$(get_version)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
blfs_depends=(dbus glib2 json-glib lcms2 libgudev libgusb libusb polkit systemd vala webkitgtk)
lfs_depends=(glibc libffi sqlite systemd util-linux zlib)
depends=(glib2 pcre2 polkit)
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
meson_options=(
      --prefix=/usr             \
      --buildtype=release       \
      -D daemon_user=colord     \
      -D vapi=true              \
      -D systemd=true           \
      -D libcolordcompat=true   \
      -D argyllcms_sensor=false \
      -D bash_completion=false  \
      -D docs=false             \
      -D man=false
)
mni "${meson_options[@]}"
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version > /var/lib/custom-packages/$name
