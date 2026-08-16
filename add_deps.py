#!/usr/bin/env python3
import sys
import os
import re
import glob
import time
import subprocess
import urllib.request

LFS_INDEX_URLS = [
    "https://www.linuxfromscratch.org/lfs/view/systemd/index.html",
    "https://www.linuxfromscratch.org/lfs/view/stable/index.html",
]

BLFS_INDEX_URLS = [
    "https://www.linuxfromscratch.org/blfs/view/systemd/index.html",
    "https://www.linuxfromscratch.org/blfs/view/stable/index.html",
]

BLFS_EXTRA_PAGES = [
    "https://www.linuxfromscratch.org/blfs/view/systemd/kde/frameworks6.html",
    "https://www.linuxfromscratch.org/blfs/view/systemd/kde/plasma-all.html",
    "https://www.linuxfromscratch.org/blfs/view/systemd/x/x7lib.html",
    "https://www.linuxfromscratch.org/blfs/view/systemd/x/x7driver.html",
    "https://www.linuxfromscratch.org/blfs/view/systemd/x/x7app.html",
    "https://www.linuxfromscratch.org/blfs/view/systemd/x/x7font.html",
]

CACHE_DIR = "/tmp/lfs_deps_cache"


def fetch_url(url, cache_filename, max_age_hours=24):
    os.makedirs(CACHE_DIR, exist_ok=True)
    cache_path = os.path.join(CACHE_DIR, cache_filename)
    if os.path.exists(cache_path):
        mtime = os.path.getmtime(cache_path)
        if time.time() - mtime < max_age_hours * 3600:
            try:
                with open(cache_path, "r", encoding="utf-8", errors="ignore") as f:
                    return f.read()
            except Exception:
                pass

    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0 (lfs_packaging)"})
        with urllib.request.urlopen(req, timeout=10) as response:
            content = response.read().decode("utf-8", errors="ignore")
            with open(cache_path, "w", encoding="utf-8") as f:
                f.write(content)
            return content
    except Exception as e:
        if os.path.exists(cache_path):
            with open(cache_path, "r", encoding="utf-8", errors="ignore") as f:
                return f.read()
        return ""


def get_lfs_packages():
    pkgs = set()
    for idx, url in enumerate(LFS_INDEX_URLS):
        html = fetch_url(url, f"lfs_index_{idx}.html")
        if not html:
            continue
        # Extract from href="chapter.../<name>.html"
        for href in re.findall(r'href=[\"\']([^\"\']+\.html)[\"\']', html):
            fname = href.split("/")[-1].replace(".html", "").lower()
            if fname not in {"index", "legalnotice", "whatsnew", "changelog", "resources", "askforhelp", "introduction", "hostreqs", "stages", "creatingpartition", "creatingfilesystem", "foreword", "audience", "architecture", "prerequisites", "standards", "package-choices", "typography", "organization", "errata", "how"}:
                pkgs.add(fname)
        # Extract from link titles
        for text in re.findall(r'<a[^>]*>\s*([A-Za-z0-9_+-]+?)(?:-[0-9]|\.html|<|\s*\()', html):
            name = text.strip().lower()
            if len(name) > 1 and name not in {"chapter", "part", "linux", "scratch"}:
                pkgs.add(name)
    return pkgs


def get_blfs_packages():
    pkgs = set()
    for idx, url in enumerate(BLFS_INDEX_URLS):
        html = fetch_url(url, f"blfs_index_{idx}.html")
        if not html:
            continue
        for href in re.findall(r'href=[\"\']([^\"\']+\.html)[\"\']', html):
            fname = href.split("/")[-1].replace(".html", "").lower()
            if fname not in {"index", "legalnotice", "welcome", "which", "conventions", "version", "mirrors", "packages", "changelog", "maillists", "wiki", "askhelp", "credits", "contactinfo", "important", "notes-on-building", "unpacking", "kde", "introduction", "kf-apps", "plasma"}:
                pkgs.add(fname)
        for text in re.findall(r'<a[^>]*>\s*([A-Za-z0-9_+-]+?)(?:-[0-9]|\.html|<|\s*\()', html):
            name = text.strip().lower()
            if len(name) > 1 and name not in {"chapter", "part", "linux", "scratch", "beyond"}:
                pkgs.add(name)

    for idx, url in enumerate(BLFS_EXTRA_PAGES):
        html = fetch_url(url, f"blfs_extra_{idx}.html")
        if not html:
            continue
        for m in re.finditer(r'([a-zA-Z0-9_+-]+)-[0-9]+\.[0-9]+', html):
            pkgs.add(m.group(1).lower())
        for m in re.finditer(r'<h3>\s*([a-zA-Z0-9_+-]+)', html):
            pkgs.add(m.group(1).lower())

    return pkgs


