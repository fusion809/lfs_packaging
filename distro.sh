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

uver() {
	local input_pkg=$1
	local pkg=${1:l}
	local build repo name projects project_count
	local project_id backend project_homepage ecosystem version_url
	local homepage cache_file cache_time now version line
	local wanted_homepage
	local configured_name
	local -a project_lines matches repo_matches

	if [[ -z "$pkg" ]]; then
		print -u2 'usage: uver package'
		return 2
	fi

	mkdir -p "$UVER_CACHE"

	# Locate build.sh. Package build scripts may be in either
	# $LFP/$pkg/build.sh or $LFP/uninstalled/$pkg/build.sh.
	# The package directory may also retain its original case.
	build=

	for candidate in \
		"$LFP/$pkg/build.sh" \
		"$LFP/$input_pkg/build.sh" \
		"$LFP/uninstalled/$pkg/build.sh" \
		"$LFP/uninstalled/$input_pkg/build.sh"; do
		if [[ -f "$candidate" ]]; then
			build=$candidate
			break
		fi
	done

	# If the package name differs only in case from the directory name,
	# locate the corresponding build.sh case-insensitively.
	if [[ -z "$build" ]]; then
		for candidate in "$LFP"/*/build.sh(N) "$LFP/uninstalled"/*/build.sh(N); do
			local candidate_pkg=${candidate:h:t}

			if [[ "${candidate_pkg:l}" == "$pkg" ]]; then
				build=$candidate
				break
			fi
		done
	fi

	# Read homepage=, repo= and _name= from build.sh.
	if [[ -n "$build" ]]; then
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

		configured_name=$(
			sed -n '
				/^[[:space:]]*_name=/ {
					s/^[[:space:]]*_name=[[:space:]]*//
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

		configured_name=${configured_name#\"}
		configured_name=${configured_name%\"}
		configured_name=${configured_name#\'}
		configured_name=${configured_name%\'}

		# Expand variables such as $pkg.
		name=$configured_name
		if [[ -n "$name" ]]; then
			name=${(e)name}
		fi

		homepage=${(e)homepage}
		repo=${(e)repo}
	fi

	# Query Anitya using the package name.
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
        str(p.get("ecosystem", "")) + "\t" +
        str(p.get("version_url", ""))
    )
'
	)

	normalize_url() {
		local url=${1:l}
		url=${url#http://}
		url=${url#https://}
		url=${url#www.}
		url=${url%/}
		print -r -- "$url"
	}

	# Determine whether the package-name query produced a usable
	# project. A project is usable if homepage= or repo= can uniquely
	# identify it. If it cannot, _name is tried below.
	local usable_pkg_project=false

	if [[ -n "$projects" ]]; then
		project_lines=("${(@f)projects}")

		# If there is no homepage= or repo=, retain the original
		# behaviour and let the normal ambiguity handling below decide.
		if [[ -z "$homepage" && -z "$repo" ]]; then
			usable_pkg_project=true
		else
			matches=()

			# First try homepage=.
			if [[ -n "$homepage" ]]; then
				wanted_homepage=$(normalize_url "$homepage")

				for line in "${project_lines[@]}"; do
					IFS=$'\t' read -r \
						project_id backend project_homepage ecosystem version_url \
						<<< "$line"

					if [[ "$wanted_homepage" == "$(normalize_url "$project_homepage")" ||
					      "$wanted_homepage" == "$(normalize_url "$ecosystem")" ]]; then
						matches+=("$line")
					fi
				done
			fi

			# If homepage= did not uniquely identify the project,
			# use repo= to narrow those matches.
			if (( ${#matches[@]} != 1 )) && [[ -n "$repo" ]]; then
				repo_matches=()

				for line in "${matches[@]:-${(@f)projects}}"; do
					IFS=$'\t' read -r \
						project_id backend project_homepage ecosystem version_url \
						<<< "$line"

					if [[ "$version_url" == "$repo" ]]; then
						repo_matches+=("$line")
					fi
				done

				matches=("${repo_matches[@]}")
			fi

			if (( ${#matches[@]} == 1 )); then
				usable_pkg_project=true
			fi
		fi
	fi

	# If the package-name query did not produce a uniquely usable
	# project, search Anitya using _name from build.sh.
	if [[ "$usable_pkg_project" != true &&
	      -n "$name" &&
	      "${name:l}" != "$pkg" ]]; then

		projects=$(
			timeout 15 wget -qO- \
				"https://release-monitoring.org/api/v2/projects/?name=$name&items_per_page=10" |
			python3 -c '
import json
import sys

for p in json.load(sys.stdin).get("items", []):
    print(
        str(p.get("id", "")) + "\t" +
        str(p.get("backend", "")) + "\t" +
        str(p.get("homepage", "")) + "\t" +
        str(p.get("ecosystem", "")) + "\t" +
        str(p.get("version_url", ""))
    )
'
		)
	fi

	if [[ -z "$projects" ]]; then
		print -u2 "No Anitya project found for $pkg"
		return 1
	fi

	project_lines=("${(@f)projects}")
	project_count=${#project_lines}

	# One Anitya project: there is no ambiguity, so build.sh is not
	# consulted.
	if (( project_count == 1 )); then
		IFS=$'\t' read -r \
			project_id backend project_homepage ecosystem version_url \
			<<< "${project_lines[1]}"
	else
		# Multiple projects: use build.sh to resolve the ambiguity.
		if [[ -z "$build" || ! -f "$build" ]]; then
			print -u2 "Multiple Anitya projects found for $pkg; no build.sh"
			print -u2 "Candidates:"
			for line in "${project_lines[@]}"; do
				IFS=$'\t' read -r \
					project_id backend project_homepage ecosystem version_url \
					<<< "$line"

				print -u2 "  $project_id  $project_homepage"
			done
			return 1
		fi

		matches=()

		# First try the explicit homepage.
		if [[ -n "$homepage" ]]; then
			wanted_homepage=$(normalize_url "$homepage")

			for line in "${project_lines[@]}"; do
				IFS=$'\t' read -r \
					project_id backend project_homepage ecosystem version_url \
					<<< "$line"

				if [[ "$wanted_homepage" == "$(normalize_url "$project_homepage")" ||
				      "$wanted_homepage" == "$(normalize_url "$ecosystem")" ]]; then
					matches+=("$line")
				fi
			done
		fi

		# If homepage did not uniquely resolve the ambiguity, match
		# repo= against Anitya's version_url.
		if (( ${#matches[@]} != 1 )) && [[ -n "$repo" ]]; then
			repo_matches=()

			# If homepage produced candidates, narrow those candidates.
			# Otherwise search all Anitya projects.
			if (( ${#matches[@]} > 0 )); then
				for line in "${matches[@]}"; do
					IFS=$'\t' read -r \
						project_id backend project_homepage ecosystem version_url \
						<<< "$line"

					if [[ "$version_url" == "$repo" ]]; then
						repo_matches+=("$line")
					fi
				done
			else
				for line in "${project_lines[@]}"; do
					IFS=$'\t' read -r \
						project_id backend project_homepage ecosystem version_url \
						<<< "$line"

					if [[ "$version_url" == "$repo" ]]; then
						repo_matches+=("$line")
					fi
				done
			fi

			matches=("${repo_matches[@]}")
		fi

		if (( ${#matches[@]} != 1 )); then
			if (( ${#matches[@]} > 1 )); then
				print -u2 "Multiple Anitya projects match $pkg:"
			elif [[ -n "$homepage" ]]; then
				print -u2 "No Anitya project for $pkg matches homepage=$homepage"
			elif [[ -n "$repo" ]]; then
				print -u2 "No Anitya project for $pkg matches repo=$repo"
			else
				print -u2 "Multiple Anitya projects found for $pkg; no homepage= or repo= in $build"
			fi

			if (( ${#matches[@]} == 0 )); then
				print -u2 "Candidates:"
				for line in "${project_lines[@]}"; do
					IFS=$'\t' read -r \
						project_id backend project_homepage ecosystem version_url \
						<<< "$line"

					print -u2 \
						"  $project_id  $project_homepage  [$backend${version_url:+: $version_url}]"
				done
			else
				for line in "${matches[@]}"; do
					IFS=$'\t' read -r \
						project_id backend project_homepage ecosystem version_url \
						<<< "$line"

					print -u2 \
						"  $project_id  $project_homepage  [$backend${version_url:+: $version_url}]"
				done
			fi

			return 1
		fi

		IFS=$'\t' read -r \
			project_id backend project_homepage ecosystem version_url \
			<<< "${matches[1]}"
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
