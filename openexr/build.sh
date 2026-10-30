#!/bin/bash
set -e
name=openexr
repo=$name/$name
homepage="https://www.openexr.com/"
description="High dynamic-range image file format library."
version=$(gh_ver $repo)
depends=(openjph libdeflate gcc git cmake imath)
download_git "https://github.com/$repo.git"
cd $name
git checkout v$version
# unpin scikit-build-core version
sed 's|scikit-build-core[^"]*|scikit-build-core|' -i pyproject.toml
# Fix python module install dir
git cherry-pick -n 30345db72944b38926f13b5114b9a01b4b553890
cmake_options=(-DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=None \
    -DOPENEXR_BUILD_PYTHON=ON)
cmaki "${cmake_options[@]}"
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
