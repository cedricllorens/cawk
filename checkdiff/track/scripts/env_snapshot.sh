#!/bin/sh
# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------
#
# Write the context of a check run (tools, locale, git, fixtures age).
#
# usage: env_snapshot.sh OUTPUT_FILE

out="$1"
[ -n "$out" ] || { echo "usage: env_snapshot.sh OUTPUT_FILE"; exit 1; }

{
	echo "date: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "uname: $(uname -sr)"
	echo "locale: LANG=${LANG:-} LC_ALL=${LC_ALL:-}"
	echo "gawk: $(gawk --version 2>&1 | head -n 1)"
	echo "gmake: $(gmake --version 2>&1 | head -n 1)"
	echo "m4: $(m4 --version 2>&1 | head -n 1)"
	echo "sed: $(sed --version 2>&1 | head -n 1)"
	echo "git head: $(git rev-parse --short HEAD 2>/dev/null || echo none)"
	echo "git status: $(git status --short 2>/dev/null | wc -l) modified/untracked"
	echo "fixtures (validate/test-sync/source), age in days:"
	now=$(date +%s)
	for f in validate/test-sync/source/*.cfg; do
		[ -f "$f" ] || continue
		echo "  $f $(( (now - $(stat -c %Y "$f")) / 86400 ))"
	done
} > "$out"
