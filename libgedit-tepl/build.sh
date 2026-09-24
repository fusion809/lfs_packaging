#!/bin/bash
set -e
# Variable declaration
name=libgedit-tepl
version=$(lgd_ver $name)
depends=(at-spi2-core brotli bzip2 cairo dbus exempi expat fontconfig freetype fribidi gcc gdk-pixbuf glib glib2 glibc glycin gnome-desktop graphite2 gtk3 gtk3 harfbuzz hicolor-icon-theme lcms lcms2 libepoxy libffi libgedit-amtk libgedit-gfls libgedit-gtksourceview libhandy libpng libseccomp libx11 libX11 libxau libxcb libXcomposite libXcursor libXdamage libXdmcp libXext libXfixes libXi libXinerama libxkbcommon libxml2 libXrandr libXrender libXres meson pango pcre2 pixman systemd util-linux wayland webkitgtk zlib)
# Fetch source and unpack it
repo_url=https://gitlab.gnome.org/World/gedit/$name.git
if [[ ! -d "$name" ]]; then
	git clone --depth 1 --branch "$version" --recurse-submodules --shallow-submodules \
		$repo_url
fi

git -C "$name" remote set-url origin "$repo_url"
git -C "$name" fetch --prune --tags --depth=1 origin
git -C "$name" checkout --force --detach "$version"
git -C "$name" submodule sync --recursive
git -C "$name" submodule update --init --recursive --depth=1

# Compile and install
cd "$name"
sudo rm -rf build
meson_options=(
	--prefix=/usr       \
    --buildtype=release \
    -D gtk_doc=false
)
mni "${meson_options[@]}"
# Cleanup and add to database
cd ..
echo $version | sudo tee /var/lib/custom-packages/$name
