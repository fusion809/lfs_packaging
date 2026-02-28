#!/bin/bash
set -e
NAME=fastfetch
VERSION=$(wget -cqO- https://github.com/fastfetch-cli/fastfetch/releases | grep "releases/tag/" | head -n 1 | cut -d '"' -f 6 | cut -d '/' -f 6)

if ! [[ -d fastfetch ]]; then
	git clone https://github.com/fastfetch-cli/fastfetch
fi

cd fastfetch
git checkout $VERSION
mkdir -p build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr
cmake --build . --target fastfetch
sudo make install
