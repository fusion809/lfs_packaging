#!/bin/bash
function arch_url {
	local pkg=${1:-}
	local desc

	if [[ -z "$pkg" ]]; then
		printf '%s\n' 'usage: arch_url package' >&2
		return 2
	fi

	# Try the official Arch repositories first.
	url=$(
		curl -fsSL \
			"https://archlinux.org/packages/search/json/?name=$pkg" |
		python3 -c '
import json
import sys

data = json.load(sys.stdin)
results = data.get("results", [])

for package in results:
    if package.get("pkgname") == sys.argv[1]:
        print(package.get("url", ""))
        break
' "$pkg"
	)

	if [[ -n "$url" ]]; then
		printf '%s\n' "$url"
		return 0
	fi

	# Fall back to the AUR.
	url=$(
		curl -fsSL \
			"https://aur.archlinux.org/rpc/v5/info?arg[]=$pkg" |
		python3 -c '
import json
import sys

data = json.load(sys.stdin)
results = data.get("results", [])

if results:
    print(results[0].get("Description", ""))
'
	)

	if [[ -n "$url" ]]; then
		printf '%s\n' "$url"
		return 0
	fi

	printf 'Could not find Arch package %s\n' "$pkg" >&2
	return 1
}

function add_arch_urls {
	local pkgdir build pkg url escaped tmp

	while IFS= read -r pkgdir; do
		pkg=${pkgdir##*/}
		build=$pkgdir/build.sh

		[[ -f "$build" ]] || continue

		# Do not overwrite an existing homepage.
		if grep -qE '^[[:space:]]*homepage=' "$build"; then
			continue
		fi

		url=$(arch_url "$pkg") || {
			printf 'Could not determine homepage for %s\n' "$pkg" >&2
			continue
		}

		[[ -n "$url" ]] || {
			printf 'Empty homepage for %s\n' "$pkg" >&2
			continue
		}

		# Escape backslashes and double quotes for a double-quoted
		# shell assignment.
		escaped=${url//\\/\\\\}
		escaped=${escaped//\"/\\\"}

		tmp=$(mktemp) || return 1

		awk -v homepage="homepage=\"$escaped\"" '
			!inserted && /^[[:space:]]*name=/ {
				print
				print homepage
				inserted=1
				next
			}
			{ print }
		' "$build" > "$tmp" || {
			rm -f "$tmp"
			printf 'Failed to modify %s\n' "$build" >&2
			continue
		}

		if ! mv "$tmp" "$build"; then
			rm -f "$tmp"
			printf 'Failed to replace %s\n' "$build" >&2
			continue
		fi

		printf '%s: %s\n' "$pkg" "$url"
	done < <(
		find "$LFP" \
			-mindepth 1 -maxdepth 1 \
			-type d \
			-print
	)
}

function arch_desc {
	local pkg=${1:-}
	local desc

	if [[ -z "$pkg" ]]; then
		printf '%s\n' 'usage: arch_desc package' >&2
		return 2
	fi

	# Try the official Arch repositories first.
	desc=$(
		curl -fsSL \
			"https://archlinux.org/packages/search/json/?name=$pkg" |
		python3 -c '
import json
import sys

data = json.load(sys.stdin)
results = data.get("results", [])

for package in results:
    if package.get("pkgname") == sys.argv[1]:
        print(package.get("arch_desc", ""))
        break
' "$pkg"
	)

	if [[ -n "$desc" ]]; then
		printf '%s\n' "$desc"
		return 0
	fi

	# Fall back to the AUR.
	desc=$(
		curl -fsSL \
			"https://aur.archlinux.org/rpc/v5/info?arg[]=$pkg" |
		python3 -c '
import json
import sys

data = json.load(sys.stdin)
results = data.get("results", [])

if results:
    print(results[0].get("Description", ""))
'
	)

	if [[ -n "$desc" ]]; then
		printf '%s\n' "$desc"
		return 0
	fi

	printf 'Could not find Arch package %s\n' "$pkg" >&2
	return 1
}

function add_arch_descs {
	local pkgdir build name desc escaped tmp

	while IFS= read -r pkgdir; do
		name=${pkgdir##*/}
		build=$pkgdir/build.sh

		[[ -f "$build" ]] || continue

		# Do not overwrite an existing description.
		if grep -qE '^[[:space:]]*description=' "$build"; then
			continue
		fi

		desc=$(arch_desc "$name") || {
			printf 'Could not determine description for %s\n' "$name" >&2
			continue
		}

		[[ -n "$desc" ]] || {
			printf 'Empty description for %s\n' "$name" >&2
			continue
		}

		# Escape backslashes and double quotes for a double-quoted
		# shell assignment.
		escaped=${desc//\\/\\\\}
		escaped=${escaped//\"/\\\"}

		tmp=$(mktemp) || return 1

		awk -v description="description=\"$escaped\"" '
			!inserted && /^[[:space:]]*name=/ {
				print
				print description
				inserted=1
				next
			}
			{ print }
		' "$build" > "$tmp" || {
			rm -f "$tmp"
			printf 'Failed to modify %s\n' "$build" >&2
			continue
		}

		if ! mv "$tmp" "$build"; then
			rm -f "$tmp"
			printf 'Failed to replace %s\n' "$build" >&2
			continue
		fi

		printf '%s: %s\n' "$name" "$desc"
	done < <(
		find "$LFP" \
			-mindepth 1 -maxdepth 1 \
			-type d \
			-print
	)
}
