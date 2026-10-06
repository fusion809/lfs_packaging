#!/bin/bash
set -e
name=vte
description="Virtual Terminal Emulator widget."
homepage="https://gitlab.gnome.org/GNOME/vte"
get_version() {
	local ver=$(gn_ver $name)
	if [[ $ver == "2.91" ]]; then
		ver=$(pkgver $name)
	fi
	echo "$ver"
}
version=$(get_version)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(at-spi2-core brotli bzip2 cairo dbus elfutils expat fast_float fmt fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin gmp gnutls graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk3 gtk4 harfbuzz icu libdrm libepoxy libffi libglvnd libgudev libidn2 libjpeg-turbo libpng libseccomp libtasn1 libunistring libunwind libwebp libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxrandr libxrender libxres lz4 mesa nettle orc p11-kit pango pcre2 pixman simdutf systemd tiff util-linux vala vulkan-loader wayland xz zlib zstd)
gng_download "$name" "$version" "$filename"
unpk_enter "$filename" "$direname"
mni --prefix=/usr --buildtype=release
sudo rm -v /etc/profile.d/vte.*
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
