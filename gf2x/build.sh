#!/bin/bash
set -e
name=gf2x
get_version() {
	local git_ver=$(timeout 5 git ls-remote --tags --refs https://gitlab.inria.fr/gf2x/gf2x.git | grep -v "rc" | grep "refs/tags/gf2x-[0-9.]+" -oE | cut -d '-' -f 2 | sort -V | tail -n 1)
	local inst_ver=$(pkgver $name)
	local arch_ver=$(aver $name)
	ver_check "$git_ver" "$inst_ver" "$arch_ver" && return
	local art_ver=$(artver $name)
	ver_check "$art_ver" "$inst_ver" "$arch_ver" && return
	fver "$name" "$inst_ver"
}
homepage="https://gitlab.inria.fr/gf2x/gf2x"
description="Library for multiplying polynomials over a binary field."
version=$(get_version)
direname="$name-$name-$version"
direname2="$name-$version"
filename="$direname.tar.gz"
download_src "https://gitlab.inria.fr/gf2x/gf2x/-/archive/$direname2/$filename"
unpk_enter "$filename"
sudo autoreconf -fiv
sudo chown $USER -R .
python3 - <<'PY'
from pathlib import Path
import re
import sys

path = Path("configure")

try:
    text = path.read_text()
except OSError as exc:
    print(f"WARNING: Cannot read {path}: {exc}")
    sys.exit(0)

pattern = re.compile(
    r"(cat >conftest\.c <<EOF\n)"
    r"((?:(?!EOF\n).)*?\bexit\s*\(\s*0\s*\)\s*;.*?\nEOF)",
    re.DOTALL,
)

matches = list(pattern.finditer(text))
if len(matches) != 4:
    print(
        f"WARNING: Expected 4 exit() test bodies, found {len(matches)}; "
        "skipping the patch."
    )
    sys.exit(0)

missing = [
    match for match in matches
    if "#include <stdlib.h>" not in match.group(2)
]

if not missing:
    print("All 4 exit() test bodies already include <stdlib.h>.")
    sys.exit(0)

patched = pattern.sub(
    lambda match: (
        match.group(1)
        + (
            "#include <stdlib.h>\n"
            if "#include <stdlib.h>" not in match.group(2)
            else ""
        )
        + match.group(2)
    ),
    text,
)

verified = list(pattern.finditer(patched))
if len(verified) != 4 or any(
    "#include <stdlib.h>" not in match.group(2)
    for match in verified
):
    print("WARNING: Verification failed; skipping the patch.")
    sys.exit(0)

try:
    path.write_text(patched)
except OSError as exc:
    print(f"WARNING: Cannot write {path}: {exc}")
    sys.exit(0)

print(f"Patched {len(missing)} test bodies; all 4 verified.")
PY
conf_options=(--prefix=/usr \
    --enable-sse2 \
    --disable-pclmul)
cmi "${conf_options[@]}"
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
