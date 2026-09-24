#!/bin/bash
set -e
name=gnome-extension-manager
_name=extension-manager
repo=mjakeman/$_name
version=$(gh_ver $repo)
direname="$_name-$version"
filename=$direname.tar.gz
depends=(blueprint brotli bzip2 cairo curl cyrus-sasl e2fsprogs elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf gettext glib2 glibc glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz json-glib keyutils lcms2 libadwaita libadwaita libdrm libelf libepoxy libffi libfyaml libgudev libidn2 libjpeg-turbo libjson-glib libpciaccess libpng libpsl libseccomp libsoup libtiff libunistring libunwind libwebp libx11 libxau libxcb libxcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxml2 libxmlb libXrandr libXrender libxshmfence libXxf86vm llvm lm-sensors mesa mitkrb nghttp2 openldap openssl orc pango pcre2 pixman spirv-tools sqlite systemd util-linux vulkan-loader wayland webkitgtk xz zlib zstd)
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
meson_options=(
    --prefix=/usr \
    -D backtrace=false
)
mni "${meson_options[@]}"
cd ../..
rm -rf $filename $direname
echo "$version" | sudo tee /var/lib/custom-packages/$name
