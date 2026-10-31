#!/bin/bash
set -e
name=gavl
repo=bplaum/$name
homepage="https://github.com/bplaum/gavl"
description="Low-level library, upon which multimedia APIs can be built."
version=$(gh_ver $repo)
depends=(glibc nettle gnutls libdrm libglvnd libva)
download_git "$homepage.git"
cd $name
git checkout v$version
git cherry-pick -n 5b776fe265810ff98f3a4e918d2afb0d337aa965 # support nettle 4
sudo autoreconf -fi
sudo chown $USER -R .
cmi --prefix=/usr --sysconfdir=/etc --localstatedir=/var --with-cpuflags=none
maki
cd ../
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
