#!/bin/bash
set -e
name=pinentry
repo="gpg/$name"
version=$(gh_ver $repo)
depends=(at-spi2-core brotli bzip2 cairo dbus elfutils expat fltk fontconfig freetype fribidi gcc gcr4 gdk-pixbuf glib2 glibc glycin graphite2 gtk3 harfbuzz icu lcms2 libICE libSM libX11 libXau libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXft libXi libXinerama libXrandr libXrender libXres libassuan libdrm libepoxy libffi libgcrypt libgpg-error libpciaccess libpng libseccomp libsecret libxcb libxkbcommon libxml2 libxshmfence lm-sensors mesa ncurses p11-kit pango pcre2 pixman spirv-tools systemd util-linux wayland xz zlib zstd)
blfs_depends=(llvm)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://www.gnupg.org/ftp/gcrypt/$name/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
cmi --prefix=/usr --enable-pinentry-tty
cd ..
rm -rf $filename $direname
echo $version | sudo tee /var/lib/custom-packages/$name
