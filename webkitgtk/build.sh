#!/bin/bash
set -e
name=webkitgtk
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -cqO- -T 5 -t 1 https://webkitgtk.org/releases/ | grep "webkitgtk-[0-9]+\.[0-9][02468]\.[0-9]+" -oE | cut -d '-' -f 2 | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(brotli bzip2 curl cyrus-sasl e2fsprogs elfutils enchant expat fontconfig freetype fribidi gcc gcr4 gdk-pixbuf glib2 glibc glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk3 gtk4 harfbuzz highway icu json-glib keyutils lapack libX11 libXcomposite libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXres libXxf86vm libadwaita libaom libepoxy libffi libfyaml libgcrypt libgpg-error libgudev libidn2 libpciaccess libpng libpsl librest libsecret libtasn1 libunistring libxkbcommon libxml2 libxmlb libxshmfence libxslt mesa mitkrb nghttp2 openldap openssl orc p11-kit pango pcre2 sqlite systemd util-linux vulkan-loader wayland xz zlib zstd)
blfs_depends=(at-spi2-core cairo dav1d lcms2 libXau libXdmcp libavif libdrm libjpeg-turbo libjxl libseccomp libsoup libtiff libunwind libwebp libxcb llvm lm-sensors pixman spirv-tools svt-av1)
lfs_depends=(dbus libelf)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://webkitgtk.org/releases/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
echo "Compiling with GTK+3 support"
options1=(-D CMAKE_BUILD_TYPE=Release     \
      -D CMAKE_INSTALL_PREFIX=/usr    \
      -D CMAKE_SKIP_INSTALL_RPATH=ON  \
      -D PORT=GTK                     \
      -D LIB_INSTALL_DIR=/usr/lib     \
      -D USE_LIBBACKTRACE=OFF         \
      -D USE_LIBHYPHEN=OFF            \
      -D ENABLE_GAMEPAD=OFF           \
      -D ENABLE_MINIBROWSER=ON        \
      -D ENABLE_DOCUMENTATION=OFF     \
      -D ENABLE_WEBDRIVER=OFF         \
      -D USE_WOFF2=OFF                \
      -D USE_GTK4=OFF                 \
      -D ENABLE_BUBBLEWRAP_SANDBOX=ON \
      -D USE_SYSPROF_CAPTURE=NO       \
      -D ENABLE_SPEECH_SYNTHESIS=OFF  \
      -W no-author -G Ninja)
cmaki "${options1[@]}"
echo "Compiling with GTK+4 support"
options2=(-D CMAKE_BUILD_TYPE=Release         \
      -D CMAKE_INSTALL_PREFIX=/usr        \
      -D CMAKE_SKIP_INSTALL_RPATH=ON      \
      -D PORT=GTK                         \
      -D LIB_INSTALL_DIR=/usr/lib         \
      -D USE_LIBBACKTRACE=OFF             \
      -D USE_LIBHYPHEN=OFF                \
      -D ENABLE_GAMEPAD=OFF               \
      -D ENABLE_MINIBROWSER=ON            \
      -D ENABLE_DOCUMENTATION=OFF         \
      -D USE_WOFF2=OFF                    \
      -D USE_GTK4=ON                      \
      -D ENABLE_BUBBLEWRAP_SANDBOX=ON     \
      -D USE_SYSPROF_CAPTURE=NO           \
      -D ENABLE_SPEECH_SYNTHESIS=OFF      \
      -W no-author -G Ninja)
rm -rf * .[^.]* &&
cmaki "${options2[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
