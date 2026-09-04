#!/bin/bash
set -e
name=aspell
version=$(gnu_ver aspell)
majVer=$(echo $version | sed 's/.[0-9]+.[0-9]+//g' -E)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(which)
if ! [[ -f $filename ]]; then
	wget -c https://ftpmirror.gnu.org/aspell/$filename
fi
dict_url=$(wget -T 5 -t 1 -cqO- https://www.linuxfromscratch.org/blfs/view/systemd/general/aspell.html | grep -oE "https:.*aspell.*.bz2" | head -n 1)
dict_filename=$(echo $dict_url | sed -E 's|.*/||g')
if ! [[ -f $dict_filename ]]; then
	wget -c $dict_url
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cmi --prefix=/usr
sudo su -c "ln -svfn aspell-$majVer /usr/lib/aspell &&

install -v -m755 -d /usr/share/doc/$direname/aspell{,-dev}.html &&

install -v -m644 manual/aspell.html/* \
    /usr/share/doc/$direname/aspell.html &&

install -v -m644 manual/aspell-dev.html/* \
    /usr/share/doc/$direname/aspell-dev.html
install -v -m 755 scripts/ispell /usr/bin/
install -v -m 755 scripts/spell /usr/bin/"
tar xf ../$dict_filename
cd ${dict_filename/.tar.*/}
cmi
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
