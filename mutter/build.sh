#!/bin/bash
set -e
name=mutter
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(at-spi2-core brotli bzip2 cairo colord curl cyrus-sasl elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin gnome-desktop graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz icu lcms2 libadwaita libcanberra libdisplay-info libdrm libei libelf libepoxy libevdev libffi libfyaml libgudev libidn2 libinput libjpeg-turbo libogg libpciaccess libpng libpsl libseccomp libtiff libunistring libunwind libvorbis libwacom libwebp libX11 libxau libxcb libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxml2 libxmlb libXrandr libXrender libxshmfence libXxf86vm llvm lm-sensors lua mesa mtdev nghttp2 openldap openssl orc pango pcre2 pipewire pixman spirv-tools startup-notification systemd util-linux vulkan-loader wayland webkitgtk xcb-util xz zlib zstd)
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
gn_download "$filename"
unpk_enter "$filename" "$direname"
options=(--prefix=/usr            \
            --buildtype=release      \
            -D tests=disabled        \
            -D profiler=false        \
            -D bash_completion=false)
#cmi "${options[@]}"
#cmaki "${options[@]}"
mni "${options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
