#!/bin/bash
set -e
name=systemd
homepage="https://systemd.io/"
description="system and service manager"
repo=$name/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
_version=$(lfs_ver $name)
_filename="$name-man-pages-$_version.tar.xz"
direname="${filename/.tar.*/}"
depends=(acl bash coreutils dbus glibc gzip hwdata kbd kmod lz4 meson ninja openssl pcre2 tar util-linux wget xz)
gha_download "$repo" "v$version" "$filename"
download_src "https://anduin.linuxfromscratch.org/LFS/$_filename"
unpk_enter "$filename" "$direname"
sed -e 's/GROUP="render"/GROUP="video"/' \
    -e 's/GROUP="sgx", //'               \
    -i rules.d/50-udev-default.rules.in
meson_options=(
    --prefix=/usr           \
      --buildtype=release     \
      -D default-dnssec=no    \
      -D firstboot=false      \
      -D install-tests=false  \
      -D ldconfig=false       \
      -D sysusers=false       \
      -D rpmmacrosdir=no      \
      -D homed=disabled       \
      -D man=disabled         \
      -D mode=release         \
      -D pamconfdir=no        \
      -D dev-kvm-mode=0660    \
      -D nobody-group=nogroup \
      -D sysupdate=disabled   \
      -D ukify=disabled       \
      -D docdir=/usr/share/doc/$direname
)
echo "Rm systemd-udev-control.socket as it causes build failure"
sudo rm -rf /usr/lib/systemd/system/systemd-udev-control.socket
mni "${meson_options[@]}"
sudo tar -xf ../../$_filename \
    --no-same-owner --strip-components=1 \
    -C /usr/share/man
cd ../..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
echo "$_version" | sudo tee -a /var/lib/custom-packages/$name
