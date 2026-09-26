#!/bin/bash
set -e
name=pay-respects
repo=iff/$name
version=$(cb_ver $repo)
depends=(gcc glibc)
filename="$name-$version.tar.gz"
direname="$name"
cba_download "$repo" "v$version" "$filename"
unpk_enter "$filename" "$direname"
make -j$(nproc) build-all
sudo ln -sf /opt/rustc/bin/{cargo,rustc} /usr/bin/
make install-all
sudo rm /usr/bin/{cargo,rustc}
sudo install -Dm755 $HOME/.cargo/bin/pay-respects /usr/bin/
sudo rm -rf $HOME/.cargo
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
