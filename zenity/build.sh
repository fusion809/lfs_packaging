#!/bin/bash
set -e
# Variable declaration
name=zenity
version=$(gn_ver zenity)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
lfs_depends=(bzip2 expat gcc gettext glibc libelf libffi openssl systemd util-linux xz zlib zstd)
depends=(elfutils glib2 libX11 libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXxf86vm libadwaita libpciaccess libxshmfence mesa openldap orc pango pcre2 wayland)
blfs_depends=(brotli cairo curl cyrus-sasl fontconfig freetype fribidi gdk-pixbuf git glib2 glycin graphene graphite2 gst-plugins-bad gst-plugins-base gstreamer gtk4 harfbuzz hicolor-icon-theme lcms2 libXau libXdmcp libadwaita libdrm libepoxy libfyaml libgudev libidn2 libjpeg-turbo libpng libpsl libseccomp libtiff libunistring libunwind libwebp libxcb libxkbcommon libxml2 libxmlb llvm lm-sensors meson nghttp2 pango pixman spirv-tools vulkan-loader webkitgtk)
# Fetch source and unpack it
if ! [[ -d $name ]]; then
	git clone https://gitlab.gnome.org/GNOME/$name
fi

# Compile and install
cd $name
git checkout $version
rm -rf build
meson_options=(
	--prefix=/usr \
	--buildtype=release \
	-D manpage=false
)
mni "${meson_options[@]}"
# Cleanup and add to database
cd ../..
echo $version > /var/lib/custom-packages/$name
