#!/bin/bash
set -e
name=dvisvgm
repo=mgieseki/$name
version=$(gh_ver $repo)
depends=(avahi brotli bzip2 cups dbus expat fontconfig freetype gcc ghostscript glibc lcms2 libICE libjpeg-turbo libpaper libpng libSM libwebp libX11 libXau libxcb libxcrypt libXdmcp libXext libXt openjpeg openssl potrace systemd texlive tiff util-linux woff2 xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/releases/download/$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
TEXARCH=$(uname -m | sed -e 's/i.86/i386/' -e 's/$/-linux/') &&

sed -i 's/python/&3/' tests/Makefile.in
TEXLIVE_PREFIX=/opt/texlive/$(ls /opt/texlive | grep "[0-9]+" -oE)
options=(--bindir=$TEXLIVE_PREFIX/bin/${TEXARCH}     \
    --mandir=$TEXLIVE_PREFIX/texmf-dist/doc/man \
    --with-kpathsea=$TEXLIVE_PREFIX)
cmi "${options[@]}"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
