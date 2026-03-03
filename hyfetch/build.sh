#!/bin/bash
set -e
# Variable declarations
name=hyfetch
depends=(fastfetch)
lfs_depends=(bash coreutils)
blfs_depends=(git rustc)
# Fetch and unpack source
if ! [[ -d $name ]]; then
	git clone https://github.com/hykilpikonna/hyfetch
fi
# Compile and install
cd $name
git checkout master
git fetch --tags --all
version=$(git describe --tags --abbrev=0)
git checkout $version
export PATH=$PATH:/opt/rustc/bin
cargo fetch --locked --target "$(rustc --print host-tuple)"
cargo build --frozen --release --all-features
cargo test --frozen --all-features
sudo install -Dm 755 "target/release/${name}" "/usr/bin/${name}"
sudo install -Dm 644 "docs/${name}.1" "/usr/share/man/man1/${name}.1"
sudo install -Dm 644 "${name}/scripts/autocomplete.bash" "/usr/share/bash-completion/completions/${name}"
sudo install -Dm 644 "${name}/scripts/autocomplete.zsh" "/usr/share/zsh/site-functions/_${name}"
sudo install -Dm 644 README.md "/usr/share/doc/${name}-$version/README.md"
# Add to database
echo $version > /var/lib/lfs-custom-packages/$name