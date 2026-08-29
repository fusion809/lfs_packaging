#!/bin/bash
set -e
name=grub
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
lfs_depends=(gcc glibc make tar wget xz)
if ! [[ -f $filename ]]; then
    wget -c https://ftpmirror.gnu.org/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
if ( cat /etc/fstab | grep "efi\|fat" &> /dev/null ) && [[ $(uname -m) == "x86_64" ]]; then
	cmi --prefix=/usr --sysconfdir=/etc --target=x86_64 --with-platform=efi --disable-efiemu --disable-werror
elif ( cat /etc/fstab | grep "efi\|fat" &> /dev/null ); then
	cmi --prefix=/usr --sysconfdir=/etc --target=i386 --with-platform=efi --disable-efiemu --disable-werror
else
	cmi --prefix=/usr --sysconfdir=/etc --disable-efiemu --disable-werror
fi
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
