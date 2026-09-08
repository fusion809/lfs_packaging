#!/bin/bash
set -e
name=rust-bindgen
repo=rust-lang/$name
version=$(gh_ver $repo)
depends=(gcc glibc llvm)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c https://github.com/$repo/archive/refs/tags/v$version/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
cargo build --release
sudo su -c "install -v -m755 target/release/bindgen /usr/bin
bindgen --generate-shell-completions bash \
    > /usr/share/bash-completion/completions/bindgen
bindgen --generate-shell-completions zsh  \
    > /usr/share/zsh/site-functions/_bindgen"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
