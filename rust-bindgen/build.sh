#!/bin/bash
set -e
name=rust-bindgen
repo=rust-lang/$name
# gh_ver sometimes reports an out-of-date version due to the releases page having older versions listed than are tagged
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -cqO- -T 5 -t 1 https://github.com/$repo/tags | grep "v[0-9]+\.[0-9]+\.[0-9]+" -oE | sed 's/^v//g' | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://github.com/$repo.git | grep "v[0-9]+\.[0-9]+\.[0-9]+" -oE | sed 's/^v//g' | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
version=$(get_version)
depends=(gcc glibc llvm)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://github.com/$repo/archive/refs/tags/v$version/$filename
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
