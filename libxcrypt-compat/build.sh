#!/bin/bash
set -e
name=libxcrypt-compat
_name=libxcrypt
repo=besser82/$_name
homepage="https://github.com/besser82/libxcrypt/"
description="Modern library for one-way hashing of passwords."
version=$(gh_ver $repo)
filename="$_name-$version.tar.xz"
direname="${filename/.tar.*/}"
ghr_download "$repo" "v$version" "$filename"
rootdir=$PWD
unpk_enter "$filename" "$direname"
python - <<'PY'
from pathlib import Path

for filename in ("crypt-gost-yescrypt.c", "crypt-sm3-yescrypt.c"):
    source = Path("lib") / filename
    text = source.read_text(encoding="utf-8")
    old = "strchr ((const char *) intbuf->retval + 3, '$')"
    new = "strchr ((char *) intbuf->retval + 3, '$')"
    if old in text:
        text = text.replace(old, new, 1)
    elif new not in text:
        raise SystemExit(f"Could not find the yescrypt output scan in {source}")
    source.write_text(text, encoding="utf-8")
PY
config_options=(--prefix=/usr \
    --disable-static \
    --enable-hashes=strong,glibc \
    --enable-obsolete-api=glibc \
    --disable-failure-tokens)
pkgdir=$rootdir/pkg
mkdir -p $pkgdir
./configure --prefix=/usr \
    --disable-static \
    --enable-hashes=strong,glibc \
    --enable-obsolete-api=glibc \
    --disable-failure-tokens
make -j$(nproc)
make DESTDIR="$pkgdir" install
rm -rf "${pkgdir}"/usr/{include,lib/{lib*.so,pkgconfig},share}
sudo rsync -aHAX "$pkgdir"/ /
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
