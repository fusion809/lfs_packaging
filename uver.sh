#!/bin/bash
typeset -g UVER_CACHE=${XDG_CACHE_HOME:-$HOME/.cache}/uver
typeset -g UVER_CACHE_TTL=300
uver() {
	local input_pkg=${1:-}
	local pkg=${input_pkg:l}
	local build repo name fallback_name
	local project_id backend project_homepage ecosystem version_url
	local homepage cache_file cache_time now version line
	local wanted_homepage
	local search_name
	local candidate candidate_pkg
	local -a project_lines matches
	local projects project_count

	if [[ -z "$pkg" ]]; then
		print -u2 'usage: uver package'
		return 2
	fi

	mkdir -p "$UVER_CACHE"

	# Locate build.sh.  Package directory names are normally lowercase,
	# but allow the name supplied by the caller as well, e.g. R/build.sh.
	build=
	for candidate in \
		"$LFP/$pkg/build.sh" \
		"$LFP/$input_pkg/build.sh" \
		"$LFP/uninstalled/$pkg/build.sh" \
		"$LFP/uninstalled/$input_pkg/build.sh"
	do
		if [[ -f "$candidate" ]]; then
			build=$candidate
			break
		fi
	done

	# If that did not find it, try case-insensitive directory matching.
	if [[ -z "$build" ]]; then
		for candidate in "$LFP"/*/build.sh(N) "$LFP/uninstalled"/*/build.sh(N); do
			candidate_pkg=${candidate:h:t}
			if [[ "${candidate_pkg:l}" == "$pkg" ]]; then
				build=$candidate
				break
			fi
		done
	fi

	# Read build.sh metadata when available.
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

		fallback_name=$(
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

		fallback_name=${fallback_name#\"}
		fallback_name=${fallback_name%\"}
		fallback_name=${fallback_name#\'}
		fallback_name=${fallback_name%\'}

		# Expand variables such as $name using the package name as the
		# value of $name, preserving the existing uver behaviour.
		name=$pkg
		homepage=${(e)homepage}
		repo=${(e)repo}
		fallback_name=${(e)fallback_name}
	fi

	# Search Anitya.  If the package name produces no usable project,
	# _name is tried as a fallback.
	search_name=$pkg

	while true; do
		projects=$(
			timeout 15 wget -qO- \
				"https://release-monitoring.org/api/v2/projects/?name=$search_name&items_per_page=10" |
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

		if [[ -z "$projects" ]]; then
			# If _name was tried already, there is nothing more to do.
			if [[ "$search_name" != "$pkg" || -z "$fallback_name" ||
			      "${fallback_name:l}" == "$pkg" ]]; then
				print -u2 "No Anitya project found for $search_name"
				return 1
			fi

			search_name=${fallback_name:l}
			continue
		fi

		project_lines=("${(@f)projects}")
		project_count=${#project_lines}

		# If build.sh is available, determine whether the projects returned
		# for the current name actually correspond to it.
		if [[ -n "$build" && ( -n "$homepage" || -n "$repo" ) ]]; then
			matches=()

			normalize_url() {
				local url=${1:l}
				url=${url#http://}
				url=${url#https://}
				url=${url#www.}
				url=${url%/}
				print -r -- "$url"
			}

			wanted_homepage=$(normalize_url "$homepage")

			if [[ -n "$homepage" ]]; then
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

			# repo= is used whenever the homepage does not uniquely identify
			# a project.  This is important when several Anitya projects
			# share the same homepage.
			if (( ${#matches[@]} != 1 )) && [[ -n "$repo" ]]; then
				local -a repo_matches
				repo_matches=()

				for line in "${project_lines[@]}"; do
					IFS=$'\t' read -r \
						project_id backend project_homepage ecosystem version_url \
						<<< "$line"

					if [[ "$version_url" == "$repo" ]]; then
						repo_matches+=("$line")
					fi
				done

				if (( ${#repo_matches[@]} == 1 )); then
					matches=("${repo_matches[@]}")
				fi
			fi

			# The current Anitya search name is usable if its metadata
			# identifies exactly one project, or if there is no metadata
			# available with which to disambiguate it.
			if (( ${#matches[@]} == 1 )); then
				break
			fi

			# If the current name produced projects but none correspond to
			# the build.sh metadata, try _name.
			if (( ${#matches[@]} == 0 )) &&
			   [[ "$search_name" == "$pkg" ]] &&
			   [[ -n "$fallback_name" ]] &&
			   [[ "${fallback_name:l}" != "$pkg" ]]
			then
				search_name=${fallback_name:l}
				continue
			fi
		else
			# No build metadata to disambiguate with.  A single project is
			# sufficient; multiple projects are handled below.
			break
		fi

		break
	done

	project_lines=("${(@f)projects}")
	project_count=${#project_lines}

	# One project: use it directly.
	if (( project_count == 1 )); then
		IFS=$'\t' read -r \
			project_id backend project_homepage ecosystem version_url \
			<<< "${project_lines[1]}"
	else
		# Multiple projects: use build.sh metadata to resolve them.
		if [[ -z "$build" ]]; then
			print -u2 "Multiple Anitya projects found for $search_name; no $build"
			print -u2 "Candidates:"
			for line in "${project_lines[@]}"; do
				IFS=$'\t' read -r \
					project_id backend project_homepage ecosystem version_url \
					<<< "$line"

				print -u2 \
					"  $project_id  $project_homepage  [$backend${version_url:+: $version_url}]"
			done
			return 1
		fi

		matches=()

		normalize_url() {
			local url=${1:l}
			url=${url#http://}
			url=${url#https://}
			url=${url#www.}
			url=${url%/}
			print -r -- "$url"
		}

		wanted_homepage=$(normalize_url "$homepage")

		# First restrict candidates by homepage.
		if [[ -n "$homepage" ]]; then
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

		# Then use repo= whenever homepage did not uniquely identify one.
		if (( ${#matches[@]} != 1 )) && [[ -n "$repo" ]]; then
			local -a repo_matches
			repo_matches=()

			for line in "${project_lines[@]}"; do
				IFS=$'\t' read -r \
					project_id backend project_homepage ecosystem version_url \
					<<< "$line"

				if [[ "$version_url" == "$repo" ]]; then
					repo_matches+=("$line")
				fi
			done

			if (( ${#repo_matches[@]} == 1 )); then
				matches=("${repo_matches[@]}")
			fi
		fi

		if (( ${#matches[@]} == 1 )); then
			IFS=$'\t' read -r \
				project_id backend project_homepage ecosystem version_url \
				<<< "${matches[1]}"
		else
			# If several candidates have the same normalized homepage,
			# choose the one with the lowest numeric Anitya project ID.
			#
			# This handles cases such as R:
			#   4150   https://www.r-project.org
			#   386062 https://www.r-project.org/
			#
			# Both normalize to the same homepage, so the oldest/lower-ID
			# project is selected.
			local -a homepage_matches
			local lowest_id lowest_line
			homepage_matches=()

			if [[ -n "$homepage" ]]; then
				for line in "${project_lines[@]}"; do
					IFS=$'\t' read -r \
						project_id backend project_homepage ecosystem version_url \
						<<< "$line"

					if [[ "$wanted_homepage" == "$(normalize_url "$project_homepage")" ]]; then
						homepage_matches+=("$line")
					fi
				done
			fi

			if (( ${#homepage_matches[@]} > 1 )); then
				lowest_id=
				lowest_line=

				for line in "${homepage_matches[@]}"; do
					IFS=$'\t' read -r \
						project_id backend project_homepage ecosystem version_url \
						<<< "$line"

					if [[ -z "$lowest_id" || "$project_id" -lt "$lowest_id" ]]; then
						lowest_id=$project_id
						lowest_line=$line
					fi
				done

				IFS=$'\t' read -r \
					project_id backend project_homepage ecosystem version_url \
					<<< "$lowest_line"
			else
				if (( ${#matches[@]} > 1 )); then
					print -u2 "Multiple Anitya projects match $search_name:"
				elif [[ -n "$homepage" ]]; then
					print -u2 "No Anitya project for $search_name matches homepage=$homepage"
				elif [[ -n "$repo" ]]; then
					print -u2 "No Anitya project for $search_name matches repo=$repo"
				else
					print -u2 "Multiple Anitya projects found for $search_name; no homepage= or repo= in $build"
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
		fi
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

	print -u2 "Could not determine upstream version for $search_name"
	return 1
}