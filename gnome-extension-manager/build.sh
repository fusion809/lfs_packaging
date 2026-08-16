#!/bin/bash
name=gnome-extension-manager
_name=extension-manager
version=$(gh_ver mjakeman/$_name)
direname=$_name-$version
filename=$direname.tar.gz
lfs_depends=(bzip2 e2fsprogs expat gcc gettext glibc libelf libffi openssl sqlite systemd util-linux xz zlib zstd)
depends=(elfutils glib2 libX11 libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXxf86vm libadwaita libpciaccess libxshmfence mesa mitkrb openldap orc pango pcre2 wayland)
blfs_depends=(blueprint brotli cairo curl cyrus-sasl fontconfig freetype fribidi gdk-pixbuf glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz json-glib keyutils lcms2 libXau libXdmcp libadwaita libdrm libepoxy libfyaml libgudev libidn2 libjpeg-turbo libjson-glib libpng libpsl libseccomp libsoup libtiff libunistring libunwind libwebp libxcb libxkbcommon libxml2 libxmlb llvm lm-sensors nghttp2 pixman spirv-tools vulkan-loader webkitgtk)

if ! [[ -f $filename ]]; then
	wget -c https://github.com/mjakeman/$_name/archive/refs/tags/v$version.tar.gz -O $filename
fi

rm -rf $direname
tar xf $filename
cd $direname
meson setup _build --prefix=/usr -D backtrace=false
meson compile -C _build
sudo meson install -C _build
cd ..
rm -rf $filename $direname
echo "$version" > /var/lib/custom-packages/$name
