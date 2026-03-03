#!/bin/bash
set -e
depends=(fastfetch)
lfs_depends=(bash coreutils)
blfs_depends=(git rustc)
NAME=hyfetch
if ! [[ -d hyfetch ]]; then
	git clone https://github.com/hykilpikonna/hyfetch
fi

cd hyfetch
git checkout master
git fetch --tags --all
VERSION=$(git describe --tags --abbrev=0)
git checkout $VERSION
export PATH=$PATH:/opt/rustc/bin
cargo fetch --locked --target "$(rustc --print host-tuple)"
cargo build --frozen --release --all-features
cargo test --frozen --all-features

sudo install -Dm 755 "target/release/${NAME}" "/usr/bin/${NAME}"
sudo install -Dm 644 "docs/${NAME}.1" "/usr/share/man/man1/${NAME}.1"
sudo install -Dm 644 "${NAME}/scripts/autocomplete.bash" "/usr/share/bash-completion/completions/${NAME}"
sudo install -Dm 644 "${NAME}/scripts/autocomplete.zsh" "/usr/share/zsh/site-functions/_${NAME}"
sudo install -Dm 644 README.md "/usr/share/doc/${NAME}-$VERSION/README.md"
echo $VERSION > /var/lib/lfs-custom-packages/$NAME