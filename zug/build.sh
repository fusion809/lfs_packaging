#!/bin/bash
set -e
name=zug
repo=arximboldi/$name
homepage="https://sinusoid.es/zug/"
description="Transducers for C++."
version=$(gh_ver $repo)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
depends=(catch2 cmake git)
download_git "https://github.com/$repo.git"
cd $name
git checkout v$version
git cherry-pick -n c8c74ada30d931e40636c13763b892f20d3ce1ae # Add missing include
CXXFLAGS+=' -D_GLIBCXX_USE_OLD_GENERATE_CANONICAL'
cmaki -DCMAKE_INSTALL_PREFIX=/usr
cd ../..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
