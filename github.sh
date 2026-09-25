function gh_com {
    timeout 5 git ls-remote https://github.com/$1.git HEAD 2>/dev/null \
	| awk '{ print $1 }'
}

# github version fetcher
function gh_ver {
	if [[ -n "$2" ]]; then
		name="$2"
	else
		name=$(echo $1 | cut -d '/' -f 2)
	fi
	local lfs_vers=$(lfs_ver $name)
	local inst_ver=$(pkgver $name)
	local up_ver=$(ght_ver $1)
	ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return
	local git_ver=$(ghl_ver $1)
	ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return
	local vat_ver=$(vatver $name)
	ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return
	local arch_ver=$(aver $name)
	ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return
	local art_ver=$(artver $name)
	ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return
	fver "$name" "$inst_ver"
}