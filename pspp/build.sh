#!/bin/bash
set -e
name=pspp
homepage="http://www.gnu.org/software/pspp/"
description="Statistical analysis app; open-source alternative to SPSS."
version=$(gnu_ver $name)
depends=(at-spi2-core blas-lapack-git brotli bzip2 cairo dbus expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 gtk3 gtksourceview4 harfbuzz icu libepoxy libffi libpng libseccomp libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxrandr libxrender libxres ncurses pango pcre2 pixman postgresql readline rust sagemath ssw systemd util-linux wayland zlib)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gnu_download "$name" "$filename"
unpk_enter "$filename" "$direname"
sed -i 's/.*_GL_EXTERN_C.*bsearch.*/#undef bsearch\n&/' gl/stdlib.in.h
	sed -i 's/.*_GL_EXTERN_C.*wmemchr.*/#undef wmemchr\n&/' gl/wchar.in.h
cmi --prefix=/usr --sysconfdir=/etc --without-libreadline-prefix --disable-static
sudo ln -sf /usr/share/icons/hicolor/256x256/apps/org.gnu.pspp.png /usr/share/pixmaps/
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
