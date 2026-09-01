#!/bin/bash
set -e
name=perl
get_version() {
	local inst_ver=$(pkgver $name)
	local majVer=$(wget -T 5 -t 1 -cqO- https://www.cpan.org/src | grep "a href=\"[0-9.]+/\"" -E | cut -d '"' -f 2 | cut -d '/' -f 1)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://www.cpan.org/src/$majVer | grep "perl-[0-9]+\.[0-9]+[02468]\.[0-9]+\.tar\.xz\"" -E | cut -d '"' -f 4 | cut -d '-' -f 2 | sed 's/.tar.*//g')
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://github.com/Perl/perl5.git | grep "refs/tags/v[0-9]+\.[0-9]+[02468]\.[0-9]+$" -E | cut -d '/' -f 3 | sed 's/v//g')
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
	wget -c https://www.cpan.org/src/$(echo $version | sed 's/\..*/.0/g')/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
export BUILD_ZLIB=False
export BUILD_BZIP2=0
majmin=$(echo $version | sed -E 's/\.[0-9]+$//g')
sh Configure -des                                          \
             -D prefix=/usr                                \
             -D vendorprefix=/usr                          \
             -D privlib=/usr/lib/perl5/$majmin/core_perl      \
             -D archlib=/usr/lib/perl5/$majmin/core_perl      \
             -D sitelib=/usr/lib/perl5/$majmin/site_perl      \
             -D sitearch=/usr/lib/perl5/$majmin/site_perl     \
             -D vendorlib=/usr/lib/perl5/$majmin/vendor_perl  \
             -D vendorarch=/usr/lib/perl5/$majmin/vendor_perl \
             -D man1dir=/usr/share/man/man1                \
             -D man3dir=/usr/share/man/man3                \
             -D pager="/usr/bin/less -isR"                 \
             -D useshrplib                                 \
             -D usethreads
make -j$(nproc)
sudo su -c "make install
unset BUILD_ZLIB BUILD_BZIP2"
cd ..
rm -rf $filename $direname
echo $version > /var/lib/custom-packages/$name
