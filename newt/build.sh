#!/bin/bash
set -e
name=newt
get_version() {
	local inst_ver=$(pkgver $name)
	local up_ver=$(wget -cqO- -T 5 -t 1 https://releases.pagure.org/newt/ | grep "newt-[0-9]+\.[0-9]+\.[0-9]+" -oE | cut -d '-' -f 2 | sort -V | tail -n 1)
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
depends=(glibc popt python tcl zlib)
filename="$name-$version.tar.gz"
direname="${filename/.tar.*/}"
if ! [[ -f $filename ]]; then
	wget -c --progress=bar:force https://releases.pagure.org/newt/$filename
fi
unpk_enter "$filename" "$direname"
sed -e '/install -m 644 $(LIBNEWT)/ s/^/#/' \
    -e '/$(LIBNEWT):/,/rv/ s/^/#/'          \
    -e 's/$(LIBNEWT)/$(LIBNEWTSH)/g'        \
    -i Makefile.in
sed -i \
    -e 's/interp->result = malloc(200);/result = malloc(200);/' \
    -e '/interp->freeProc = TCL_DYNAMIC;/d' \
    -e 's/interp->result = "no dialog mode was specified";/Tcl_SetResult(interp, "no dialog mode was specified", TCL_STATIC);/' \
    -e 's/interp->result = "multiple modes were specified";/Tcl_SetResult(interp, "multiple modes were specified", TCL_STATIC);/' \
    -e 's/interp->result = "missing text parameter";/Tcl_SetResult(interp, "missing text parameter", TCL_STATIC);/' \
    -e 's/interp->result = "height missing";/Tcl_SetResult(interp, "height missing", TCL_STATIC);/' \
    -e 's/interp->result = "height is not a number";/Tcl_SetResult(interp, "height is not a number", TCL_STATIC);/' \
    -e 's/interp->result = "width missing";/Tcl_SetResult(interp, "width missing", TCL_STATIC);/' \
    -e 's/interp->result = "width is not a number";/Tcl_SetResult(interp, "width is not a number", TCL_STATIC);/' \
    -e 's/interp->result = "list-height missing";/Tcl_SetResult(interp, "list-height missing", TCL_STATIC);/' \
    -e 's/interp->result = "list-height is not a number";/Tcl_SetResult(interp, "list-height is not a number", TCL_STATIC);/' \
    -e 's/interp->result = "yes";/Tcl_SetResult(interp, "yes", TCL_STATIC);/' \
    -e 's/interp->result = "no";/Tcl_SetResult(interp, "no", TCL_STATIC);/' \
    -e 's/interp->result = result;/Tcl_SetResult(interp, result, TCL_DYNAMIC);/' \
    -e 's/interp->result = selections\[0\];/Tcl_SetResult(interp, selections[0], TCL_DYNAMIC);/' \
    -e 's/interp->result = "bad paramter for whiptcl dialog box";/Tcl_SetResult(interp, "bad paramter for whiptcl dialog box", TCL_STATIC);/' \
    -e 's/Tcl_FreeResult(interp);/Tcl_ResetResult(interp);/' \
    -e 's/sprintf(interp->result, "%s: %s\\n",/sprintf(result, "%s: %s\\n",/' \
    whiptcl.c
cmi --prefix=/usr --with-gpm-support
cd ../
rm -rf "$filename" "$direname"
echo "$version" | sudo tee "/var/lib/custom-packages/$name"
