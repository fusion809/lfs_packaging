#!/bin/bash
set -e
name=figcraft
repo=storytold/$name
description="Vibe coded interface design and prototyping."
homepage="https://getartcraft.com/apps/figcraft"
version=$(gh_ver $repo)
depends=(gcc glibc)
craft_buildin $name $version
