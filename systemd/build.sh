#!/bin/bash
set -e
name=systemd
repo=$name/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
_filename="$name-man-pages-$version.tar.xz"
direname="${filename/.tar.*/}"
lfs_depends=(acl bash dbus hwdata glibc kbd kmod lz4 openssl pcre2 util-linux meson ninja wget xz gzip tar coreutils)

if ! [[ -f $filename ]]; then
    wget -c https://github.com/$repo/archive/v$version/$filename
fi
if ! [[ -f $_filename ]]; then
    wget -c https://anduin.linuxfromscratch.org/LFS/$_filename
fi
rm -rf $direname
tar xf $filename
cd $direname
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
mni "${meson_options[@]}"
tar xf ../../$_filename \
    --no-same-owner --strip-components=1 \
    -C /usr/share/man
cd ../..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name