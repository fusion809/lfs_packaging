#!/bin/bash
set -e
depends=()
NAME=fastfetch
if ! [[ -d fastfetch ]]; then
	git clone https://github.com/fastfetch-cli/fastfetch
fi

cd fastfetch
git checkout master
git pull origin master
git fetch --all --tags
git fetch --prune --prune-tags
VERSION=$(git describe --tags --abbrev=0)
git checkout $VERSION
mkdir -p build
cd build
cmake .. \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCMAKE_C_FLAGS:STRING="-O2 -fPIC" \
	-DCMAKE_CXX_FLAGS:STRING="-O2 -fPIC"
cmake --build . --target fastfetch
sudo make install
echo $VERSION > /var/lib/lfs-custom-packages/$NAME