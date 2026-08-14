#!/bin/bash
set -e
source ~/lfs_packaging/shared-funcs.sh
name=elfutils
get_version() {
	local up_ver=$(wget -cqO- https://sourceware.org/elfutils/ftp/ | grep -oE 'href="[0-9.]+/"' | sed -E 's/href="([^/]+)\/"/\1/' | sort -V | tail -n 1)
	if echo "$up_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$up_ver"
		return 0
	fi

	local git_ver=$(git ls-remote --tags https://sourceware.org/git/elfutils.git | grep -oP 'refs/tags/elfutils-\K[0-9.]+$' | sort -V | tail -n 1)
	if echo "$git_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$git_ver"
		return 0
	fi

	local arch_ver=$(aver $name)
	if echo "$arch_ver" | grep -q "[0-9]\.[0-9]"; then
		echo "$arch_ver"
		return 0
	fi
}

version=$(get_version)
filename="$name-$version.tar.bz2"
direname="${filename/.tar.bz2/}"
lfs_depends=(bzip2
	gcc
	glibc
	libelf
	sqlite
	xz
	zlib
	zstd)
blfs_depends=(curl
	json-c
	libarchive)
if ! [[ -f $filename ]]; then
        wget -c https://sourceware.org/elfutils/ftp/$version/$filename
fi
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
./configure --prefix=/usr --sysconfdir=/etc --program-prefix="eu-"
make -j$(nproc)
sudo make install
cd ..
sudo rm -rf $name-$version*
echo $version > /var/lib/custom-packages/$name
