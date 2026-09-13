#!/bin/bash
set -e
name=pciutils
repo=$name/$name
version=$(gh_ver $repo)
depends=(glibc kmod openssl systemd xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://mj.ucw.cz/download/linux/pci/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -r '/INSTALL/{/PCI_IDS|update-pciids /d; s/update-pciids.8//}' \
    -i Makefile
make -j$(nproc) PREFIX=/usr                \
     SHAREDIR=/usr/share/hwdata \
     SHARED=yes
sudo su -c "make PREFIX=/usr                \
     SHAREDIR=/usr/share/hwdata \
     SHARED=yes                 \
     install install-lib        &&

chmod -v 755 /usr/lib/libpci.so"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
