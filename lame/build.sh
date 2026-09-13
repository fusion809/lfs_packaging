#!/bin/bash
set -e
name=lame
repo=${name}project/$name
version=$(gh_ver $repo)
depends=(glibc ncurses)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://downloads.sourceforge.net/lame/$filename
fi
rm -rf "$direname"
tar xf "$filename"
cd "$direname"
sed -i -e 's/^\(\s*hardcode_libdir_flag_spec\s*=\).*/\1/' configure
./configure --prefix=/usr --disable-static --enable-mp3rtp
# Fix: set_id3v2tag in parse.c incorrectly called utf8/ucs2 functions with
# unsigned short* arg; upstream collapsed to utf16-only. Also remove the
# stale TENC_UTF8 paths from id3_tag() that fed into it.
python3 - <<'PYEOF'
import re, sys

with open("frontend/parse.c") as f:
    src = f.read()

# Replace the broken set_id3v2tag (with enc param and utf8/ucs2 calls)
old = re.search(
    r'#ifdef ID3TAGS_EXTENDED\nstatic int\nset_id3v2tag\(lame_global_flags\* gfp, TextEncoding enc.*?^#endif',
    src, re.DOTALL | re.MULTILINE)
if old:
    new_func = """#ifdef ID3TAGS_EXTENDED
static int
set_id3v2tag(lame_global_flags* gfp, int type, unsigned short const* str)
{
    switch (type)
    {
        case 'a': return id3tag_set_textinfo_utf16(gfp, "TPE1", str);
        case 't': return id3tag_set_textinfo_utf16(gfp, "TIT2", str);
        case 'l': return id3tag_set_textinfo_utf16(gfp, "TALB", str);
        case 'g': return id3tag_set_textinfo_utf16(gfp, "TCON", str);
        case 'c': return id3tag_set_comment_utf16(gfp, 0, 0, str);
        case 'n': return id3tag_set_textinfo_utf16(gfp, "TRCK", str);
        case 'y': return id3tag_set_textinfo_utf16(gfp, "TYER", str);
        case 'v': return id3tag_set_fieldvalue_utf16(gfp, str);
    }
    return 0;
}
#endif"""
    src = src[:old.start()] + new_func + src[old.end():]

# Fix id3_tag: remove TENC_UTF8 branch, use TENC_UTF16 only
src = src.replace(
    "    if ((enc == TENC_UTF16 || enc == TENC_UTF8) && type != 'v' ) {",
    "    if (enc == TENC_UTF16 && type != 'v' ) {")
src = src.replace(
    "        case TENC_UTF16:  x = toUtf16(str);  break;\n        case TENC_UTF8:   x = toUtf8(str);   break;\n",
    "        case TENC_UTF16:  x = toUtf16(str);  break;\n")
src = src.replace(
    "        case TENC_UTF16:  result = set_id3v2tag(gfp, enc, type, x); break;\n        case TENC_UTF8:   result = set_id3v2tag(gfp, enc, type, x); break;\n",
    "        case TENC_UTF16:  result = set_id3v2tag(gfp, type, x); break;\n")

with open("frontend/parse.c", "w") as f:
    f.write(src)
print("parse.c patched OK")
PYEOF
# Fix: export hip_set_pinfo and hip_finish_pinfo so the frontend can link
grep -q 'hip_finish_pinfo' include/libmp3lame.sym || \
    sed -i 's/^hip_decode1_headersB$/hip_decode1_headersB\nhip_set_pinfo\nhip_finish_pinfo/' include/libmp3lame.sym
make -j$(nproc)
sudo make pkghtmldir=/usr/share/doc/$direname install
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
