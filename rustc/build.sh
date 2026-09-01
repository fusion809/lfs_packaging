#!/bin/bash
set -e
name=rustc
get_version() {
    local inst_ver=$(pkgver $name)
    local up_ver=$(wget -T 5 -cqO- https://blog.rust-lang.org/releases/latest | grep "\-[0-9]\." | head -n 1 | cut -d '/' -f 5 | cut -d '-' -f 2)
    ver_check "$up_ver" "$inst_ver" && return

    local ghub_ver=$(gh_ver rust-lang/rust)
    ver_check "$ghub_ver" "$inst_ver" && return

    fver "$name" "$inst_ver"
}
version=$(get_version)
filename="$name-$version-src.tar.xz"
direname="${filename/.tar.xz/}"
depends=(openldap)
lfs_depends=(coreutils gcc glibc libffi openssl python zlib zstd)
blfs_depends=(brotli cmake curl cyrus-sasl libidn2 libpsl libunistring libxml2 llvm nghttp2)
if [[ $(free -h | tail -n 2 | head -n 1 | sed 's/Mem:\s*//g' | cut -d ' ' -f 1 | sed 's/Gi//g') -lt 15 ]]; then
	echo "You need to increase the RAM allocated to this VM to at least 16GB otherwise the build will fail." && exit 1
fi
if ! [[ -f $filename ]]; then
	wget -c https://static.rust-lang.org/dist/$filename
	#wget -c $ssl_src
fi

tar xf $filename
cd $direname
sudo mkdir -pv /opt/$name-$version      &&
sudo ln -svfn $name-$version /opt/$name
change_id=$(cat src/bootstrap/src/utils/change_tracker.rs | grep "change_id" | sed 's/^\s*change_id:\s//g' | cut -d ',' -f 1 | grep -E "^[0-9]+$" | sort -V | tail -n 1)
cat << EOF > bootstrap.toml
# See bootstrap.toml.example for more possible options,
# and see src/bootstrap/defaults/bootstrap.dist.toml for a few options
# automatically set when building from a release tarball
# (unfortunately, we have to override many of them).

# Tell x.py that the editors have reviewed the content of this file
# and updated it to follow the major changes of the building system,
# so x.py will not warn users to review that information.
change-id = $change_id

[llvm]
# When using the system installed copy of LLVM, prefer the shared libraries
link-shared = true

# If building the shipped LLVM source, only enable the x86 target
# instead of all the targets supported by LLVM.
targets = "X86"

[build]
description = "for BLFS r13.0-1024"

# Omit the documentation to save time and space (the default is to build them).
docs = false

# Only install these extended tools. Cargo, clippy, rustdoc, and rustfmt
# are installed by a default rustup installation, and rust-src is needed
# to build the Rust code in Linux kernel (in case you need such a kernel
# feature).
tools = ["cargo", "clippy", "rustdoc", "rustfmt", "src"]

[install]
prefix = "/opt/rustc-$version"
docdir = "share/doc/rustc-$version"

[rust]
channel = "stable"

# Enable the same optimizations as the official upstream build.
lto = "thin"
codegen-units = 1

# Don't build llvm-bitcode-linker which is only useful for the NVPTX
# backend that we don't enable.
llvm-bitcode-linker = false

[target.x86_64-unknown-linux-gnu]
llvm-config = "/usr/bin/llvm-config"

[target.i686-unknown-linux-gnu]
llvm-config = "/usr/bin/llvm-config"
EOF
export LIBSSH2_SYS_USE_PKG_CONFIG=1
export LIBSQLITE3_SYS_USE_PKG_CONFIG=1
(
	export PATH=$PATH:/opt/rustc-$(cat /var/lib/custom-packages/rustc | head -n 1)/bin
    cd src/tools/cargo
    cargo update --offline
)
# Strip unrecognized amx-tf32 feature to prevent LLVM fatal error:
# 1. Remove amx-tf32 from compiler target features (fixes LLVM fatal error)
find compiler/ -type f -name "*.rs" -exec sed -i "/amx-tf32/d; /amx_tf32/d" {} + 2>/dev/null || true

# 2. Map amx-tf32 to amx-tile in stdarch/core (fixes core library build)
find library/ -type f -name "*.rs" -exec sed -i 's/"amx-tf32"/"amx-tile"/g; s/"amx_tf32"/"amx_tile"/g' {} + 2>/dev/null || true

# 3 lto = "off" to fix build
sed -i 's/lto = "thin"/lto = "off"/' bootstrap.toml

./x.py build
sudo ./x.py install
sudo rm -fv /opt/rustc-$version/share/doc/rustc-$version/*.old   &&
sudo install -vm644 README.md                                \
               /opt/rustc-$version/share/doc/rustc-$version &&

sudo install -vdm755 /usr/share/zsh/site-functions      &&
sudo ln -sfv /opt/rustc/share/zsh/site-functions/_cargo \
        /usr/share/zsh/site-functions

sudo mv -v /etc/bash_completion.d/cargo /usr/share/bash-completion/completions
unset LIB{SSH2,SQLITE3}_SYS_USE_PKG_CONFIG
echo $version >> /var/lib/custom-packages/$name
sudo find /opt -maxdepth 1 -type d -name 'rustc-*' ! -name "rustc-$version" -exec sudo rm -rf {} +
