#!/bin/bash
set -e
name=ntp
repo=$name-project/$name
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -cqO- -T 5 -t 1 https://github.com/$repo/tags | grep "NTP_[0-9_P]+" -oE | sed 's/NTP_//g' | grep "P" | tr 'P' 'p' | tr '_' '.' | sed 's/\.$//g' | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://github.com/$repo.git | grep "refs/tags/NTP_[0-9P_]+" -oE | sed 's/.*NTP_//g' | tr 'P' 'p' | tr '_' '.' | grep "p" | sed 's/\.$//g' | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
# gh_ver sort of works but sometimes errors
version=$(get_version)
majmVer=$(echo $version | sed -E 's/.[0-9p]+$//g')
majVer=$(echo $version | cut -d '.' -f 1)
depends=(glibc libcap libevent ncurses openssl readline)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://www.eecis.udel.edu/~ntp/ntp_spool/ntp$majVer/ntp-$majmVer/$filename
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
sudo install -Dm644 ../ntp.conf /etc/ntp.conf
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
