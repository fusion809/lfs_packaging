#!/bin/bash
set -e
name=cargo-c
repo=lu-zero/$name
version=$(gh_ver $repo)
depends=(brotli curl cyrus-sasl gcc glibc libidn2 libpsl libssh2 libunistring nghttp2 openldap openssl sqlite zlib zstd)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/archive/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
curl -fLO https://github.com/lu-zero/cargo-c/releases/download/v$version/Cargo.lock
export LIBSSH2_SYS_USE_PKG_CONFIG=1    &&
export LIBSQLITE3_SYS_USE_PKG_CONFIG=1 &&

cargo build --release
sudo install -vm755 target/release/cargo-{capi,cbuild,cinstall,ctest} /usr/bin/
unset LIB{SSH2,SQLITE3}_SYS_USE_PKG_CONFIG
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
