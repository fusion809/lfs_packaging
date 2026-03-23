#!/bin/bash
set -e
name=elfutils
version=$(wget -cqO- https://sourceware.org/git/?p=elfutils.git\;a=tags | grep "elfutils-" | head -n 1 | cut -d "-" -f 2 | sed "s/<.*//g")
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
