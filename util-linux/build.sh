#!/bin/bash
name=util-linux
get_version() {
	local inst_ver=$(pkgver $name)
	local majVer=$(wget -T 5 -t 1 -cqO- https://www.kernel.org/pub/linux/utils/util-linux/ | grep -E "v[0-9]+\.[0-9]+" | cut -d '"' -f 2 | sed 's/v//g' | sed 's|/||g' | sort -V | tail -n 1)

	local up_ver=$(wget -T 5 -t 1 -cqO- https://www.kernel.org/pub/linux/utils/util-linux/v$majVer | grep -E "util-linux-[0-9]+\.[0-9]+\.[0-9]+.tar.xz" | cut -d '"' -f 2 | sed 's/util-linux-//g' | sed 's/.tar.xz//g' | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(ghl_ver $name/$name)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.kernel.org/pub/linux/utils/util-linux/v$(echo $version | sed -E 's/.[0-9]+$//g')/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
configure_options=(--bindir=/usr/bin     \
            --libdir=/usr/lib     \
            --runstatedir=/run    \
            --sbindir=/usr/sbin   \
            --disable-chfn-chsh   \
            --disable-login       \
            --disable-nologin     \
            --disable-su          \
            --disable-setpriv     \
            --disable-runuser     \
            --disable-pylibmount  \
            --disable-liblastlog2 \
            --disable-static      \
            --without-python      \
            ADJTIME_PATH=/var/lib/hwclock/adjtime \
	    --docdir=/usr/share/doc/$direname)
cmi "${configure_options[@]}"
cd ..
rm -rf $direname $filename
echo "$version" > /var/lib/custom-packages/$name
