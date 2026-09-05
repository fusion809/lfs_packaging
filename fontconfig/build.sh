#!/bin/bash
set -e
name=fontconfig
repo=$name/$name
version=$(gfd_ver $repo)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(freetype)
if ! [[ -f $filename ]]; then
	wget -c https://gitlab.freedesktop.org/api/v4/projects/890/packages/generic/fontconfig/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
configure_options=(--prefix=/usr        \
            --sysconfdir=/etc    \
            --localstatedir=/var \
            --disable-docs       \
	    --docdir=/usr/share/doc/$direname)
cmi "${configure_options[@]}"
sudo su -c "install -v -dm755 \
        /usr/share/{man/man{1,3,5},doc/$direname} &&
install -v -m644 fc-*/*.1         /usr/share/man/man1 &&
install -v -m644 doc/*.3          /usr/share/man/man3 &&
install -v -m644 doc/fonts-conf.5 /usr/share/man/man5 &&
install -v -m644 doc/*.{pdf,sgml,txt,html} \
                                  /usr/share/doc/$direname"
cd ..

rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
