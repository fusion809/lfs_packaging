#!/bin/bash
set -e
name=ladspa
homepage="https://www.ladspa.org/"
description="Linux audio developer's simple plugin API."
version=$(aver $name)
filename="${name}_sdk_$version.tgz"
direname="${filename/.tgz/}"
depends=(libsndfile)
download_src "https://ladspa.org/download/$filename"
unpk_enter "$filename" "$direname"
arch_patch "$name" "$name-1.17-fix-memleak-in-plugin-scanning.patch"
arch_patch "$name" "$name-1.17-plugin_underlinking.patch"
arch_patch "$name" "$name-1.17-distribution-flags.patch"
make -C src
make_options=(INSTALL_PLUGINS_DIR="/usr/lib/ladspa/"
    INSTALL_INCLUDE_DIR="/usr/include/"
    INSTALL_BINARY_DIR="/usr/bin/")
make "${make_options[@]}" install -C src
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
