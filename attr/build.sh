#!/bin/bash
set -e
name=attr
version=$(ngnu_ver $name)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
lfs_depends=(gcc glibc make tar wget xz)
if ! [[ -f $filename ]] && ! [[ -d $name ]] ; then
	wget -c https://download.savannah.nongnu.org/releases/$name/$filename || ( git clone https://git.savannah.nongnu.org/git/$name.git )
fi
if [[ -f $filename ]]; then
	rm -rf $direname && tar xf $filename && cd $direname
elif [[ -d $name ]]; then
	cd $name && git checkout v$version
fi

cmi --prefix=/usr --disable-static --sysconfdir=/etc --docdir=/usr/share/doc/$direname
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
