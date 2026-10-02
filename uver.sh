
#!/bin/bash
typeset -g UVER_CACHE=${XDG_CACHE_HOME:-$HOME/.cache}/uver
typeset -g UVER_CACHE_TTL=300
typeset -g LFP=${LFP:-$HOME/lfs_packaging}

function uver {
	python3 "$LFP/uver.py" "$@"
}

function afind {
	local keyword="$1"

	if [[ -z "$keyword" ]]; then
		echo "Usage: afind KEYWORD" >&2
		return 2
	fi

	python3 - "$keyword" <<'PY'
import json
import sys
import urllib.parse
import urllib.request

keyword = sys.argv[1]

params = urllib.parse.urlencode({
	"pattern": f"*{keyword}*",
	"items_per_page": 250,
})

url = f"https://release-monitoring.org/api/projects/?{params}"

request = urllib.request.Request(
	url,
	headers={"User-Agent": "afind/1.0"},
)

try:
	with urllib.request.urlopen(request, timeout=30) as response:
		data = json.load(response)
except Exception as error:
	print(f"Could not query Anitya: {error}", file=sys.stderr)
	sys.exit(1)

projects = data.get("projects", data.get("items", []))

for project in projects:
	if isinstance(project, str):
		print(project)
		continue

	print(
		f"{project.get('id', '')}\t"
		f"{project.get('name', '')}\t"
		f"{project.get('homepage', '')}"
	)
PY
}