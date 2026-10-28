#!/bin/bash
set -e
name=deckcraft
repo=storytold/$name
description="Vibe coded clean-room reimplementation of Microsoft PowerPoint."
homepage="https://getartcraft.com/apps/deckcraft"
version=$(gh_ver $repo)
depends=(alsa-lib gcc glibc)
conflicts=(deckcraft-bin)
craft_buildin $name $version

