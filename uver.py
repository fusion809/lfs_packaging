#!/usr/bin/env python3

import json
import os
import re
import sys
import urllib.parse
import urllib.request

ANITYA_API = "https://release-monitoring.org/api/v2"
LFP = os.environ.get("LFP", os.path.expanduser("~/lfs_packaging"))


def fetch_json(url, description):
    try:
        request = urllib.request.Request(
            url,
            headers={"User-Agent": "uver/1.0"},
        )

        with urllib.request.urlopen(request, timeout=30) as response:
            return json.load(response)

    except Exception as error:
        print(
            f"Could not query Anitya for {description}: {error}",
            file=sys.stderr,
        )
        return None


def expand_metadata_variables(metadata):
    """Expand references to other variables declared in build.sh."""
    variable_pattern = re.compile(
        r"\$\{([A-Za-z_][A-Za-z0-9_]*)\}"
        r"|\$([A-Za-z_][A-Za-z0-9_]*)"
    )

    for _ in range(len(metadata) + 1):
        changed = False

        for key, value in metadata.items():
            expanded = variable_pattern.sub(
                lambda match: metadata.get(
                    match.group(1) or match.group(2),
                    match.group(0),
                ),
                value,
            )

            if expanded != value:
                metadata[key] = expanded
                changed = True

        if not changed:
            break

    return metadata


def read_build_metadata(pkg):
    build_file = os.path.join(LFP, pkg, "build.sh")

    metadata = {
        "name": pkg,
        "_name": "",
        "homepage": "",
        "repo": "",
    }

    if not os.path.isfile(build_file):
        return metadata

    try:
        with open(build_file, "r", encoding="utf-8") as file:
            content = file.read()
    except OSError:
        return metadata

    for variable in ("name", "_name", "homepage", "repo"):
        pattern = (
            rf"""^\s*(?:export\s+)?{re.escape(variable)}\s*=\s*"""
            rf"""(?:"([^"]*)"|'([^']*)'|([^\s#]*))"""
            rf"""\s*(?:#.*)?$"""
        )

        match = re.search(pattern, content, re.MULTILINE)

        if match:
            metadata[variable] = next(
                (
                    group
                    for group in match.groups()
                    if group is not None
                ),
                "",
            ).strip()

    return expand_metadata_variables(metadata)


def normalise_url(url):
    if not url:
        return ""

    url = url.strip()
    parsed = urllib.parse.urlsplit(url)

    if not parsed.netloc and parsed.path and "://" not in url:
        parsed = urllib.parse.urlsplit("//" + url)

    netloc = parsed.netloc.lower()

    if netloc.startswith("www."):
        netloc = netloc[4:]

    # Preserve path case so distinct project URLs remain distinct.
    result = f"{netloc}{parsed.path}"

    if parsed.query:
        result += f"?{parsed.query}"

    if parsed.fragment:
        result += f"#{parsed.fragment}"

    return result


def normalise_url_relaxed(url):
    return normalise_url(url).rstrip("/")


def normalise_repo(repo):
    if not repo:
        return ""

    repo = repo.strip()
    repo = re.sub(r"^https?://", "", repo, flags=re.IGNORECASE)
    repo = re.sub(r"^www\.", "", repo, flags=re.IGNORECASE)
    repo = repo.rstrip("/")

    if repo.endswith(".git"):
        repo = repo[:-4]

    return repo


def anitya_projects(name):
    params = urllib.parse.urlencode({
        "name": name,
        "items_per_page": 250,
    })

    url = f"{ANITYA_API}/projects/?{params}"
    data = fetch_json(url, f"project {name}")

    if not isinstance(data, dict):
        return []

    for key in ("items", "projects"):
        projects = data.get(key)

        if isinstance(projects, list):
            return projects

    return []


def deduplicate_projects(projects):
    unique = []
    seen = set()

    for project in projects:
        project_id = project.get("id")

        if project_id is not None:
            identity = ("id", str(project_id))
        else:
            identity = (
                "record",
                project.get("name", ""),
                normalise_url(project.get("homepage", "")),
                normalise_repo(project.get("repo", "")),
            )

        if identity not in seen:
            seen.add(identity)
            unique.append(project)

    return unique


