#!/bin/bash
set -e
name=ntp
repo=$name-project/$name
version=$(gh_ver $repo)
majmVer=$(echo $version | sed -E 's/.[0-9p]+$//g')
majVer=$(echo $version | cut -d '.' -f 1)
depends=(glibc libcap libevent ncurses openssl readline)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.eecis.udel.edu/~ntp/ntp_spool/ntp$majVer/ntp-$majmVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -i 's/getclock/getclock memchr/'               sntp/m4/ntp_libntp.m4 &&
sed -i 's/pthread_detach(NULL)/pthread_detach(0)/' sntp/m4/openldap-thread-check.m4 &&
autoreconf -fiv
sed -i "/ep.*FAILED/,+4s/ep/ep2/" ntpd/ntp_io.c
gap_patches $name
options=(--prefix=/usr      \
            --bindir=/usr/sbin \
            --sysconfdir=/etc  \
            --enable-linuxcaps \
            --with-lineeditlibs=readline \
	    --docdir=/usr/share/doc/$direname)
cmi "${options[@]}"
sudo install -v -o ntp -g ntp -d /var/lib/ntp
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
