#!/bin/bash
# Heavily based on PKGBUILD
set -e
name=go
repo=golang/$name
version=$(gh_ver $repo)
depends=(gcc glibc libjpeg-turbo libwebp tiff xz zlib zstd)
filename="${name}${version}.src.tar.gz"
direname="$name"
download_src "https://go.dev/dl/$filename"
unpk_enter "$filename" "$direname" "src"
export GOARCH=amd64
export GOAMD64=v1 # make sure we're building for the right x86-64 version
export GOROOT_FINAL=/usr/lib/go
# GOROOT_BOOTSTRAP needs to be set to an alternative path
# if GO isn't already installed
export GOROOT_BOOTSTRAP=/usr/lib/go

# Disable dwarf5 until debugedit catches up
export GOEXPERIMENT=nodwarf5

./make.bash -v
sudo mkdir -p /usr/lib/go /usr/share/doc/$name-$version
cd ../
sudo su -c "cp -a bin pkg src lib misc api /usr/lib/go
cp -r doc/* /usr/share/doc/$name-$version
ln -sf /usr/lib/go/bin/go /usr/bin/
ln -sf /usr/lib/go/bin/gofmt /usr/bin/
install -Dm644 VERSION /usr/lib/go/VERSION
rm -rf /usr/lib/go/pkg/bootstrap
rm -rf /usr/lib/go/pkg/obj/go-build
install -Dm644 go.env /usr/lib/go/go.env"
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
