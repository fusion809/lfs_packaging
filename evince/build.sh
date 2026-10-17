#!/bin/bash
set -e
name=evince
repo=GNOME/$name
homepage="https://gitlab.gnome.org/GNOME/evince"
description="GNOME's document viewer."
version=$(gh_ver $repo)
depends=(acl at-spi2-core avahi brotli bzip2 cairo cups curl cyrus-sasl dbus djvulibre elfutils enchant expat fontconfig freetype fribidi gcc gdk-pixbuf ghostscript glib2 glibc glycin gnome-desktop gpgme gpgmepp graphite2 gspell gst-plugins-base gstreamer gtk3 harfbuzz icu lcms2 libarchive libassuan libdrm libepoxy libffi libgcrypt libgpg-error libgxps libhandy libice libidn2 libjpeg-turbo libpaper libpng libpsl libseccomp libsecret libselinux libsm libspectre libunistring libunwind libwebp libx11 libxau libxcb libxcomposite libxcrypt libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxrandr libxrender libxres libxt lz4 nghttp2 nspr nss openjpeg openldap openssl orc pango pcre2 pixman systemd texlive tiff util-linux wayland xz zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "$version" "$filename"
unpk_enter "$filename" "$direname"
TEX_YEAR=$(ls /opt/texlive/[0-9]* -ld | sed 's|.*/opt/texlive/||g')
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/texlive/$TEX_YEAR/lib
export PATH=$PATH:/opt/texlive/$TEX_YEAR/bin
export CPPFLAGS+=" -I/opt/texlive/$TEX_YEAR/include -DNO_DEBUG" \
meson_options=(
	--prefix=/usr                \
        --buildtype=release          \
        -D gtk_doc=false             \
	--wrap-mode=nodownload)
mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
