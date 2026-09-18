#!/bin/bash
set -e
name=cups
repo=OpenPrinting/$name
version=$(gh_ver $repo)
depends=(avahi dbus gcc glibc lapack libxcrypt linux-pam openssl systemd xdg-utils zlib)
filename="$name-$version-source.tar.gz"
direname="${filename/-source.tar.*/}"
# Kernel options required
ghr_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
sed -i '/& ipp->prev)/s/prev/& \&\& ipp->prev->next == *attr/' cups/ipp.c
options=(
    --libdir=/usr/lib            
    --with-rundir=/run/cups      
    --with-system-groups=lpadmin 
	--with-docdir=/usr/share/cups/doc-$version
)
cmi "${options[@]}"
sudo su -c "ln -svnf ../cups/doc-$version /usr/share/doc/$direname
echo 'ServerName /run/cups/cups.sock' > /etc/cups/client.conf"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
