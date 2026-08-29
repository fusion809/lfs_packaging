#!/bin/bash
set -e
name=inetutils
version=$(gnu_ver $name)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
lfs_depends=(gcc glibc gzip make ncurses readline tar wget)
depends=(libxcrypt pcre2)
if ! [[ -f $filename ]]; then
    wget -c https://ftpmirror.gnu.org/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
sed -i 's/def HAVE_TERMCAP_TGETENT/ 1/' telnet/telnet.c
configure_options=(--prefix=/usr        \
        --bindir=/usr/bin    \
        --localstatedir=/var \
        --disable-logger     \
        --disable-whois      \
        --disable-rcp        \
        --disable-rexec      \
        --disable-rlogin     \
        --disable-rsh        \
        --disable-servers)
cmi "${configure_options[@]}"
sudo mv -v /usr/{,s}bin/ifconfig
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
