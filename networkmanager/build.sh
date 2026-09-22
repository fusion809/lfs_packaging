#!/bin/bash
set -e
name=networkmanager
repo=$name/$name
version=$(gfd_ver "$repo")
# Deps
depends=(brotli curl cyrus-sasl glib2 glib2 glibc iptables libffi libidn2 libndp libpsl libunistring ncurses newt nghttp2 nspr nss openldap openssl pcre2 polkit pygobject readline systemd systemd util-linux vala wpa_supplicant zlib zstd)
# Source file/dir
filename="NetworkManager-$version.tar.xz"
direname="${filename/.tar.xz/}"
gfdr_download "$repo" "$version" "$filename"
# Unpack and build
unpk_enter "$filename" "$direname"
grep -rl '^#!.*python$' | xargs sed -i '1s/python/&3/'

meson_options=(
    --prefix=/usr               \
    --buildtype=release         \
    -D libaudit=no              \
    -D nmtui=true               \
    -D ovs=false                \
    -D ppp=false                \
    -D nbft=false               \
    -D selinux=false            \
    -D clat=false               \
    -D qt=false                 \
    -D session_tracking=systemd \
    -D nm_cloud_setup=false     \
    -D modem_manager=false
)
mni "${meson_options[@]}"
oldVer=$(pkgver $name)
if [[ $oldVer != $version ]]; then 
	sudo rm -rf /usr/lib/NetworkManager/$oldVer
fi
sudo rm -rf /usr/share/doc/NetworkManager-$version &&
sudo mv -v /usr/share/doc/NetworkManager{,-$version}
for file in $(echo ../man/*.[1578]); do
    section=${file##*.} &&
    sudo install -vdm 755 /usr/share/man/man$section
    sudo install -vm 644 $file /usr/share/man/man$section/
    sudo cp -Rv ../docs/{api,libnm} /usr/share/doc/NetworkManager-$version
done
cd ../..
rm -rf "$direname" "$filename"
echo "$version" | sudo tee /var/lib/custom-packages/$name
