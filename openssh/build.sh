#!/bin/bash
set -e
name=openssh
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/ | grep -oE "openssh-[0-9.p]+.tar.gz" | grep -oE "[0-9]+\.[0-9]+p[0-9]+" | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs git://anongit.mindrot.org/openssh.git | grep -oE "V_[0-9_P]+" | sed 's/V_//g' | sed 's/_/./' | sed 's/_P/p/g' | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(glibc libxcrypt openssl zlib)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
#sudo su -c "install -v -g sys -m700 -d /var/lib/sshd &&
#
#groupadd -g 50 sshd        &&
#useradd  -c 'sshd PrivSep' \
#         -d /var/lib/sshd  \
#         -g sshd           \
#         -s /bin/false     \
#         -u 50 sshd"
cmi --prefix=/usr --sysconfdir=/etc/ssh --with-privsep-path=/var/lib/sshd --with-default-path=/usr/bin --with-superuser-path=/usr/sbin:/usr/bin --with-pid-dir=/run
sudo su -c "install -v -m755    contrib/ssh-copy-id /usr/bin     &&

install -v -m644    contrib/ssh-copy-id.1 \
                    /usr/share/man/man1              &&
install -v -m755 -d /usr/share/doc/$direname    &&
install -v -m644    INSTALL LICENCE OVERVIEW README* \
                    /usr/share/doc/$direname"
cd ..
URL=$(wget -cqO- https://www.linuxfromscratch.org/blfs/view/systemd/introduction/systemd-units.html | grep "blfs-systemd-units-[0-9]+.tar.xz" -E | cut -d '"' -f 2 | head -n 1)
wget -c $URL
systemd_filename=$(echo $URL | sed 's|https.*/||g')
tar xf $systemd_filename
cd blfs-systemd-units*[0-9]
sudo make install-sshd
cd ..
rm -rf $filename $direname $systemd_filename
echo "$version" | sudo tee /var/lib/custom-packages/$name
