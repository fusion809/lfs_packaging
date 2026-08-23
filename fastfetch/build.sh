#!/bin/bash
set -e
# Variable declarations
name=fastfetch
depends=(yyjson) # Can build and run without it
lfs_depends=(bash coreutils gcc glibc zlib)
blfs_depends=(cmake dbus dconf ImageMagick 
pulseaudio libxcb libxrandr sqlite)
version=$(gh_ver "fastfetch-cli/fastfetch")
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"

# Get the source
if ! [[ -f $filename ]]; then
	wget -c https://github.com/fastfetch-cli/fastfetch/archive/$version.tar.gz -O $filename
fi
rm -rf $direname
tar xf $filename
cd $direname
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
cd ../..
rm -rf $filename $direname
# Add to database
echo $version > /var/lib/custom-packages/$name
