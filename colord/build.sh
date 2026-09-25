#!/bin/bash
set -e
# Variable declaration
name=colord
repo=hughsie/colord
homepage="http://www.freedesktop.org/software/colord/"
get_version() {
      local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget --timeout=5 -t 1 -cqO- https://www.freedesktop.org/software/colord/releases/ | grep "colord-[0-9.]*.tar.xz\"" | tail -n 1 | cut -d '"' -f 2 | sed 's/.tar.xz//g' | sed 's/colord-//g')
      ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return

      local ghub_ver=$(gh_ver $repo)
      ver_check "$ghub_ver" "$inst_ver" "$lfs_vers" && return

      fver "$name" "$inst_ver"
}
version=$(get_version)
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
depends=(dbus glib2 glib2 glibc json-glib lcms2 libffi libgudev libgusb libusb pcre2 polkit polkit sqlite systemd systemd util-linux vala webkitgtk zlib)
# Fetch source and unpack it
fd_download "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
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
echo $version | sudo tee /var/lib/custom-packages/$name
