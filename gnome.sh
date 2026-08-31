#!/bin/bash

# gnome version fetcher
function gn_ver {
	local inst_ver=$(pkgver "$1")
	if [[ "$1" == "gtk3" ]]; then
		local up_ver=$(wgn_ver "gtk" "3")
		ver_check "$up_ver" "$inst_ver" && return

		local git_ver=$(ggn_ver "gtk" "3")
		ver_check "$git_ver" "$inst_ver" && return
	elif [[ "$1" == "glib" ]]; then
		local up_ver=$(wgn_ver "glib")
		ver_check "$up_ver" "$inst_ver" && return

		local git_ver=$(gglib2_ver)
		ver_check "$git_ver" "$inst_ver" && return

		local arch_ver=$(aver "glib2")
		ver_check "$arch_ver" "$inst_ver" && return
	elif [[ "$1" == "libpeas" ]]; then
		local up_ver=$(wlp_ver "$1")
		ver_check "$up_ver" "$inst_ver" && return
		local git_ver=$(glp_ver "$1")
		ver_check "$git_ver" "$inst_ver" && return
	else
		local up_ver=$(wgn_ver "$1")
		ver_check "$up_ver" "$inst_ver" && return

		local git_ver=$(ggn_ver "$1")
		ver_check "$git_ver" "$inst_ver" && return
	fi
	local arch_ver=$(aver "$1")
	ver_check "$arch_ver" "$inst_ver" && return

	local lfs_vers=$(lfs_ver "$1")
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$1" "$inst_ver"
}

# libgedit-* version fetcher
function lgd_ver {
	local name=$1
	local inst_ver=$(pkgver "$name")
	local up_ver=$(wlgd_ver $name)
	ver_check "$up_ver" "$inst_ver" && return

	local git_ver=$(glgd_ver $name)
	ver_check "$git_ver" "$inst_ver" && return
	local arch_ver=$(aver "$name")
	ver_check "$arch_ver" "$inst_ver" && return
	local lfs_vers=$(lfs_ver $name)
	ver_check "$lfs_vers" "$inst_ver" && return
	fver "$name" "$inst_ver"
}
