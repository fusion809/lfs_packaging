#!/bin/bash
set -e
name=cups
repo=OpenPrinting/$name
version=$(gh_ver $repo)
depends=(dbus gcc glibc lapack libxcrypt linux-pam openssl systemd zlib)
blfs_depends=(avahi xdg-utils)
filename="$name-$version-source.tar.gz"
direname="${filename/.tar.*/}"
# Kernel options required
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/releases/download/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -i '/& ipp->prev)/s/prev/& \&\& ipp->prev->next == *attr/' cups/ipp.c
options=(--libdir=/usr/lib            \
            --with-rundir=/run/cups      \
            --with-system-groups=lpadmin \
	    --with-docdir=/usr/share/cups/doc-$version)
cmi "${options[@]}"
sudo su -c "ln -svnf ../cups/doc-$version /usr/share/doc/$direname
echo 'ServerName /run/cups/cups.sock' > /etc/cups/client.conf"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
