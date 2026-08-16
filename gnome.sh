#!/bin/bash

# gnome version fetcher
function gn_ver {
	if [[ "$1" == "gtk3" ]]; then
		local up_ver=$(wgn_ver "gtk" "3")
		ver_check "$up_ver" && return

		local git_ver=$(ggn_ver "gtk" "3")
		ver_check "$git_ver" && return
	else
		local up_ver=$(wgn_ver "$1")
		ver_check "$up_ver" && return
		local git_ver=$(ggn_ver "$1" "v[0-9]")
		ver_check "$git_ver" && return
	fi
	local arch_ver=$(aver "${2:-$1}")
	ver_check "$arch_ver" "$name" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$name" && return
}

# libgedit-* version fetcher
function lgd_ver {
	local name=$1
	local up_ver=$(wlgd_ver $name)
	ver_check "$up_ver" && return

	local git_ver=$(glgd_ver $name)
	ver_check "$git_ver" && return
	local arch_ver=$(aver "$name")
	ver_check "$arch_ver" "$name" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$name" && return
}