#!/bin/bash
set -e
name=mitkrb
_name=krb5
homepage="http://web.mit.edu/kerberos/"
description="The Kerberos network authentication system."
dist="https://kerberos.org/dist/krb5/"
majMinVer=$(wget -T 5 -t 1 -cqO- $dist | grep "/</a>" | tail -n 1 | 
	cut -d '"' -f 8 | sed 's|/||g')
get_version() {
  local inst_ver=$(pkgver $name)
  local lfs_vers=$(lfs_ver $name)
  if echo "$majVer" | grep -q "[0-9]"; then
    local version=$(wget -T 5 -t 1 -cqO- $dist/$majMinVer/ | cut -d '"' -f 8 | 
	    grep "^krb5" | grep -v "asc" | cut -d '-' -f 2 | 
	    sed 's/.tar.gz//g' | sort | uniq | tail -n 1)
    ver_check "$version" "$inst_ver" "$lfs_vers" && return
  fi
  local mon_ver=$(uver $name | sed 's/-final//g')
  ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
  local vat_ver=$(vatver $_name)
  ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return
  local arch_ver=$(aver $_name)
  ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
  local art_ver=$(artver $_name)
  ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return
  local nix_ver=$(nixver $_name)
  ver_check "$nix_ver" "$inst_ver" "$lfs_vers" && return
  fver "$name" "$inst_ver"
}
version=$(get_version)
dirname="$_name-$version"
filename="$dirname.tar.gz"
depends=(bash e2fsprogs glibc keyutils lmdb openssl)
download_src "$dist/$majMinVer/$filename"
unpk_enter "$filename" "$direname"
patch -Np1 <<'PATCH'
--- a/src/plugins/tls/k5tls/openssl.c
+++ b/src/plugins/tls/k5tls/openssl.c
@@ -162,7 +162,7 @@
 get_cert_sans(const X509 *x)
 {
     int ext;
-    X509_EXTENSION *san_ext;
+    const X509_EXTENSION *san_ext;
 
     ext = X509_get_ext_by_NID(x, NID_subject_alt_name, -1);
     if (ext < 0)
@@ -178,12 +178,33 @@
 static int
 get_cert_cn(const X509 *x, char *buf, size_t bufsize)
 {
-    X509_NAME *name;
+    const X509_NAME *name;
+    const X509_NAME_ENTRY *entry;
+    const ASN1_STRING *data;
+    unsigned char *utf8 = NULL;
+    size_t copylen;
+    int idx, len;
 
     name = X509_get_subject_name(x);
     if (name == NULL)
         return -1;
-    return X509_NAME_get_text_by_NID(name, NID_commonName, buf, bufsize);
+    idx = X509_NAME_get_index_by_NID(name, NID_commonName, -1);
+    if (idx < 0)
+        return -1;
+    entry = X509_NAME_get_entry(name, idx);
+    data = X509_NAME_ENTRY_get_data(entry);
+    len = ASN1_STRING_to_UTF8(&utf8, data);
+    if (len < 0)
+        return -1;
+    if (bufsize == 0) {
+        OPENSSL_free(utf8);
+        return 0;
+    }
+    copylen = (size_t)len < bufsize - 1 ? (size_t)len : bufsize - 1;
+    memcpy(buf, utf8, copylen);
+    buf[copylen] = 0;
+    OPENSSL_free(utf8);
+    return (int)copylen;
 }
 
 /* Return true if text matches any of the addresses we can recover from x. */
PATCH
gap_patches $name || echo "patching failed. Continuing"
cd src &&
sed -i -e '/eq 0/{N;s/12 //}' plugins/kdb/db2/libdb2/test/run.test &&

configure_options=(
    --prefix=/usr            \
    --sysconfdir=/etc        \
    --localstatedir=/var/lib \
    --runstatedir=/run       \
    --with-system-et         \
    --with-system-ss         \
    --with-system-verto=no   \
    --enable-dns-for-realm   \
    --disable-rpath
)
mkdir -p build
cd build
../configure "${configure_options[@]}"
maki
sudo cp -vfr ../../doc -T /usr/share/doc/$dirname
export CP="/var/lib/custom-packages"
echo "$version" | sudo tee "$CP/$name"
cd ../..
rm -rf "$dirname" "$filename"
