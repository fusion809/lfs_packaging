#!/bin/bash
set -e
name=poppler
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://poppler.freedesktop.org/ | grep "poppler-[0-9]+\.[0-9]+\.[0-9]+" -oE | cut -d '-' -f 2 | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(brotli bzip2 cairo curl cyrus-sasl dbus double-conversion elfutils expat fontconfig freetype gcc glib2 glibc gpgme gpgmepp graphite2 harfbuzz icu lcms2 libassuan libdrm libffi libgpg-error libidn2 libjpeg-turbo libpciaccess libpng libpsl libtiff libunistring libwebp libX11 libXau libxcb libXdmcp libXext libxkbcommon libxml2 libXrender libxshmfence libXxf86vm llvm lm-sensors mesa nghttp2 nspr nss openjpeg openldap openssl pcre2 pixman qt6 spirv-tools systemd util-linux wayland xz zlib zstd)
filename="$name-$version.tar.xz"
dversion=$(wget -cqO- https://poppler.freedesktop.org/ | grep "poppler-data-[0-9]+\.[0-9]+\.[0-9]+" -oE | cut -d '-' -f 3 | sort -V | tail -n 1)
data_filename="$name-data-$dversion.tar.gz"
direname="${filename/.tar.*/}"
download_src "https://poppler.freedesktop.org/$filename"
download_src "https://poppler.freedesktop.org/$data_filename"
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
