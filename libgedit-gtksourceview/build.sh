#!/bin/bash
set -e
# Variable declaration
name=libgedit-gtksourceview
version=$(lgd_ver $name)
lfs_depends=(bzip2 dbus expat gcc glibc libffi systemd util-linux zlib)
depends=(glib2 gtk3 libX11 libXcomposite libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXres libgedit-amtk libgedit-gfls pango pcre2 wayland)
blfs_depends=(at-spi2-core brotli cairo exempi fontconfig freetype fribidi gdk-pixbuf glib glycin gnome-desktop graphite2 gtk3 harfbuzz hicolor-icon-theme lcms lcms2 libXau libXdmcp libepoxy libhandy libpng libseccomp libx11 libxcb libxkbcommon libxml2 meson pixman)
# Fetch source and unpack it
repo_url="https://gitlab.gnome.org/World/gedit/$name.git"
if [[ ! -d "$name/.git" ]]; then
	git clone --depth 1 --branch "$version" --recurse-submodules --shallow-submodules \
		"$repo_url" "$name"
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
echo $version > /var/lib/custom-packages/$name
