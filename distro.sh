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

typeset -g UVER_CACHE=${XDG_CACHE_HOME:-$HOME/.cache}/uver
typeset -g UVER_CACHE_TTL=300

typeset -g UVER_CACHE=${XDG_CACHE_HOME:-$HOME/.cache}/uver
typeset -g UVER_CACHE_TTL=300

uver() {
	local pkg=${1:l}
	local build repo name projects project_count
	local project_id backend project_homepage ecosystem
	local homepage cache_file cache_time now version line
	local wanted_homepage wanted_repo
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

	# With one Anitya project there is no ambiguity, so build.sh is
	# neither required nor consulted.
	if (( project_count == 1 )); then
		IFS=$'\t' read -r project_id backend project_homepage ecosystem <<< "${project_lines[1]}"
	else
		# Multiple projects: use build.sh to resolve the ambiguity.
		build=$LFP/$pkg/build.sh

		if [[ ! -f "$build" ]]; then
			print -u2 "Multiple Anitya projects found for $pkg; no $build"
			return 1
		fi

		homepage=$(
			sed -n '
				/^[[:space:]]*homepage=/ {
					s/^[[:space:]]*homepage=[[:space:]]*//
					p
					q
				}
			' "$build"
		)

		repo=$(
			sed -n '
				/^[[:space:]]*repo=/ {
					s/^[[:space:]]*repo=[[:space:]]*//
					p
					q
				}
			' "$build"
		)

		# Remove surrounding quotes.
		homepage=${homepage#\"}
		homepage=${homepage%\"}
		homepage=${homepage#\'}
		homepage=${homepage%\'}

		repo=${repo#\"}
		repo=${repo%\"}
		repo=${repo#\'}
		repo=${repo%\'}

		# Expand variables such as $name.
		name=$pkg
		homepage=${(e)homepage}
		repo=${(e)repo}

		# Normalize URLs for comparison.
		normalize_url() {
			local url=${1:l}

			url=${url#http://}
			url=${url#https://}
			url=${url#www.}
			url=${url%/}

			print -r -- "$url"
		}

		matches=()

		# First try the explicit homepage.
		if [[ -n "$homepage" ]]; then
			wanted_homepage=$(normalize_url "$homepage")

			for line in "${project_lines[@]}"; do
				IFS=$'\t' read -r project_id backend project_homepage ecosystem <<< "$line"

				if [[ "$wanted_homepage" == "$(normalize_url "$project_homepage")" ||
				      "$wanted_homepage" == "$(normalize_url "$ecosystem")" ]]; then
					matches+=("$line")
				fi
			done
		fi

		# If homepage did not resolve the ambiguity, try repo=.
		#
		# For GitHub repositories, Anitya may have:
		#
		#   homepage  = https://project.example.org/
		#   ecosystem = https://github.com/owner/project
		#
		# or the GitHub URL may appear as the homepage itself. Compare
		# the normalized GitHub repository URL against both fields.
		if (( ${#matches[@]} == 0 )) && [[ -n "$repo" ]]; then
			wanted_repo=$(normalize_url "https://github.com/$repo")

			for line in "${project_lines[@]}"; do
				IFS=$'\t' read -r project_id backend project_homepage ecosystem <<< "$line"

				project_homepage=$(normalize_url "$project_homepage")
				ecosystem=$(normalize_url "$ecosystem")

				if [[ "$project_homepage" == "$wanted_repo" ||
				      "$ecosystem" == "$wanted_repo" ||
				      "$project_homepage" == *"/$repo" ||
				      "$ecosystem" == *"/$repo" ]]; then
					matches+=("$line")
				fi
			done
		fi

		if (( ${#matches[@]} != 1 )); then
			if (( ${#matches[@]} > 1 )); then
				print -u2 "Multiple Anitya projects match $pkg"
			elif [[ -n "$homepage" ]]; then
				print -u2 "No Anitya project for $pkg matches homepage=$homepage"
			elif [[ -n "$repo" ]]; then
				print -u2 "No Anitya project for $pkg matches repo=$repo"
			else
				print -u2 "Multiple Anitya projects found for $pkg; no homepage= or repo= in $build"
			fi
			return 1
		fi

		IFS=$'\t' read -r project_id backend project_homepage ecosystem <<< "${matches[1]}"
	fi

	# Cache by Anitya project ID.
	cache_file="$UVER_CACHE/anitya-$project_id"

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

	# Get the latest version recorded by Anitya.
	version=$(
		timeout 15 wget -qO- \
			"https://release-monitoring.org/api/v2/versions/?project_id=$project_id" |
		python3 -c '
import json
import sys

data = json.load(sys.stdin)
print(data.get("latest_version", ""))
'
	)

	if [[ -n "$version" ]]; then
		print -r -- "$version" >| "$cache_file"
		print -r -- "$version"
		return 0
	fi

	print -u2 "Could not determine upstream version for $pkg"
	return 1
}

function vatver {
	export VAT_URL="https://raw.githubusercontent.com/tox-wtf/vat/refs/heads/master/p/"
	wget -cqO- -T 5 -t 1 "$VAT_URL/$1/v.tsv" | grep -F release | cut -f3
}
