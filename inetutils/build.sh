#!/bin/bash
set -e
name=inetutils
version=$(gnu_ver $name)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(gcc glibc gzip make ncurses readline tar wget libxcrypt pcre2)
gnu_download $name $filename
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
echo "$version" | sudo tee /var/lib/custom-packages/$name
