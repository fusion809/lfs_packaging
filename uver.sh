#!/bin/bash
typeset -g UVER_CACHE=${XDG_CACHE_HOME:-$HOME/.cache}/uver
typeset -g UVER_CACHE_TTL=300
uver() {
	local input_pkg=${1:-}
	local pkg
	local build repo name fallback_name
	local project_id backend project_homepage ecosystem version_url
	local homepage cache_file cache_time now version line
	local wanted_homepage
	local search_name
	local candidate candidate_pkg
	local projects project_count
	local matches match_count
	local repo_matches repo_match_count
	local homepage_matches homepage_match_count
	local lowest_id lowest_line
	local search_attempt
	local project_homepage_normalized

	pkg=$(printf '%s\n' "$input_pkg" | tr '[:upper:]' '[:lower:]')

	if [[ -z "$pkg" ]]; then
		printf '%s\n' 'usage: uver package' >&2
		return 2
	fi

	mkdir -p "$UVER_CACHE"

	# Locate build.sh. Try the exact package name first, then the
	# lower-case name, then uninstalled/.
	build=
	for candidate in \
		"$LFP/$input_pkg/build.sh" \
		"$LFP/$pkg/build.sh" \
		"$LFP/uninstalled/$input_pkg/build.sh" \
		"$LFP/uninstalled/$pkg/build.sh"
	do
		if [[ -f "$candidate" ]]; then
			build=$candidate
			break
		fi
	done

	# If the exact names did not work, find build.sh case-insensitively.
	if [[ -z "$build" ]]; then
		while IFS= read -r candidate; do
			candidate_pkg=${candidate%/build.sh}
			candidate_pkg=${candidate_pkg##*/}
			candidate_pkg=$(printf '%s\n' "$candidate_pkg" |
				tr '[:upper:]' '[:lower:]')

			if [[ "$candidate_pkg" == "$pkg" ]]; then
				build=$candidate
				break
			fi
		done < <(
			find "$LFP" "$LFP/uninstalled" \
				-mindepth 2 -maxdepth 2 \
				-type f -name build.sh \
				-print 2>/dev/null
		)
	fi

	homepage=
	repo=
	fallback_name=

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

		# Expand variables such as $name.
		name=$pkg

		if [[ -n "$homepage" ]]; then
			eval "homepage=$homepage"
		fi

		if [[ -n "$repo" ]]; then
			eval "repo=$repo"
		fi

		if [[ -n "$fallback_name" ]]; then
			eval "fallback_name=$fallback_name"
		fi
	fi

	# Search Anitya. _name is used when the normal package name either
	# has no Anitya project or only produces projects that do not match
	# the build.sh metadata.
	search_name=$pkg
	search_attempt=0

	while :; do
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
			if [[ "$search_attempt" -eq 0 &&
			      -n "$fallback_name" &&
			      "$(printf '%s\n' "$fallback_name" | tr '[:upper:]' '[:lower:]')" != "$pkg" ]]
			then
				search_name=$(printf '%s\n' "$fallback_name" |
					tr '[:upper:]' '[:lower:]')
				search_attempt=1
				continue
			fi

			printf 'No Anitya project found for %s\n' "$search_name" >&2
			return 1
		fi

		project_count=$(printf '%s\n' "$projects" | wc -l)

		# For a single project, check the build metadata if available.
		# If it does not match, _name may provide the correct project.
		if [[ "$project_count" -eq 1 &&
		      -n "$build" &&
		      ( -n "$homepage" || -n "$repo" ) ]]
		then
			IFS=$'\t' read -r \
				project_id backend project_homepage ecosystem version_url \
				<<< "$projects"

			match_count=0

			if [[ -n "$homepage" ]]; then
				wanted_homepage=$homepage
				wanted_homepage=${wanted_homepage#http://}
				wanted_homepage=${wanted_homepage#https://}
				wanted_homepage=${wanted_homepage#www.}
				wanted_homepage=${wanted_homepage%/}

				project_homepage_normalized=$project_homepage
				project_homepage_normalized=${project_homepage_normalized#http://}
				project_homepage_normalized=${project_homepage_normalized#https://}
				project_homepage_normalized=${project_homepage_normalized#www.}
				project_homepage_normalized=${project_homepage_normalized%/}

				if [[ "$wanted_homepage" == "$project_homepage_normalized" ]]; then
					match_count=1
				fi
			fi

			if [[ "$match_count" -eq 0 && -n "$repo" &&
			      "$version_url" == "$repo" ]]
			then
				match_count=1
			fi

			if [[ "$match_count" -eq 1 ]]; then
				break
			fi

			if [[ "$search_attempt" -eq 0 &&
			      -n "$fallback_name" &&
			      "$(printf '%s\n' "$fallback_name" | tr '[:upper:]' '[:lower:]')" != "$pkg" ]]
			then
				search_name=$(printf '%s\n' "$fallback_name" |
					tr '[:upper:]' '[:lower:]')
				search_attempt=1
				continue
			fi
		fi

		break
	done

	project_count=$(printf '%s\n' "$projects" | wc -l)

	if [[ "$project_count" -eq 1 ]]; then
		IFS=$'\t' read -r \
			project_id backend project_homepage ecosystem version_url \
			<<< "$projects"
	else
		if [[ -z "$build" ]]; then
			printf 'Multiple Anitya projects found for %s; no build.sh\n' \
				"$search_name" >&2
			printf '%s\n' 'Candidates:' >&2

			while IFS=$'\t' read -r \
				project_id backend project_homepage ecosystem version_url
			do
				printf '  %s  %s  [%s%s]\n' \
					"$project_id" \
					"$project_homepage" \
					"$backend" \
					"${version_url:+: $version_url}" >&2
			done <<< "$projects"

			return 1
		fi

		matches=
		match_count=0

		# First match by normalised homepage.
		if [[ -n "$homepage" ]]; then
			wanted_homepage=$homepage
			wanted_homepage=${wanted_homepage#http://}
			wanted_homepage=${wanted_homepage#https://}
			wanted_homepage=${wanted_homepage#www.}
			wanted_homepage=${wanted_homepage%/}

			while IFS=$'\t' read -r \
				project_id backend project_homepage ecosystem version_url
			do
				project_homepage_normalized=$project_homepage
				project_homepage_normalized=${project_homepage_normalized#http://}
				project_homepage_normalized=${project_homepage_normalized#https://}
				project_homepage_normalized=${project_homepage_normalized#www.}
				project_homepage_normalized=${project_homepage_normalized%/}

				if [[ "$wanted_homepage" == "$project_homepage_normalized" ]]; then
					if [[ -z "$matches" ]]; then
						matches=$project_id$'\t'$backend$'\t'$project_homepage$'\t'$ecosystem$'\t'$version_url
					else
						matches=$matches$'\n'$project_id$'\t'$backend$'\t'$project_homepage$'\t'$ecosystem$'\t'$version_url
					fi
					match_count=$((match_count + 1))
				fi
			done <<< "$projects"
		fi

		# If homepage did not uniquely identify the project, try repo=.
		if [[ "$match_count" -ne 1 && -n "$repo" ]]; then
			repo_matches=
			repo_match_count=0

			while IFS=$'\t' read -r \
				project_id backend project_homepage ecosystem version_url
			do
				if [[ "$version_url" == "$repo" ]]; then
					if [[ -z "$repo_matches" ]]; then
						repo_matches=$project_id$'\t'$backend$'\t'$project_homepage$'\t'$ecosystem$'\t'$version_url
					else
						repo_matches=$repo_matches$'\n'$project_id$'\t'$backend$'\t'$project_homepage$'\t'$ecosystem$'\t'$version_url
					fi
					repo_match_count=$((repo_match_count + 1))
				fi
			done <<< "$projects"

			if [[ "$repo_match_count" -eq 1 ]]; then
				matches=$repo_matches
				match_count=1
			fi
		fi

		if [[ "$match_count" -eq 1 ]]; then
			IFS=$'\t' read -r \
				project_id backend project_homepage ecosystem version_url \
				<<< "$matches"
		else
			# Multiple projects with the same normalised homepage:
			# select the one with the lowest numeric Anitya ID.
			homepage_match_count=0
			lowest_id=
			lowest_line=

			if [[ -n "$homepage" ]]; then
				wanted_homepage=$homepage
				wanted_homepage=${wanted_homepage#http://}
				wanted_homepage=${wanted_homepage#https://}
				wanted_homepage=${wanted_homepage#www.}
				wanted_homepage=${wanted_homepage%/}

				while IFS=$'\t' read -r \
					project_id backend project_homepage ecosystem version_url
				do
					project_homepage_normalized=$project_homepage
					project_homepage_normalized=${project_homepage_normalized#http://}
					project_homepage_normalized=${project_homepage_normalized#https://}
					project_homepage_normalized=${project_homepage_normalized#www.}
					project_homepage_normalized=${project_homepage_normalized%/}

					if [[ "$wanted_homepage" == "$project_homepage_normalized" ]]; then
						homepage_match_count=$((homepage_match_count + 1))

						if [[ -z "$lowest_id" ||
						      "$project_id" -lt "$lowest_id" ]]
						then
							lowest_id=$project_id
							lowest_line=$project_id$'\t'$backend$'\t'$project_homepage$'\t'$ecosystem$'\t'$version_url
						fi
					fi
				done <<< "$projects"
			fi

			if [[ "$homepage_match_count" -gt 1 ]]; then
				IFS=$'\t' read -r \
					project_id backend project_homepage ecosystem version_url \
					<<< "$lowest_line"
			else
				if [[ "$match_count" -gt 1 ]]; then
					printf 'Multiple Anitya projects match %s:\n' \
						"$search_name" >&2
				elif [[ -n "$homepage" ]]; then
					printf 'No Anitya project for %s matches homepage=%s\n' \
						"$search_name" "$homepage" >&2
				elif [[ -n "$repo" ]]; then
					printf 'No Anitya project for %s matches repo=%s\n' \
						"$search_name" "$repo" >&2
				else
					printf 'Multiple Anitya projects found for %s; no homepage= or repo= in %s\n' \
						"$search_name" "$build" >&2
				fi

				printf '%s\n' 'Candidates:' >&2
				while IFS=$'\t' read -r \
					project_id backend project_homepage ecosystem version_url
				do
					printf '  %s  %s  [%s%s]\n' \
						"$project_id" \
						"$project_homepage" \
						"$backend" \
						"${version_url:+: $version_url}" >&2
				done <<< "$projects"

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
		version=$(cat "$cache_file")

		if [[ -n "$version" ]]; then
			printf '%s\n' "$version"
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
		printf '%s\n' "$version" > "$cache_file"
		printf '%s\n' "$version"
		return 0
	fi

	printf 'Could not determine upstream version for %s\n' "$search_name" >&2
	return 1
}