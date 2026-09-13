#!/bin/bash
set -e
name=sddm
repo=$name/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 double-conversion e2fsprogs expat fontconfig freetype gcc glib2 glibc graphite2 harfbuzz icu keyutils libX11 libXext libXxf86vm libffi libpciaccess libpng libxkbcommon libxml2 libxshmfence linux-pam mesa mitkrb openssl pcre2 systemd wayland xz zlib zstd)
blfs_depends=(libXau libXdmcp libdrm libxcb llvm lm-sensors qt6 spirv-tools)
lfs_depends=(dbus libelf)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/archive/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
options=(-D CMAKE_INSTALL_PREFIX=/usr        \
      -D CMAKE_BUILD_TYPE=Release         \
      -D CMAKE_POLICY_VERSION_MINIMUM=3.5 \
      -D RUNTIME_DIR=/run/sddm            \
      -D BUILD_MAN_PAGES=ON               \
      -D BUILD_WITH_QT6=ON                \
      -D DATA_INSTALL_DIR=/usr/share/sddm \
      -D DBUS_CONFIG_FILENAME=sddm_org.freedesktop.DisplayManager.conf)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
