#!/bin/bash
set -e
name=nodejs
repo=$name/node
version=$(gh_ver $repo $name)
filename="node-v$version.tar.xz"
direname="${filename/.tar.*/}"
depends=(brotli c-ares gcc glibc icu libuv nghttp2 openssl simdutf which zlib)
if ! [[ -f $filename ]]; then
	wget -c https://nodejs.org/dist/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
configure_options=(--prefix=/usr          \
            --shared-brotli        \
            --shared-cares         \
            --shared-libuv         \
            --shared-nghttp2       \
            --shared-openssl       \
            --shared-simdutf       \
            --shared-zlib          \
	    --with-intl=system-icu)
cmi "${configure_options[@]}"
sudo ln -sf node /usr/share/doc/node-$version
cd ..
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
