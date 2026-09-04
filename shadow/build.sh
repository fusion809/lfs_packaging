#!/bin/bash
set -e
name=shadow
repo="shadow-maint/shadow"
version=$(gh_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(acl glibc libxcrypt linux-pam systemd)
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/releases/download/$version/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \; &&
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \; &&

sed -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD YESCRYPT@' \
    -e 's@/var/spool/mail@/var/mail@'                   \
    -e '/PATH=/{s@/sbin:@@;s@/bin:@@}'                  \
    -i etc/login.defs                                   &&
./configure --sysconfdir=/etc   \
            --disable-static    \
            --without-libbsd    \
            --with-{b,yes}crypt &&
make -j$(nproc)
sudo make exec_prefix=/usr pamddir= install
sudo make -C man install-man
cd ..
sudo su -c '
for FILE in chage chpasswd login newusers passwd su
do
	install -vm644 $FILE /etc/pam.d/$FILE
done

for PROGRAM in chfn chgpasswd chsh groupadd groupdel \
               groupmems groupmod useradd userdel usermod
do
    install -v -m644 /etc/pam.d/chage /etc/pam.d/${PROGRAM}
    sed -i "s/chage/$PROGRAM/" /etc/pam.d/${PROGRAM}
done'
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
