#!/bin/bash
function artver {
	local name=$(echo $1 | tr '[:upper:]' '[:lower:]')
	local ver=$(wget -T 5 -t 1 -cqO- https://packages.artixlinux.org/packages/{world,system,galaxy}/{x86_64,any}/$name/ | grep "$name [0-9.]+[a-z0-9]*" -oE | head -n 1 | cut -d ' ' -f 2)
	if [[ "$name" == "gcc" ]]; then
		echo $ver | sed -E 's/\.1$/\.0/g'
	else
		echo $ver
	fi
}

function gent_ver {
	local pkg="$1"
	local name=$(echo $pkg | cut -d '/' -f 2)
	wget -T 5 -t 1 -cqO- https://packages.gentoo.org/packages/$pkg \
	| grep -oE "$name-[0-9.]+ebuild" | sed 's/\.ebuild//g' | sed "s/$name-//g" \
	| sort -V | tail -n 1
}

function gver {
	local arg=$1
	local pkg=${arg##*/}
	local atom=$arg
	local candidates candidate version versions

	if [[ "$arg" != */* ]]; then
		candidates=$(
			wget -T 10 -t 1 -qO- \
				"https://gpo.zugaina.org/Search?search=$pkg" |
			grep -oE 'href="/[^"]+"' |
			sed -E 's|href="/||; s|"$||' |
			grep -E "/${pkg}$"
		)

		[[ -n "$candidates" ]] || return 1

		# Find the candidate with the highest stable version.
		while IFS= read -r candidate; do
			version=$(
				wget -T 10 -t 1 -qO- \
					"https://gpo.zugaina.org/$candidate" |
				grep -oE "${pkg}-[0-9][[:alnum:]_.+-]*" |
				sed "s/^${pkg}-//" |
				grep -vE '(^|[._-])9999([._-]|$)|_p[0-9]+$' |
				sed -E 's/-r[0-9]+$//' |
				sort -V |
				tail -n1
			)

			if [[ -n "$version" ]]; then
				versions+=("$version $candidate")
			fi
		done <<< "$candidates"

		[[ ${#versions} -gt 0 ]] || return 1

		atom=$(
			printf '%s\n' "${versions[@]}" |
			sort -V |
			tail -n1 |
			sed 's/^[^ ]* //'
		)
	fi

	wget -T 10 -t 1 -qO- \
		"https://gpo.zugaina.org/$atom" |
	grep -oE "${pkg}-[0-9][[:alnum:]_.+-]*" |
	sed "s/^${pkg}-//" |
	grep -vE '(^|[._-])9999([._-]|$)|_p[0-9]+$' |
	sed -E 's/-r[0-9]+$//' |
	sort -V |
	tail -n1
}

function lfs_ver {
	# Some local package names differ from LFS/BLFS tarball names — map them here.
	# fallback_page: relative path to the individual BLFS page for packages whose
	# version doesn't appear in the index pages (e.g. listed by display name, not tarball).
	local search_name fallback_page
	case "$1" in
		mitkrb) search_name="krb5"; fallback_page="blfs-mitkrb.html" ;;
		vte) search_name="vte" ; fallback_page="blfs-vte.html";;
		*)       search_name="$1";  fallback_page="" ;;
	esac

	# Try the index pages first.
	local ver
	ver=$(cat $HOME/.cache/*lfs*index.html \
		| grep -iE ">$search_name-[0-9.]+" \
		| grep -v "docbook5.html" \
		| grep -vE "vte-2\.[0-9]+" \
		| grep -v "\.so" \
		| grep -v "emu/dolphin" \
		| sed -E "s/.*$search_name-([0-9.]+[-rc0-9]*).*/\1/I" \
		| grep -E "^[0-9.]+[-rc0-9]*$" | sed 's|-$||g' | sort -V | tail -n 1)

	# If not found and a fallback page is defined, scrape the individual BLFS page.
	if [[ -z "$ver" && -n "$fallback_page" ]]; then
		ver=$(cat $HOME/.cache/$fallback_page \
			| grep -iE "$search_name-[0-9]+\.[0-9]" \
			| sed -E "s/.*$search_name-([0-9]+\.[0-9]+(\.[0-9]+)?).*/\1/I" \
			| grep -E "^[0-9.]+[-rc0-9]*$" | sort -V | tail -n 1)
	fi
	echo "$ver"
}

function nixver {
    if [[ -z "$1" ]]; then
        echo "Usage: nixver PACKAGE" >&2
        return 1
    fi

    local pkg="$1"
    local index
    local response

    index=$(
        wget -qO- \
            --user='aWVSALXpZv' \
            --password='X8gPHnzL52wFEekuxsfQ9cSh' \
            'https://search.nixos.org/backend/_aliases' |
        grep -oE 'latest-[0-9]+-nixos-unstable' |
        sed 's/^latest-\([0-9][0-9]*\)-nixos-unstable$/\1/' |
        sort -n |
        tail -n1
    )

    if [[ -z "$index" ]]; then
        echo "Could not determine current NixOS Search index" >&2
        return 1
    fi

    response=$(
        wget -qO- \
            --user='aWVSALXpZv' \
            --password='X8gPHnzL52wFEekuxsfQ9cSh' \
            --header='Content-Type: application/json' \
            --post-data="{\"query\":{\"bool\":{\"filter\":[{\"term\":{\"type\":\"package\"}}],\"must\":[{\"term\":{\"package_attr_name\":\"$pkg\"}}]}}}" \
            "https://search.nixos.org/backend/latest-${index}-nixos-unstable/_search"
    ) || return 1

    printf '%s\n' "$response" |
        sed -n 's/.*"package_pversion":"\([^"]*\)".*/\1/p' |
        head -n1
}

typeset -A uver_projects=(
	go	1227
	scc	376740
)

typeset -g UVER_CACHE=${XDG_CACHE_HOME:-$HOME/.cache}/uver
typeset -g UVER_CACHE_TTL=300

uver() {
	local pkg=${1:l}
	local build repo name projects project_count
	local project_id backend homepage ecosystem
	local cache_file cache_time now version tags line
	local -a project_lines matches

	if [[ -z "$pkg" ]]; then
		print -u2 'usage: uver package'
		return 2
	fi

	mkdir -p "$UVER_CACHE"

	projects=$(
		timeout 15 wget -qO- \
			"https://release-monitoring.org/api/v2/projects/?name=$pkg&items_per_page=10" |
		python3 -c '
import json
import sys

for p in json.load(sys.stdin).get("items", []):
    print(
        str(p.get("id", "")) + "\t" +
        str(p.get("backend", "")) + "\t" +
        str(p.get("homepage", "")) + "\t" +
        str(p.get("ecosystem", ""))
    )
	'
	)

	if [[ -z "$projects" ]]; then
		print -u2 "No Anitya project found for $pkg"
		return 1
	fi

	project_lines=("${(@f)projects}")
	project_count=${#project_lines}

	# No ambiguity: do not inspect build.sh.
	if (( project_count == 1 )); then
		IFS=$'\t' read -r project_id backend homepage ecosystem <<< "${project_lines[1]}"
	else
		# Ambiguous package name: use build.sh to identify the upstream repo.
		build=$LFP/$pkg/build.sh

		if [[ ! -f "$build" ]]; then
			print -u2 "Multiple Anitya projects found for $pkg; no $build"
			return 1
		fi

		repo=$(
			sed -n '
				/^[[:space:]]*repo=/ {
					s/^[[:space:]]*repo=[[:space:]]*//
					p
					q
				}
			' "$build"
		)

		if [[ -z "$repo" ]]; then
			print -u2 "Multiple Anitya projects found for $pkg; no repo= in $build"
			return 1
		fi

		# Remove matching surrounding quotes.
		repo=${repo#\"}
		repo=${repo%\"}
		repo=${repo#\'}
		repo=${repo%\'}

		# Expand variables such as $name in repo=golang/$name.
		name=$pkg
		repo=${(e)repo}

		matches=()

		for line in "${project_lines[@]}"; do
			IFS=$'\t' read -r project_id backend homepage ecosystem <<< "$line"

			if [[ "$homepage" == "https://github.com/$repo" ||
			      "$homepage" == "http://github.com/$repo" ||
			      "$homepage" == "https://www.github.com/$repo" ||
			      "$homepage" == "http://www.github.com/$repo" ]]; then
				matches+=("$line")
			fi
		done

		if (( ${#matches[@]} == 1 )); then
			IFS=$'\t' read -r project_id backend homepage ecosystem <<< "${matches[1]}"
		else
			# Anitya may use a different homepage from the actual
			# repository, e.g. golang/go -> https://go.dev.
			project_id=
			backend=GitHub
			homepage="https://github.com/$repo"
		fi
	fi

	# Cache by upstream repository when available, otherwise Anitya ID.
	if [[ -n "$repo" ]]; then
		cache_file="$UVER_CACHE/${repo//\//__}"
	else
		cache_file="$UVER_CACHE/anitya-$project_id"
	fi

	if [[ -f "$cache_file" ]]; then
		cache_time=$(stat -c %Y "$cache_file" 2>/dev/null) || cache_time=0
	else
		cache_time=0
	fi

	now=$(date +%s)

	if (( now - cache_time < UVER_CACHE_TTL )); then
		version=$(<"$cache_file")

		if [[ -n "$version" ]]; then
			print -r -- "$version"
			return 0
		fi
	fi

	# For a GitHub repository, query Git directly rather than api.github.com.
	if [[ -n "$repo" && "$backend" == GitHub ]]; then
		tags=$(
			timeout 15 git ls-remote --tags --refs \
				"https://github.com/$repo.git" 2>/dev/null |
			sed -n 's#^[^	]*	refs/tags/##p'
		)

		if [[ -n "$tags" ]]; then
			if [[ "$repo" == golang/go ]]; then
				version=$(
					print -r -- "$tags" |
					grep -E '^go[0-9]+(\.[0-9]+)+$' |
					sed 's/^go//' |
					sort -V |
					tail -n1
				)
			else
				version=$(
					print -r -- "$tags" |
					grep -E '^v?[0-9]+(\.[0-9]+)+$' |
					sed 's/^v//' |
					sort -V |
					tail -n1
				)
			fi

			if [[ -n "$version" ]]; then
				print -r -- "$version" >| "$cache_file"
				print -r -- "$version"
				return 0
			fi
		fi
	fi

	# Fall back to Anitya's recorded latest version.
	if [[ -n "$project_id" ]]; then
		version=$(
			timeout 15 wget -qO- \
				"https://release-monitoring.org/api/v2/versions/?project_id=$project_id" |
			sed -n 's/.*"latest_version":[[:space:]]*"\([^"]*\)".*/\1/p' |
			head -n1
		)

		if [[ -n "$version" ]]; then
			print -r -- "$version" >| "$cache_file"
			print -r -- "$version"
			return 0
		fi
	fi

	print -u2 "Could not determine upstream version for $pkg"
	return 1
}

function vatver {
	export VAT_URL="https://raw.githubusercontent.com/tox-wtf/vat/refs/heads/master/p/"
	wget -cqO- -T 5 -t 1 "$VAT_URL/$1/v.tsv" | grep -F release | cut -f3
}
