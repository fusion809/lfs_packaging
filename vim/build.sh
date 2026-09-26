#!/bin/bash
set -e
name=vim
homepage="https://www.vim.org"
description="Vi Improved, a highly configurable, improved version of the vi text editor"
repo=$name/$name
version=$(gh_ver $repo)
majver=$(echo $version | cut -d . -f 1)
minver=$(echo $version | cut -d . -f 2)
vimdir=$(echo "${name}${majver}${minver}")
direname="$name-$version"
filename="$direname.tar.gz"
depends=(acl at-spi2-core brotli bzip2 cairo dbus expat fontconfig freetype fribidi gawk gcc gdk-pixbuf glib2 glibc glycin gpm gpm graphite2 gtk3 harfbuzz lcms2 libcanberra libepoxy libffi libgcrypt libice libogg libpng libseccomp libSM libvorbis libx11 libxau libxcb libxcomposite libxcursor libxdamage libxdmcp libxext libxfixes libxi libxinerama libxkbcommon libxrandr libxrender libxres libxt ncurses pango pcre2 pixman systemd util-linux wayland webkitgtk zlib)

gha_download "$repo" "v$version" "$filename"
# Fixed extraction and build prefix issues
unpk_enter "$filename" "$direname"
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

cmi --prefix=/usr
export CP="/var/lib/custom-packages"
echo "$version" | sudo tee "$CP/$name" > /dev/null
sudo chmod 777 "/var/lib/custom-packages/$name"
sudo rm -rf /usr/share/doc/vim-*
sudo ln -sv ../vim/"$vimdir"/doc /usr/share/doc/"$direname" || true
cd ..
rm -rf "$direname" "$filename"
