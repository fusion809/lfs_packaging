#!/bin/bash
set -e
# Variable declaration
name=libgusb
version=$(gh_ver "hughsie/libgusb")
filename="$name-$version.tar.xz"
direname="${filename/.tar.xz/}"
depends=(glib2 glib2 glibc hwdata json-glib libffi libusb pcre2 systemd util-linux vala webkitgtk zlib)
# Fetch source and unpack it
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/hughsie/libgusb/releases/download/$version/$filename
fi
rm -rf $direname
tar xf $filename
# Compile and install
cd $direname
meson_options=(
	--prefix=/usr       \
    --buildtype=release \
	-D docs=false
)
mni "${meson_options[@]}"
# Cleanup and add to database
cd ../..
sudo rm -rf $direname $filename
echo $version | sudo tee /var/lib/custom-packages/$name
