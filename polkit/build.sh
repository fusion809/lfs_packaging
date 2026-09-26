#!/bin/bash
set -e
# Variable declaration
name=polkit
homepage="https://github.com/polkit-org/polkit"
description="Application development toolkit for controlling system-wide privileges"
repo="$name-org/$name"
version=$(gh_ver "$repo")
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
depends=(duktape expat glib2 glib2 glibc libffi libxslt linux-pam linux-pam pcre2 systemd systemd util-linux zlib)
# Download source, unpack and enter it
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
# Compile and install
#sudo groupadd -fg 27 polkitd &&
#sudo useradd -c "PolicyKit Daemon Owner" -d /etc/polkit-1 -u 27 \
#        -g polkitd -s /bin/false polkitd
meson_options=(
      --prefix=/usr                \
      --buildtype=release          \
      -D man=false                 \
      -D session_tracking=logind
)
mni "${meson_options[@]}"
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
