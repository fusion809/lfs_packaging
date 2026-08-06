#!/bin/bash
set -e
name=networkmanager
up_ver=$(git ls-remote --tags https://gitlab.freedesktop.org/NetworkManager/NetworkManager.git | sed -n 's|.*refs/tags/\([0-9][0-9.]*\)$|\1|p' | sort -V | tail -1)
arch_ver=$(wget -cqO- -T 10 "https://gitlab.archlinux.org/archlinux/packaging/packages/lzip/-/raw/main/PKGBUILD" | grep "^pkgver=" | cut -d '=' -f 2)
version="${up_ver:-$arch_ver}"

blfs_depends=(libndp curl glib2 iptables libpsl newt nss polkit pygobject systemd vala wpa_supplicant)
filename="NetworkManager-$version.tar.xz"
direname="${filename/.tar.xz/}"

if ! [[ -f "$filename" ]]; then
	wget -c https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/releases/$version/downloads/$filename
fi

tar xf "$filename"
cd "$direname"
grep -rl '^#!.*python$' | xargs sed -i '1s/python/&3/'
mkdir build &&
cd    build &&

meson setup ..                    \
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
      -D modem_manager=false      &&
docbookver=$(cat /var/lib/book-packages/docbook-xsl-nons | head -n 1)
sed -i -e "s|http://docbook.sourceforge.net/release/xsl/current/manpages/docbook.xsl|/usr/share/xml/docbook/xsl-stylesheets-nons-$docbookver/manpages/docbook.xsl|g" build.ninja meson-info/intro-targets.json
ninja -j$(nproc)
sudo ninja install
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
