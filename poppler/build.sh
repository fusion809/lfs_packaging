#!/bin/bash
set -e
name=poppler
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://poppler.freedesktop.org/ | grep "poppler-[0-9]+\.[0-9]+\.[0-9]+" -oE | cut -d '-' -f 2 | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(brotli bzip2 curl cyrus-sasl dbus double-conversion elfutils expat fontconfig freetype gcc glib2 glibc gpgme gpgmepp graphite2 harfbuzz icu libX11 libXau libXdmcp libXext libXrender libXxf86vm libassuan libffi libgpg-error libidn2 libpciaccess libpng libpsl libunistring libxcb libxkbcommon libxml2 libxshmfence mesa nghttp2 nspr nss openldap openssl pcre2 qt6 systemd util-linux wayland xz zlib zstd)
blfs_depends=(cairo lcms2 libdrm libjpeg-turbo libtiff libwebp llvm lm-sensors openjpeg pixman spirv-tools)
filename="$name-$version.tar.xz"
dversion=$(wget -cqO- https://poppler.freedesktop.org/ | grep "poppler-data-[0-9]+\.[0-9]+\.[0-9]+" -oE | cut -d '-' -f 3 | sort -V | tail -n 1)
data_filename="$name-data-$dversion.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://poppler.freedesktop.org/$filename
fi
if ! [[ -f $data_filename ]]; then
	wget -c https://poppler.freedesktop.org/$data_filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
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
