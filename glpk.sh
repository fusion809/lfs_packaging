#!/bin/bash
function gglpk_ver {
	local URL="https://salsa.debian.org/science-team/glpk.git"
    timeout 5 git ls-remote --tags --refs $URL 2>/dev/null | grep "upstream" \
	| cut -d '/' -f 4 | sort -V | tail -n 1
}

function wglpk_ver {
	wget -T 5 -t 1 -cqO- https://salsa.debian.org/science-team/glpk/-/tags \
	| grep "upstream/[0-9.]+" -oE | cut -d '/' -f 2 | sort -V | tail -n 1
}

function glpk_ver {
	local name="glpk"
	local inst_ver=$(pkgver $name)
	local arch_ver=$(arch_ver $name)
	local up_ver=$(wglpk_ver)
	ver_check "$up_ver" "$inst_ver" "$arch_ver" && return
	local git_ver=$(gglpk_ver)
	ver_check "$git_ver" "$inst_ver" "$arch_ver" && return
	local wgnu_vers=$(wgnu_ver "$name")
	ver_check "$wgnu_vers" "$inst_ver" "$arch_ver" && return
	local nix_ver=$(nixver $name)
	ver_check "$nix_ver" "$inst_ver" "$arch_ver" && return
	local art_ver=$(artver $name)
	ver_check "$art_ver" "$inst_ver" "$arch_ver" && return
	fver "$name" "$inst_ver"
}