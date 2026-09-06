#!/bin/bash
set -e
name=evolution-data-server
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 e2fsprogs elfutils enchant expat fontconfig freetype fribidi gcc gdk-pixbuf geocode-glib glib2 glibc glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk3 gtk4 harfbuzz highway icu json-glib keyutils libX11 libXcomposite libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXres libXxf86vm libaom libepoxy libffi libgcrypt libgpg-error libgudev libgweather libical libidn2 libpciaccess libpng libpsl libtasn1 libunistring libxkbcommon libxml2 libxshmfence libxslt mesa mitkrb nghttp2 nspr nss orc pango pcre2 sqlite systemd util-linux vulkan-loader wayland xz zlib zstd)
blfs_depends=(at-spi2-core cairo dav1d lcms2 libXau libXdmcp libavif libcanberra libdrm libjpeg-turbo libjxl libogg libseccomp libsecret libsoup libtiff libunwind libvorbis libwebp libxcb llvm lm-sensors pixman spirv-tools svt-av1 webkitgtk)
lfs_depends=(dbus libelf)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/$name/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
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
