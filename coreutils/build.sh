#!/bin/bash
set -e
name=coreutils
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
lfs_depends=(glibc gcc automake autoconf tar xz wget m4 make)
if ! [[ -f $filename ]]; then
    wget -c https://ftpmirror.gnu.org/$name/$filename
fi
patch_filename=$(wget -cqO- https://www.linuxfromscratch.org/lfs/view/systemd/chapter08/coreutils.html | grep "\.patch" | cut -d '/' -f 2 | sed 's/<//g')
if [[ -n $patch_filename ]] && ( ! [[ -f $patch_filename ]] ); then
    wget -c https://www.linuxfromscratch.org/patches/lfs/development/$patch_filename
fi
rm -rf $direname
tar xf $filename
cd $direname
if [[ -n $patch_filename ]]; then
    patch -Np1 -i ../$patch_filename
fi
autoreconf -fv
automake -af
FORCE_UNSAFE_CONFIGURE=1 cmi --prefix=/usr
sudo su -c "mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8"
cd ..
rm -rf $filename $patch_filename $direname
echo "$name" > /var/lib/custom-packages/$name