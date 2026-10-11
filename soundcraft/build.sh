#!/bin/bash
set -e
name=soundcraft
repo=storytold/$name
description="Vibe coded clean-room reimplementation of Avid Pro Tools."
homepage="https://getartcraft.com/apps/soundcraft"
version=$(gh_ver $repo)
depends=(alsa-lib gcc glibc)
craft_buildin $name $version