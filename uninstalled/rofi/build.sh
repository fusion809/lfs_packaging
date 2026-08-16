#!/bin/bash
set -e
name=rofi
version=$(gh_ver davatorium/rofi)

if ! [[ -d rofi ]]; then
	git clone https://github.com/davatorium/rofi.git
fi
if ! [[ -d libgwater ]]; then
	git clone https://github.com/sardemff7/libgwater
fi

if ! [[ -d libnkutils ]]; then
	git clone https://github.com/sardemff7/libnkutils
fi
cd rofi
git checkout $version
git submodule init
git config submodule.subprojects/libgwater.url ../libgwater
git config submodule.subprojects/libnkutils.url ../libnkutils
git -c protocol.file.allow=always submodule update

mni "--prefix=/usr"
cd ..
rm -rf build
cd ..
echo "$version" > /var/lib/custom-packages/$name
