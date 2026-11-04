#!/bin/bash
set -e
name=zug
repo=arximboldi/$name
homepage="https://sinusoid.es/zug/"
description="Transducers for C++."
version=$(gh_ver $repo)
depends=(catch2 cmake git)
download_github "$repo"
cd $name
git checkout v$version
git cherry-pick -n c8c74ada30d931e40636c13763b892f20d3ce1ae # Add missing include
CXXFLAGS+=' -D_GLIBCXX_USE_OLD_GENERATE_CANONICAL'
cmaki -DCMAKE_INSTALL_PREFIX=/usr
cd ../..
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
