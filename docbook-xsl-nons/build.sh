#!/bin/bash
set -e
name=docbook-xsl-nons
get_version() {
	local inst_ver=$(pkgver $name)
	local git_ver=$(timeout 5 git ls-remote --tags --refs  https://github.com/docbook/xslt10-stylesheets.git | grep "refs/tags/release" | cut -d '/' -f 4 | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/releases/download/release/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
gap_patches "$name"
sudo su -c "install -v -m755 -d /usr/share/xml/docbook/xsl-stylesheets-nons-$version &&

cp -v -R VERSION assembly common eclipse epub epub3 extensions fo        \
         highlighting html htmlhelp images javahelp lib manpages params  \
         profiling roundtrip slides template tests tools webhelp website \
         xhtml xhtml-1_1 xhtml5                                          \
    /usr/share/xml/docbook/xsl-stylesheets-nons-$version &&

ln -svf VERSION /usr/share/xml/docbook/xsl-stylesheets-nons-$version/VERSION.xsl &&

install -v -m644 -D README \
                    /usr/share/doc/$direname/README.txt &&

install -v -m644    RELEASE-NOTES* NEWS* \
                    /usr/share/doc/$direname"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
