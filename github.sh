function gh_com {
    timeout 5 git ls-remote https://github.com/$1.git HEAD 2>/dev/null \
	| awk '{ print $1 }'
}

# github version fetcher

function gh_ver {
    local name
    if [[ -n ${2-} ]]; then
        name=$2
    else
        name=${1##*/}
    fi

    local lfs_vers inst_ver up_ver git_ver mon_ver vat_ver arch_ver art_ver

    lfs_vers=$(lfs_ver "$name")
    inst_ver=$(pkgver "$name")
    up_ver=$(ght_ver "$1" "${2-}")
    ver_check "$up_ver" "$inst_ver" "$lfs_vers" && return

    git_ver=$(ghl_ver "$1" "${2-}")
    ver_check "$git_ver" "$inst_ver" "$lfs_vers" && return

    mon_ver=$(uver "$name")
    ver_check "$mon_ver" "$inst_ver" "$lfs_vers" && return

    vat_ver=$(vatver "$name")
    ver_check "$vat_ver" "$inst_ver" "$lfs_vers" && return

    arch_ver=$(aver "$name")
    ver_check "$arch_ver" "$inst_ver" "$lfs_vers" && return

    art_ver=$(artver "$name")
    ver_check "$art_ver" "$inst_ver" "$lfs_vers" && return

    fver "$name" "$inst_ver"
}