def build_installed_files_index():
    path_to_pkg = {}
    basename_to_pkg = {}

    db_paths = glob.glob("/var/lib/custom-packages/*") + glob.glob("/var/lib/book-packages/*")
    for db_path in db_paths:
        pkg_name = os.path.basename(db_path)
        try:
            with open(db_path, "r", encoding="utf-8", errors="ignore") as f:
                lines = f.read().splitlines()
            if len(lines) > 1:
                for file_path in lines[1:]:
                    file_path = file_path.strip()
                    if file_path:
                        path_to_pkg[file_path] = pkg_name
                        base = os.path.basename(file_path)
                        if base.startswith("lib") or ".so" in base:
                            basename_to_pkg[base] = pkg_name
        except Exception:
            continue

    return path_to_pkg, basename_to_pkg


def get_package_files(pkg_name):
    for dir_path in ["/var/lib/custom-packages", "/var/lib/book-packages"]:
        db_file = os.path.join(dir_path, pkg_name)
        if os.path.exists(db_file):
            try:
                with open(db_file, "r", encoding="utf-8", errors="ignore") as f:
                    lines = f.read().splitlines()
                if len(lines) > 1:
                    return lines[1:]
            except Exception:
                pass
    return []


def inspect_elf_dependencies(file_paths):
    libs_needed = set()
    examined_files = []

    for path in file_paths:
        if not os.path.exists(path) or os.path.isdir(path):
            continue
        # Check if regular file or symlink pointing to regular file
        try:
            res = subprocess.run(["ldd", path], capture_output=True, text=True, errors="ignore")
            if res.returncode != 0:
                continue
            has_deps = False
            for line in res.stdout.splitlines():
                line = line.strip()
                if not line or "linux-vdso.so" in line:
                    continue
                if "=>" in line:
                    parts = line.split("=>")
                    right = parts[1].strip()
                    if right.startswith("/"):
                        lib_path = right.split()[0]
                        libs_needed.add(lib_path)
                        has_deps = True
                elif line.startswith("/"):
                    lib_path = line.split()[0]
                    libs_needed.add(lib_path)
                    has_deps = True
            if has_deps:
                examined_files.append(path)
        except Exception:
            continue

    return libs_needed, examined_files


def parse_array_from_script(content, var_name):
    pattern = r'(?m)^[ \t]*' + re.escape(var_name) + r'=\(([\s\S]*?)\)'
    m = re.search(pattern, content)
    if m:
        body = m.group(1)
        cleaned = re.sub(r'#[^\n]*', '', body)
        return set(cleaned.split()), m.start(), m.end()
    return None, -1, -1


def update_build_script(build_sh_path, add_depends, add_lfs_depends, add_blfs_depends, dry_run=False):
    if not os.path.exists(build_sh_path):
        print(f"Error: {build_sh_path} does not exist.", file=sys.stderr)
        return False

    with open(build_sh_path, "r", encoding="utf-8") as f:
        content = f.read()

    modified = False

    def update_or_insert(curr_content, var_name, items_to_add):
        nonlocal modified
        if not items_to_add:
            return curr_content

        existing, start, end = parse_array_from_script(curr_content, var_name)
        if existing is not None:
            new_items = sorted(list(existing.union(items_to_add)))
            if new_items != sorted(list(existing)):
                replacement = f"{var_name}=({' '.join(new_items)})"
                curr_content = curr_content[:start] + replacement + curr_content[end:]
                modified = True
        else:
            # Variable doesn't exist yet, insert it
            new_items = sorted(list(items_to_add))
            declaration = f"{var_name}=({' '.join(new_items)})"
            # Try to place adjacent to depends/lfs_depends/blfs_depends or after version/name
            dep_patterns = [
                r'(?m)^[ \t]*(?:lfs_|blfs_|pip_)?depends=\([\s\S]*?\)',
                r'(?m)^[ \t]*version=.*$',
                r'(?m)^[ \t]*name=.*$',
                r'(?m)^[ \t]*set\s+.*$',
                r'(?m)^#!/bin/bash.*$',
            ]
            inserted = False
            for pat in dep_patterns:
                match = re.search(pat, curr_content)
                if match:
                    end_pos = match.end()
                    if end_pos < len(curr_content) and curr_content[end_pos] == "\n":
                        end_pos += 1
                    curr_content = curr_content[:end_pos] + declaration + "\n" + curr_content[end_pos:]
                    inserted = True
                    modified = True
                    break
            if not inserted:
                curr_content = declaration + "\n" + curr_content
                modified = True

        return curr_content

    content = update_or_insert(content, "depends", add_depends)
    content = update_or_insert(content, "lfs_depends", add_lfs_depends)
    content = update_or_insert(content, "blfs_depends", add_blfs_depends)

    if modified:
        if not dry_run:
            with open(build_sh_path, "w", encoding="utf-8") as f:
                f.write(content)
        return True
    return False