def select_project(projects, homepage="", repo=""):
    projects = deduplicate_projects(projects)

    if not projects:
        return None

    homepage_normalised = normalise_url(homepage)
    repo_normalised = normalise_repo(repo)

    # Prefer an exact homepage match across all candidate projects.
    if homepage_normalised:
        matches = [
            project
            for project in projects
            if normalise_url(project.get("homepage", ""))
            == homepage_normalised
        ]

        if len(matches) == 1:
            return matches[0]

        if matches:
            projects = matches
        else:
            # Only relax trailing-slash matching when exact matching fails.
            relaxed_homepage = normalise_url_relaxed(homepage)

            matches = [
                project
                for project in projects
                if normalise_url_relaxed(
                    project.get("homepage", "")
                ) == relaxed_homepage
            ]

            if len(matches) == 1:
                return matches[0]

            if matches:
                projects = matches

    # Use the repository only if the homepage did not uniquely identify
    # the project.
    if repo_normalised:
        matches = [
            project
            for project in projects
            if normalise_repo(project.get("repo", ""))
            == repo_normalised
        ]

        if len(matches) == 1:
            return matches[0]

        if matches:
            projects = matches

    if len(projects) == 1:
        return projects[0]

    return None


def find_project(name, fallback_name, homepage="", repo=""):
    # Search both the package name and the expanded upstream name before
    # selecting, so a misleading package-name match cannot hide the
    # correct upstream project.
    projects = anitya_projects(name)

    if fallback_name and fallback_name.casefold() != name.casefold():
        projects.extend(anitya_projects(fallback_name))

    projects = deduplicate_projects(projects)

    project = select_project(
        projects,
        homepage=homepage,
        repo=repo,
    )

    return project, projects


def anitya_versions(project):
    project_id = project.get("id")

    if project_id is None:
        return None

    params = urllib.parse.urlencode({"project_id": project_id})
    url = f"{ANITYA_API}/versions/?{params}"

    return fetch_json(url, f"versions for Anitya project {project_id}")


def stable_version(data):
    if not isinstance(data, dict):
        return None

    stable = data.get("stable_versions")

    if isinstance(stable, list):
        stable = [str(version) for version in stable if version]

        if stable:
            latest = data.get("latest_version")

            if latest and str(latest) in stable:
                return str(latest)

            return stable[0]

    latest = data.get("latest_version") or data.get("version")

    return str(latest) if latest else None


def get_anitya_version(project):
    data = anitya_versions(project)

    if isinstance(data, dict):
        version = stable_version(data)

        if version:
            return version

    return stable_version(project)


def get_project_detail(project, detail):
    if detail not in project:
        print(
            f"Anitya project has no '{detail}' field",
            file=sys.stderr,
        )
        return None

    value = project[detail]

    if value is None:
        return None

    if isinstance(value, (dict, list)):
        return json.dumps(value, ensure_ascii=False)

    return str(value)


def print_project_options(projects, selected_project=None):
    selected_id = (
        selected_project.get("id")
        if selected_project is not None
        else None
    )

    options = [
        project
        for project in deduplicate_projects(projects)
        if project.get("id") != selected_id
    ]

    if not options:
        print("No alternative Anitya projects found.")
        return 0

    def sort_key(project):
        try:
            return (0, int(project.get("id", 0)))
        except (TypeError, ValueError):
            return (1, str(project.get("id", "")))

    for project in sorted(options, key=sort_key):
        print(
            f"{project.get('id', '')}\t"
            f"{project.get('name', '')}\t"
            f"{project.get('homepage', '')}"
        )

    return 0


def print_ambiguous_project_error(pkg, projects):
    print(
        f"Multiple Anitya projects found for {pkg}, "
        "but none matched its build.sh homepage or repo.",
        file=sys.stderr,
    )

    print("Candidates:", file=sys.stderr)

    for project in projects:
        print(
            f"  {project.get('id', '')}\t"
            f"{project.get('name', '')}\t"
            f"{project.get('homepage', '')}",
            file=sys.stderr,
        )

    print(
        f"Run 'uver {pkg} options' to list the alternatives.",
        file=sys.stderr,
    )

    return 1


def main():
    if len(sys.argv) not in (2, 3):
        print(
            f"Usage: {os.path.basename(sys.argv[0])} PACKAGE [DETAIL]",
            file=sys.stderr,
        )
        return 2

    pkg = sys.argv[1]
    detail = sys.argv[2] if len(sys.argv) == 3 else None

    metadata = read_build_metadata(pkg)

    name = metadata["name"] or pkg
    fallback_name = metadata["_name"]
    homepage = metadata["homepage"]
    repo = metadata["repo"]

    project, projects = find_project(
        name,
        fallback_name,
        homepage=homepage,
        repo=repo,
    )

    if detail == "options":
        return print_project_options(projects, project)

    if not projects:
        print(
            f"Could not find Anitya project for {pkg}",
            file=sys.stderr,
        )
        return 1

    if project is None:
        return print_ambiguous_project_error(pkg, projects)

    if detail:
        value = get_project_detail(project, detail)

        if value is None:
            return 1

        print(value)
        return 0

    version = get_anitya_version(project)

    if version:
        print(version)
        return 0

    print(
        f"Could not determine upstream stable version for {pkg}",
        file=sys.stderr,
    )
    return 1


if __name__ == "__main__":
    sys.exit(main())
