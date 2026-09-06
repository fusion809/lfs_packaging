#!/bin/bash
set -e
name=mutter
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 colord curl cyrus-sasl elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz icu libX11 libXcomposite libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXxf86vm libadwaita libdisplay-info libepoxy libevdev libffi libfyaml libgudev libidn2 libpciaccess libpng libpsl libunistring libwacom libxkbcommon libxml2 libxmlb libxshmfence mesa mtdev nghttp2 openldap openssl orc pango pcre2 systemd util-linux vulkan-loader wayland xz zlib zstd)
blfs_depends=(at-spi2-core cairo gnome-desktop lcms2 libXau libXdmcp libcanberra libdrm libei libinput libjpeg-turbo libogg libseccomp libtiff libunwind libvorbis libwebp libxcb llvm lm-sensors lua pipewire pixman spirv-tools startup-notification webkitgtk xcb-util)
lfs_depends=(libelf)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://download.gnome.org/sources/mutter/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
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
