#!/bin/bash
set -e
# Variable declarations
name=hyfetch
depends=(fastfetch)
lfs_depends=(bash coreutils gcc glibc)
blfs_depends=(rustc)
version=$(gh_ver hykilpikonna/hyfetch)
filename="$name-$version.tar.gz"
direname="${filename/.tar.gz/}"
# Fetch and unpack source
if ! [[ -f $filename ]]; then
	wget -c https://github.com/hykilpikonna/hyfetch/archive/$version.tar.gz -O $filename
fi
# Compile and install
rm -rf $direname
tar xf $filename
cd $direname
export PATH=$PATH:/opt/rustc/bin
cargo fetch --locked --target "$(rustc --print host-tuple)"
cargo build --frozen --release --all-features
cargo test --frozen --all-features
sudo install -Dm 755 "target/release/${name}" "/usr/bin/${name}"
sudo install -Dm 644 "docs/${name}.1" "/usr/share/man/man1/${name}.1"
sudo install -Dm 644 "${name}/scripts/autocomplete.bash" "/usr/share/bash-completion/completions/${name}"
sudo install -Dm 644 "${name}/scripts/autocomplete.zsh" "/usr/share/zsh/site-functions/_${name}"
sudo install -Dm 644 README.md "/usr/share/doc/${name}-$version/README.md"
cd ..
rm -rf $filename $direname
# Add to database
echo $version > /var/lib/custom-packages/$name
