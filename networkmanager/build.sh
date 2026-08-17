#!/bin/bash
set -e
name=networkmanager
version=$(gfd_ver "NetworkManager/NetworkManager")
# Deps
blfs_depends=(brotli curl cyrus-sasl glib2 iptables libidn2 libndp libpsl libunistring newt nghttp2 nspr nss polkit pygobject systemd vala wpa_supplicant)
lfs_depends=(glibc libffi ncurses openssl readline systemd util-linux zlib zstd)
depends=(glib2 openldap pcre2)
# Source file/dir
filename="NetworkManager-$version.tar.xz"
direname="${filename/.tar.xz/}"

if ! [[ -f "$filename" ]]; then
	wget -c https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/releases/$version/downloads/$filename
fi

# Unpack and build
tar xf "$filename"
cd "$direname"
grep -rl '^#!.*python$' | xargs sed -i '1s/python/&3/'
mkdir build &&
cd    build &&

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
echo "$version" > /var/lib/custom-packages/$name
