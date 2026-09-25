#!/bin/bash
function wkap_ver {
	wget -T 5 -t 1 -cqO- https://download.kde.org/stable/release-service \
	| grep -oE "[0-9]+\.[0-9]+\.[0-9]+" | sort -V | tail -n 1
}

function kap_ver {
	local name=$1
	local lfs_vers=$(lfs_ver $name)
	local inst_ver=$(pkgver $name)
	local up_ver=$(wkap_ver)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(gkap_ver $name)	
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