#!/bin/bash
set -e
name=coreutils
homepage="https://www.gnu.org/software/coreutils/"
version=$(gnu_ver $name)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(acl attr autoconf automake gcc glibc gmp libcap m4 make openssl patch tar wget xz)
gnu_download $name $filename
unpk_enter "$filename" "$direname"
gap_patches "$name"
sudo autoreconf -fv
sudo chown $USER -R .
automake -af
FORCE_UNSAFE_CONFIGURE=1 cmi --prefix=/usr
sudo su -c "mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8"
cd ..
rm -rf $filename $patch_filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
