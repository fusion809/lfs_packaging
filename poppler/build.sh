#!/bin/bash
set -e
name=poppler
description="PDF rendering library based on xpdf 3.0"
homepage="http://poppler.freedesktop.org/"
get_version() {
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- $homepage | grep "poppler-[0-9]+\.[0-9]+\.[0-9]+" -oE | cut -d '-' -f 2 | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local mon_ver=$(uver $name)
	ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(brotli bzip2 cairo curl cyrus-sasl dbus double-conversion elfutils expat fontconfig freetype gcc glib2 glibc gpgme gpgmepp graphite2 harfbuzz icu lcms2 libassuan libdrm libffi libgpg-error libidn2 libjpeg-turbo libpciaccess libpng libpsl libtiff libunistring libwebp libx11 libxau libxcb libxdmcp libxext libxkbcommon libxml2 libxrender libxshmfence libxxf86vm llvm lm-sensors mesa nghttp2 nspr nss openjpeg openldap openssl pcre2 pixman qt6 spirv-tools systemd util-linux wayland xz zlib zstd)
filename="$name-$version.tar.xz"
dversion=$(wget -cqO- $homepage | grep "poppler-data-[0-9]+\.[0-9]+\.[0-9]+" -oE | cut -d '-' -f 3 | sort -V | tail -n 1)
data_filename="$name-data-$dversion.tar.gz"
direname="${filename/.tar.*/}"
download_src "$homepage/$filename"
download_src "$homepage/$data_filename"
unpk_enter "$filename" "$direname"
options=(-D CMAKE_BUILD_TYPE=Release   \
      -D CMAKE_INSTALL_PREFIX=/usr  \
      -D TESTDATADIR=$PWD/testfiles \
      -D ENABLE_QT5=OFF             \
      -D ENABLE_UNSTABLE_API_ABI_HEADERS=ON \
      -G Ninja)
cmaki "${options[@]}"
sudo su -c "install -v -m755 -d           /usr/share/doc/$direname &&
cp -vr ../glib/reference/html /usr/share/doc/$direname"
tar -xf ../../$data_filename
cd ${data_filename/.tar.*/}
sudo make prefix=/usr install
cd ../..
rm -rf "$filename" "$direname" "$data_filename"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
