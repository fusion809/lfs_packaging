#!/bin/bash
set -e
# Variable declarations
name=fastfetch
depends=(yyjson) # Can build and run without it
lfs_depends=(bash coreutils gcc glibc zlib)
blfs_depends=(cmake dbus dconf ImageMagick 
pulseaudio libxcb libxrandr sqlite)

# Get the source
if ! [[ -d fastfetch ]]; then
	git clone https://github.com/fastfetch-cli/fastfetch
fi

cd $name
version=$(git checkout master -q && git pull origin master -q && git fetch --all --tags -q && git fetch --prune --prune-tags -q && git describe --tags --abbrev=0)
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
echo $version > /var/lib/custom-packages/$name
