#!/bin/bash
set -e
name=evolution-data-server
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(at-spi2-core brotli bzip2 cairo dav1d dbus e2fsprogs elfutils enchant expat fontconfig freetype fribidi gcc gdk-pixbuf geocode-glib glib2 glibc glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk3 gtk4 harfbuzz highway icu json-glib keyutils lcms2 libaom libavif libcanberra libdrm libelf libepoxy libffi libgcrypt libgpg-error libgudev libgweather libical libidn2 libjpeg-turbo libjxl libogg libpciaccess libpng libpsl libseccomp libsecret libsoup libtasn1 libtiff libunistring libunwind libvorbis libwebp libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxml2 libxrandr libxrender libxres libxshmfence libxslt libxxf86vm llvm lm-sensors mesa mitkrb nghttp2 nspr nss orc pango pcre2 pixman spirv-tools sqlite svt-av1 systemd util-linux vulkan-loader wayland webkitgtk xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(-D CMAKE_INSTALL_PREFIX=/usr \
      -D SYSCONF_INSTALL_DIR=/etc  \
      -D ENABLE_VALA_BINDINGS=ON   \
      -D ENABLE_INSTALLED_TESTS=ON \
      -D WITH_OPENLDAP=OFF         \
      -D WITH_KRB5=OFF             \
      -D ENABLE_INTROSPECTION=ON   \
      -D ENABLE_GTK_DOC=OFF        \
      -D WITH_LIBDB=OFF            \
      -W no-author -G Ninja)
cmaki "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
