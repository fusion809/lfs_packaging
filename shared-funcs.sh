#!/bin/bash
source ~/lfs_packaging/base-funcs.sh
source ~/lfs_packaging/base-version.sh
source ~/lfs_packaging/arch.sh
source ~/lfs_packaging/distro.sh
source ~/lfs_packaging/uver.sh
source ~/lfs_packaging/version-checks.sh
source ~/lfs_packaging/freedesktop-components.sh
source ~/lfs_packaging/freedesktop.sh
source ~/lfs_packaging/github-components.sh
source ~/lfs_packaging/github.sh
source ~/lfs_packaging/gitlab-components.sh
source ~/lfs_packaging/gitlab.sh
source ~/lfs_packaging/gnome-components.sh
source ~/lfs_packaging/gnome.sh
source ~/lfs_packaging/gnu-components.sh
source ~/lfs_packaging/gnu.sh
source ~/lfs_packaging/glpk.sh
source ~/lfs_packaging/ngnu-components.sh
source ~/lfs_packaging/ngnu.sh
source ~/lfs_packaging/sourceforge-components.sh
source ~/lfs_packaging/sourceforge.sh
source ~/lfs_packaging/sourceware-components.sh
source ~/lfs_packaging/sourceware.sh
source ~/lfs_packaging/kde.sh
source ~/lfs_packaging/oss-hosts.sh
source ~/lfs_packaging/add_deps.sh
source ~/lfs_packaging/compile.sh
source ~/lfs_packaging/download.sh
source ~/lfs_packaging/prepare.sh

pkgurl() {
	local pkg=${1:-}
	local desc

	if [[ -z "$pkg" ]]; then
		printf '%s\n' 'usage: pkgurl package' >&2
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

add_pkgurls() {
	local pkgdir build pkg url escaped tmp

	while IFS= read -r pkgdir; do
		pkg=${pkgdir##*/}
		build=$pkgdir/build.sh

		[[ -f "$build" ]] || continue

		# Do not overwrite an existing homepage.
		if grep -qE '^[[:space:]]*homepage=' "$build"; then
			continue
		fi

		url=$(pkgurl "$pkg") || {
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

pkgdesc() {
	local pkg=${1:-}
	local desc

	if [[ -z "$pkg" ]]; then
		printf '%s\n' 'usage: pkgdesc package' >&2
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
        print(package.get("pkgdesc", ""))
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

add_pkgdescs() {
	local pkgdir build name desc escaped tmp

	while IFS= read -r pkgdir; do
		name=${pkgdir##*/}
		build=$pkgdir/build.sh

		[[ -f "$build" ]] || continue

		# Do not overwrite an existing description.
		if grep -qE '^[[:space:]]*description=' "$build"; then
			continue
		fi

		desc=$(pkgdesc "$name") || {
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