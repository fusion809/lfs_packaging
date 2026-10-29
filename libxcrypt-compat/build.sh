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

source = Path("lib/crypt-gost-yescrypt.c")
text = source.read_text(encoding="utf-8")
old_declaration = "  char *hptr = strchr ((const char *) intbuf->retval + 3, '$');"
new_declaration = "  const char *hptr = strchr ((const char *) intbuf->retval + 3, '$');"
old_input_cast = "(uint8_t *) hptr"
new_input_cast = "(const uint8_t *) hptr"

if old_declaration in text:
    text = text.replace(old_declaration, new_declaration, 1)
elif new_declaration not in text:
    raise SystemExit(f"Could not find the hptr declaration in {source}")

text = text.replace(old_input_cast, new_input_cast, 1)
source.write_text(text, encoding="utf-8")
PY
config_options=(--prefix=/usr \
    --disable-static \
    --enable-hashes=strong,glibc \
    --enable-obsolete-api=glibc \
    --disable-failure-tokens)
pkgdir=$rootdir/pkg
mkdir $pkgdir
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
