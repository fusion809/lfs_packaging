#!/bin/bash
set -e
name=vim
version=$(gh_ver "vim/vim")
majver=$(echo $version | cut -d . -f 1)
minver=$(echo $version | cut -d . -f 2)
vimdir=$(echo "${name}${majver}${minver}")
direname="$name-$version"
filename="$direname.tar.gz"
lfs_depends=(acl bzip2 dbus expat gawk gcc glibc gpm libffi libgcrypt ncurses systemd util-linux zlib)
# Optional lfs_depends of libcanberra for sound support, tcl for tcl support
blfs_depends=(at-spi2-core brotli cairo fontconfig freetype fribidi gdk-pixbuf glycin gpm graphite2 harfbuzz lcms2 libXau libXdmcp libcanberra libepoxy libogg libpng libseccomp libvorbis libxcb libxkbcommon pixman webkitgtk)
# Optional blfs_depends of gtk3, libxt, lua, perl, python, ruby for GUI/language support
depends=(glib2 gtk3 libICE libSM libX11 libXcomposite libXcursor libXdamage libXext libXfixes libXi libXinerama libXrandr libXrender libXres libXt pango pcre2 wayland)

if ! [[ -f "$filename" ]]; then
    wget -c https://github.com/vim/vim/archive/v$version.tar.gz -O $filename
fi

# Fixed extraction and build prefix issues
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h

cmi "--prefix=/usr"
export CP="/var/lib/custom-packages"
echo "$version" | sudo tee "$CP/$name" > /dev/null
sudo chmod 777 "/var/lib/custom-packages/$name"
sudo rm -rf /usr/share/doc/vim-*
sudo ln -sv ../vim/"$vimdir"/doc /usr/share/doc/"$direname" || true
cd ..
rm -rf "$direname" "$filename"
