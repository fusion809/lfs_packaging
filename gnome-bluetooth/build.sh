#!/bin/bash
set -e
name=gnome-bluetooth
repo=GNOME/$name
version=$(gh_ver $repo)
depends=(brotli bzip2 cairo curl cyrus-sasl elfutils expat fontconfig freetype fribidi gcc gdk-pixbuf glib2 glibc glycin graphene graphite2 gsound gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz icu lcms2 libadwaita libcanberra libdrm libelf libepoxy libffi libfyaml libgudev libidn2 libjpeg-turbo libnotify libogg libpciaccess libpng libpsl libseccomp libtiff libunistring libunwind libvorbis libwebp libX11 libXau libxcb libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxml2 libxmlb libXrandr libXrender libxshmfence libXxf86vm llvm lm-sensors mesa nghttp2 openldap openssl orc pango pcre2 pixman spirv-tools systemd upower util-linux vulkan-loader wayland webkitgtk xz zlib zstd)
majVer=$(echo $version | sed -E 's/\.[0-9]+$//g')
filename="$name-$version.tar.xz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://download.gnome.org/sources/$name/$majVer/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -i 's:"/desktop:"/org:' schema/*.xml || echo "sed failed"
meson_options=(
    --prefix=/usr
    --buildtype=release
)

printf '%s\n' "before mni:"
printf '<%s>\n' "${meson_options[@]}"

mni "${meson_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
