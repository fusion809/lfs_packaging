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
        match = re.search(
            rf'^\s*(?:export\s+)?{re.escape(variable)}\s*=\s*'
            rf'(?:"([^"]*)"|\'([^\']*)\'|([^\s#]*))'
            rf'\s*(?:#.*)?$',
            content,
            re.MULTILINE,
        )

        if not match:
            continue

        value = next(
            (
                group
                for group in match.groups()
                if group is not None
            ),
            "",
        )

        metadata[variable] = value.strip()

    return metadata


def normalise_url(url):
    if not url:
        return ""

    url = url.strip().lower()
    url = re.sub(r"^https?://", "", url)
    url = re.sub(r"^www\.", "", url)

    return url.rstrip("/")


def normalise_repo(repo):
    if not repo:
        return ""

    repo = repo.strip().lower()
    repo = re.sub(r"^https?://", "", repo)
    repo = re.sub(r"^www\.", "", repo)
    repo = repo.rstrip("/")

    if repo.endswith(".git"):
        repo = repo[:-4]

    return repo


def anitya_projects(name):
    params = urllib.parse.urlencode(
        {
            "name": name,
            "items_per_page": 250,
        }
    )

    url = f"{ANITYA_API}/projects/?{params}"

    data = fetch_json(
        url,
        f"project {name}",
    )

    if not isinstance(data, dict):
        return []

    projects = data.get("items")

    if isinstance(projects, list):
        return projects

    projects = data.get("projects")

    if isinstance(projects, list):
        return projects

    return []


def select_project(projects, homepage="", repo=""):
    if not projects:
        return None

    homepage = normalise_url(homepage)
    repo = normalise_repo(repo)

    # If a homepage was supplied, it takes precedence over the
    # number of projects returned by Anitya.
    if homepage:
        homepage_matches = [
            project
            for project in projects
            if normalise_url(
                project.get("homepage", "")
            ) == homepage
        ]

        if homepage_matches:
            projects = homepage_matches
        else:
            return None

    # If a repository was supplied, use it to further disambiguate.
    if repo:
        repo_matches = [
            project
            for project in projects
            if normalise_repo(
                project.get("repo", "")
            ) == repo
        ]

        if repo_matches:
            projects = repo_matches
        else:
            return None

    # A single remaining project is unambiguous.
    if len(projects) == 1:
        return projects[0]

    # Multiple projects remain. Do not arbitrarily choose one here.
    return None


def anitya_versions(project):
    project_id = project.get("id")

    if project_id is None:
        return None

    params = urllib.parse.urlencode(
        {
            "project_id": project_id,
        }
    )

    url = f"{ANITYA_API}/versions/?{params}"

    return fetch_json(
        url,
        f"versions for Anitya project {project_id}",
    )


def stable_version(data):
    if not isinstance(data, dict):
        return None

    stable = data.get("stable_versions")

    if not isinstance(stable, list):
        stable = []

    stable = [
        str(version)
        for version in stable
        if version
    ]

    if not stable:
        return None

    latest = data.get("latest_version")

    if latest and str(latest) in stable:
        return str(latest)

    return stable[0]


def get_anitya_version(project):
    data = anitya_versions(project)

    if isinstance(data, dict):
        version = stable_version(data)

        if version:
            return version

    stable = project.get("stable_versions")

    if isinstance(stable, list):
        stable = [
            str(version)
            for version in stable
            if version
        ]

        if stable:
            latest = project.get("latest_version")

            if latest and str(latest) in stable:
                return str(latest)

            return stable[0]

    latest = project.get("latest_version")

    if latest:
        return str(latest)

    latest = project.get("version")

    if latest:
        return str(latest)

    return None


def get_anitya_project(name, homepage="", repo=""):
    projects = anitya_projects(name)

    if not projects:
        return None, projects

    project = select_project(
        projects,
        homepage=homepage,
        repo=repo,
    )

    return project, projects


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
        return json.dumps(
            value,
            ensure_ascii=False,
        )

    return str(value)


def print_project_options(projects, selected_project=None):
    selected_id = None

    if selected_project is not None:
        selected_id = selected_project.get("id")

    options = [
        project
        for project in projects
        if project.get("id") != selected_id
    ]

    if not options:
        print("No alternative Anitya projects found.")
        return 0

    for project in sorted(
        options,
        key=lambda project: int(
            project.get("id", 2**63 - 1)
        ),
    ):
        project_id = project.get("id", "")
        name = project.get("name", "")
        homepage = project.get("homepage", "")

        print(
            f"{project_id}\t{name}\t{homepage}"
        )

    return 0


def print_ambiguous_project_error(pkg):
    print(
        f"Multiple Anitya projects found for {pkg}, "
        "but none could be selected using the "
        "build.sh homepage or repo.",
        file=sys.stderr,
    )

    print(
        f"Run 'uver {pkg} options' to list the alternatives.",
        file=sys.stderr,
    )

    return 1


def find_project(
    name,
    fallback_name,
    homepage="",
    repo="",
):
    # First try the normal package name.
    projects = anitya_projects(name)

    if projects:
        project = select_project(
            projects,
            homepage=homepage,
            repo=repo,
        )

        if project is not None:
            return project, projects, name

    # If the normal name did not identify the correct project,
    # try the explicit _name from build.sh.
    if fallback_name and fallback_name != name:
        fallback_projects = anitya_projects(fallback_name)

        if fallback_projects:
            fallback_project = select_project(
                fallback_projects,
                homepage=homepage,
                repo=repo,
            )

            if fallback_project is not None:
                return (
                    fallback_project,
                    fallback_projects,
                    fallback_name,
                )

            if not projects:
                return (
                    None,
                    fallback_projects,
                    fallback_name,
                )

    return None, projects, name


def main():
    if len(sys.argv) not in (2, 3):
        print(
            f"Usage: {os.path.basename(sys.argv[0])} "
            "PACKAGE [DETAIL]",
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

    project, projects, selected_name = find_project(
        name,
        fallback_name,
        homepage=homepage,
        repo=repo,
    )

    if detail == "options":
        return print_project_options(
            projects,
            project,
        )

    if not projects:
        print(
            f"Could not find Anitya project for {pkg}",
            file=sys.stderr,
        )

        return 1

    if project is None:
        return print_ambiguous_project_error(pkg)

    if detail:
        value = get_project_detail(
            project,
            detail,
        )

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
