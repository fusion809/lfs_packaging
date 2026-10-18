#!/bin/bash
set -e
name=inchi
_name=InChI
repo=IUPAC-$_name/$_name
homepage="https://github.com/IUPAC-InChI/InChI"
description="The IUPAC international chemical identifier."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
gha_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
cmake_options=(
    -W no-dev
    -DCMAKE_BUILD_TYPE=None
    -DCMAKE_INSTALL_PREFIX=/usr
    -DCMAKE_SKIP_RPATH=ON
  )
cmaki "${cmake_options[@]}" 
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
