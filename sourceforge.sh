#!/bin/bash
# SourceForge version fetcher
function sf_ver {
	local repo=$1
	local name=$(echo $repo | cut -d '/' -f 1)
	local lfs_vers=$(lfs_ver $name)
    local inst_ver=$(pkgver $name)
    local up_ver=$(wsf_ver $repo)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(gsf_ver $repo)
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
    local mon_ver=$(uver $name)
	ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
    local vat_ver=$(vatver $name)
    ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return
    local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	local art_ver=$(artver $name)
	ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}
