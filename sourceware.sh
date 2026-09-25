#!/bin/bash
function sw_ver {
	local name=$1
	local inst_ver=$(pkgver $name)
	local lfs_vers=$(lfs_ver $name)
    local up_ver=$(wsw_ver $name)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(gsw_ver $name)
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
    local vat_ver=$(vatver $name)
    ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return
    local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	local art_ver=$(artver $name)
	ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}