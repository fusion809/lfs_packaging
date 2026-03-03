#!/bin/bash
set -e
# Variable declarations
name=fastfetch
depends=(yyjson) # Can build and run without it
lfs_depends=(bash coreutils gcc glibc zlib)
blfs_depends=(cmake dbus dconf imagemagick 
pulseaudio libxcb libxrandr # These are listed in Arch's PKGBUILD, but I am doubtful these are required, unless you plan to use a GUI for it.
sqlite
)
# Arch https://gitlab.archlinux.org/archlinux/packaging/packages/fastfetch/-/blob/main/PKGBUILD?ref_type=heads
# has chafa (image output as ascii art), ddcutil, directx-headers, libglvnd, ocl-icd, opencl-headers, vulkan-icd-loader, vulkan-headers and xfconf listed as a dep, but seems to build and run fine without it

# Get the source
if ! [[ -d fastfetch ]]; then
	git clone https://github.com/fastfetch-cli/fastfetch
fi

cd $name
git checkout master
git pull origin master
git fetch --all --tags
git fetch --prune --prune-tags
version=$(git describe --tags --abbrev=0)
git checkout $version
# Compile and install
mkdir -p build
cd build
cmake .. \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCMAKE_C_FLAGS:STRING="-O2 -fPIC" \
	-DCMAKE_CXX_FLAGS:STRING="-O2 -fPIC"
cmake --build . --target fastfetch
sudo make install
cd ..
# Add to database
echo $version > /var/lib/lfs-custom-packages/$name