#!/bin/bash
set -e
name=webkitgtk
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -cqO- -T 5 -t 1 https://webkitgtk.org/releases/ | grep "webkitgtk-[0-9]+\.[0-9][02468]\.[0-9]+" -oE | cut -d '-' -f 2 | sort -V | tail -n 1)
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
depends=(at-spi2-core brotli bzip2 cairo curl cyrus-sasl dav1d dbus e2fsprogs elfutils enchant expat fontconfig freetype fribidi gcc gcr4 gdk-pixbuf glib2 glibc glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk3 gtk4 harfbuzz highway icu json-glib keyutils lapack lcms2 libadwaita libaom libavif libdrm libelf libepoxy libffi libfyaml libgcrypt libgpg-error libgudev libidn2 libjpeg-turbo libjxl libpciaccess libpng libpsl librest libseccomp libsecret libsoup libtasn1 libtiff libunistring libunwind libwebp libX11 libXau libxcb libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxml2 libxmlb libXrandr libXrender libXres libxshmfence libxslt libXxf86vm llvm lm-sensors mesa mitkrb nghttp2 openldap openssl orc p11-kit pango pcre2 pixman spirv-tools sqlite svt-av1 systemd util-linux vulkan-loader wayland xz zlib zstd)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
download_src "https://webkitgtk.org/releases/$filename"
unpk_enter "$filename" "$direname"
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
cd ..
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
cmaki "${options2[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
