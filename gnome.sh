#!/bin/bash

# gnome version fetcher
function gn_ver {
	local pkg_name="${2:-$1}"
	[[ "$pkg_name" == "glib" ]] && pkg_name="glib2"
	[[ "$pkg_name" == "gtk" ]] && pkg_name="gtk4"
	local lfs_vers=$(lfs_ver $name)
	local inst_ver=$(pkgver "$pkg_name")
	if [[ "$1" == "gtk3" ]]; then
		local up_ver=$(wgn_ver "gtk" "3")
		ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return

		local git_ver=$(ggn_ver "gtk" "3")
		ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
		local mon_ver=$(uver $name)
		ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
	elif [[ "$1" == "gtk" || "$1" == "gtk4" ]]; then
		local up_ver=$(wgn_ver "gtk" "4")
		ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return

		local git_ver=$(ggn_ver "gtk" "4")
		ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
		
		local mon_ver=$(uver $name)
		ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
		
		local arch_ver=$(aver "gtk4")
		ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	elif [[ "$1" == "glib" || "$1" == "glib2" ]]; then
		local up_ver=$(wgn_ver "glib2")
		ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return

		local git_ver=$(ggn_ver "glib2" "glib")
		ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return

		local mon_ver=$(uver $name)
		ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
		local arch_ver=$(aver "glib2")
		ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	elif [[ "$1" == "libpeas" ]]; then
		local up_ver=$(wlp_ver "$1")
		ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
		local git_ver=$(glp_ver "$1")
		ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
		local mon_ver=$(uver $name)
		ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
	else
		local up_ver=$(wgn_ver "$1")
		ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return

		local git_ver=$(ggn_ver "$1")
		ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
		local mon_ver=$(uver $name)
		ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
	fi
	if [[ $pkg_name == "vte" ]]; then
		pkg_name="vte3"
	fi
	local arch_ver=$(aver "$pkg_name")
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	local art_ver=$(artver $pkg_name)
	ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return

	fver "$pkg_name" "$inst_ver"
}

# libgedit-* version fetcher
function lgd_ver {
	local name=$1
	local inst_ver=$(pkgver "$name")
	local lfs_vers=$(lfs_ver $name)
	local up_ver=$(wlgd_ver $name)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return

	local git_ver=$(glgd_ver $name)
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
	local mon_ver=$(uver $name)
	ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return
	local arch_ver=$(aver "$name")
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	local art_ver=$(artver $name)
	ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}
