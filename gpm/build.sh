#!/bin/bash
set -e
name=gpm
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://anduin.linuxfromscratch.org/BLFS/gpm/ | grep "gpm-[0-9]\.[0-9]+\.[0-9]" -oE | cut -d '-' -f 2 | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://github.com/telmich/gpm.git | grep "refs/tags/[0-9]+\.[0-9]+\.[0-9]+" -oE | grep -v "\.99" | cut -d '/' -f 3 | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name | sed 's/\.r.*//g')
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(glibc ncurses)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://anduin.linuxfromscratch.org/BLFS/gpm/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
gap_patches $name
./autogen.sh
cmi --prefix=/usr --sysconfdir=/etc ac_cv_path_emacs=no
sudo su -c "install-info --dir-file=/usr/share/info/dir           \
             /usr/share/info/gpm.info                 &&

rm -fv /usr/lib/libgpm.a                              &&
ln -sfv $(ls /usr/lib/libgpm.so.* | tail -n 1 | cut -d '/' -f 3) /usr/lib/libgpm.so            &&
install -v -m644 conf/gpm-root.conf /etc              &&

install -v -m755 -d /usr/share/doc/$direname/support &&
install -v -m644    doc/support/*                     \
                    /usr/share/doc/$direname/support &&
install -v -m644    doc/{FAQ,HACK_GPM,README*}        \
                    /usr/share/doc/$direname"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
