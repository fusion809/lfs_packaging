#!/bin/bash
set -e
name=v4l-utils
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://www.linuxtv.org/downloads/v4l-utils/ | grep "v4l-utils-[0-9]+\.[0-9]+\.[0-9]+" -oE | sed 's/v4l-utils-//g' | sort -V | tail -n 1)
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
depends=(alsa-lib brotli bzip2 dbus double-conversion elfutils expat fontconfig freetype gcc glib2 glibc glu graphite2 harfbuzz icu json-c libX11 libXau libXdmcp libXext libXxf86vm libdrm libffi libjpeg-turbo libpciaccess libpng libxcb libxkbcommon libxml2 libxshmfence lm-sensors mesa pcre2 qt6 spirv-tools systemd wayland xz zlib zstd)
blfs_depends=(llvm)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://www.linuxtv.org/downloads/v4l-utils/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(--prefix=/usr       \
      --buildtype=release \
      -D gconv=disabled   \
      -D doxygen-doc=disabled)
mni "${options[@]}"
for prog in v4l2gl v4l2grab
do
   sudo cp -v contrib/test/$prog /usr/bin
done
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
