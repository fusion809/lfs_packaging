#!/bin/bash
set -e
name=pybind11
repo=pybind/$name
homepage="https://pybind11.readthedocs.io/"
description="Semaless operability between C++ and Python."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
python -m build --wheel --no-isolation
cmake_options=(-G 'Unix Makefiles' \
        -DCMAKE_BUILD_TYPE:STRING='None' \
        -DCMAKE_INSTALL_PREFIX:PATH='/usr' \
        -DDOWNLOAD_CATCH:BOOL='ON' \
        -Wno-author)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
