#!/bin/bash
set -e
name=intltool
repo=Distrotech/$name
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(perl-xml-parser)
if ! [[ -f $filename ]]; then
	wget -c http://launchpad.net/intltool/trunk/$version/+download/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -i 's:\\\${:\\\$\\{:' intltool-update.in
cmi --prefix=/usr
sudo su -c "install -v -m644 -D doc/I18N-HOWTO -t /usr/share/doc/$direname"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