def find_deps(pkg_name, dry_run=False, verbose=False):
    workspace_root = os.path.expanduser("~/lfs_packaging")
    pkg_build_sh = os.path.join(workspace_root, pkg_name, "build.sh")

    if not os.path.exists(pkg_build_sh):
        print(f"Error: build.sh for package '{pkg_name}' not found at {pkg_build_sh}", file=sys.stderr)
        return 1

    print(f"Finding dependencies for package: {pkg_name}")
    pkg_files = get_package_files(pkg_name)
    if not pkg_files:
        print(f"Warning: No installed files database found in /var/lib/{{custom,book}}-packages/{pkg_name}")
        # Search for typical binaries or libraries matching the package name
        common_candidates = glob.glob(f"/usr/bin/*{pkg_name}*") + glob.glob(f"/usr/lib/*{pkg_name}*.so*")
        pkg_files = common_candidates

    libs_needed, examined_files = inspect_elf_dependencies(pkg_files)
    print(f"Examined {len(examined_files)} binaries/libraries, discovered {len(libs_needed)} shared library dependencies.")

    if verbose and examined_files:
        print("Examined files:")
        for ef in examined_files:
            print(f"  - {ef}")

    path_to_pkg, basename_to_pkg = build_installed_files_index()

    mapped_pkgs = set()
    unmapped_libs = []

    for lib in libs_needed:
        real_lib = os.path.realpath(lib)
        dep_pkg = path_to_pkg.get(lib) or path_to_pkg.get(real_lib)
        if not dep_pkg:
            dep_pkg = basename_to_pkg.get(os.path.basename(lib)) or basename_to_pkg.get(os.path.basename(real_lib))

        if dep_pkg:
            if dep_pkg != pkg_name:
                mapped_pkgs.add(dep_pkg)
        else:
            unmapped_libs.append(lib)

    if unmapped_libs and verbose:
        print("Unmapped libraries:")
        for ul in unmapped_libs:
            print(f"  - {ul}")

    print(f"Mapped to {len(mapped_pkgs)} unique dependency packages: {', '.join(sorted(mapped_pkgs)) if mapped_pkgs else 'None'}")

    # Fetch LFS and BLFS package lists
    lfs_pkgs = get_lfs_packages()
    blfs_pkgs = get_blfs_packages()

    # Categorize dependencies
    custom_deps = set()
    lfs_deps = set()
    blfs_deps = set()

    for dep in mapped_pkgs:
        dep_build = os.path.join(workspace_root, dep, "build.sh")
        if os.path.exists(dep_build):
            custom_deps.add(dep)
        elif dep.lower() in lfs_pkgs:
            lfs_deps.add(dep)
        elif dep.lower() in blfs_pkgs or os.path.exists(f"/var/lib/book-packages/{dep}"):
            blfs_deps.add(dep)
        else:
            # Default to BLFS if in book-packages or unknown
            blfs_deps.add(dep)

    print("\nCategorized dependencies:")
    print(f"  depends (custom ~/lfs_packaging) : {sorted(list(custom_deps)) if custom_deps else 'None'}")
    print(f"  lfs_depends (LFS book)           : {sorted(list(lfs_deps)) if lfs_deps else 'None'}")
    print(f"  blfs_depends (BLFS book)         : {sorted(list(blfs_deps)) if blfs_deps else 'None'}")

    # Update build.sh
    changed = update_build_script(pkg_build_sh, custom_deps, lfs_deps, blfs_deps, dry_run=dry_run)
    if changed:
        action = "Would update" if dry_run else "Updated"
        print(f"\n[SUCCESS] {action} {pkg_build_sh}")
    else:
        print(f"\n[INFO] {pkg_build_sh} is already up-to-date with all discovered dependencies.")

    return 0


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: find_deps <package_name> [--dry-run] [--verbose]")
        sys.exit(1)

    pkg = sys.argv[1]
    is_dry_run = "--dry-run" in sys.argv or "-n" in sys.argv
    is_verbose = "--verbose" in sys.argv or "-v" in sys.argv

    sys.exit(find_deps(pkg, dry_run=is_dry_run, verbose=is_verbose))
