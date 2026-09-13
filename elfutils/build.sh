#!/bin/bash
set -e
name=elfutils
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -T 5 -t 1 -cqO- https://sourceware.org/elfutils/ftp/ | grep -oE 'href="[0-9.]+/"' | sed -E 's/href="([^/]+)\/"/\1/' | sort -V | tail -n 1)
	ver_check "$up_ver" "$inst_ver" && return

	local git_ver=$(timeout 5 git ls-remote --tags https://sourceware.org/git/elfutils.git | grep -oP 'refs/tags/elfutils-\K[0-9.]+$' | sort -V | tail -n 1)
	ver_check "$git_ver" "$inst_ver" && return

	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" && return

	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" && return
	fver "$name" "$inst_ver"
}

version=$(get_version)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
lfs_depends=(acl bzip2 gcc glibc libelf lz4 openssl sqlite xz zlib zstd)
depends=(libarchive openldap)
blfs_depends=(brotli curl cyrus-sasl json-c libarchive libidn2 libpsl libunistring libxml2 nghttp2)
if ! [[ -f $filename ]]; then
        wget -c --progress=bar:force https://sourceware.org/elfutils/ftp/$version/$filename
fi
rm -rf $direname
tar xf $filename
cd $direname
./configure --prefix=/usr        \
            --disable-debuginfod \
            --enable-libdebuginfod=dummy
make -C lib -j$(nproc)
make -C libelf -j$(nproc)
sudo su -c "make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig
rm /usr/lib/libelf.a"
cd ..
rm -rf $direname
tar xf $filename
cd $direname
MOCK_GCC_DIR="/tmp/mock_gcc_elfutils"
mkdir -p "$MOCK_GCC_DIR"
cat > "$MOCK_GCC_DIR/gcc" <<\GCCEOF
#!/bin/bash
REAL_GCC=$(which -a gcc | grep -v "mock_gcc_elfutils" | head -n 1)
[ -z "$REAL_GCC" ] && REAL_GCC=/usr/bin/gcc
newargs=()
for arg in "$@"; do
    [[ "$arg" == -Werror* ]] && continue
    newargs+=("$arg")
done
exec "$REAL_GCC" "${newargs[@]}"
GCCEOF
chmod +x "$MOCK_GCC_DIR/gcc"
export PATH="$MOCK_GCC_DIR:$PATH"
cmi --prefix=/usr --sysconfdir=/etc --program-prefix="eu-"
cd ..
sudo rm -rf $name-$version*
echo $version | sudo tee /var/lib/custom-packages/$name
