#!/bin/sh
# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------
#
# SHELL wrapper used by "gmake check_track" (gmake check SHELL=<this script>).
# It runs each recipe line unchanged, then records in checkdiff/track/trace/:
#   trace.tsv          phase <TAB> counter value <TAB> snapshot sha256 (or -) <TAB> command <TAB> rc
#   snap/<sha256>.gz   sorted content the counter command counted (one file per distinct content)
#   last.txt           exit status and text of the last recipe line run (diagnosis of a run stopped midway)
# Snapshots cover every counter line that reads files (cat, find, grep/egrep, wc -c < file):
# the pipe into gmake is excluded, rerunning it here would be unsafe and costly.
#
# usage (by gmake only): trace_shell.sh -c "command"

TRACK_DIR="${CAWK_TRACK_DIR:-checkdiff/track}"
TRACE_DIR="$TRACK_DIR/trace"

/bin/sh "$@"
rc=$?

# the command is the last argument, the others are the shell flags
for cmd; do :; done

printf '%s\t%s\n' "$rc" "$cmd" > "$TRACE_DIR/last.txt" 2>/dev/null

case "$cmd" in
*">> checkdiff/checkdiff.new"*)
	[ -d "$TRACE_DIR/snap" ] || exit $rc
	n=$(( $(cat "$TRACE_DIR/trace.tsv" 2>/dev/null | wc -l) + 1 ))
	value=$(tail -n 1 checkdiff/checkdiff.new)
	hash="-"
	# source command whose stdout is the counted content, to snapshot it
	snap_src=""
	case "$cmd" in
	*" | wc -l >> checkdiff/checkdiff.new")
		left=${cmd%" | wc -l >> checkdiff/checkdiff.new"}
		case "$left" in
		"cat "*|"find "*|"grep "*|"egrep "*|"fgrep "*|"sort "*) snap_src="$left" ;;
		esac
		;;
	"wc -c < "*" >> checkdiff/checkdiff.new")
		snap_src="cat ${cmd#wc -c < }"
		snap_src=${snap_src%" >> checkdiff/checkdiff.new"}
		;;
	esac
	if [ -n "$snap_src" ]; then
		tmp="$TRACE_DIR/snap/.tmp.$$"
		sh -c "$snap_src" 2>/dev/null | LC_ALL=C sort | gzip -n -c > "$tmp"
		hash=$(sha256sum "$tmp" | cut -d' ' -f1)
		if [ -f "$TRACE_DIR/snap/$hash.gz" ]; then rm -f "$tmp"; else mv "$tmp" "$TRACE_DIR/snap/$hash.gz"; fi
	fi
	printf '%s\t%s\t%s\t%s\t%s\n' "$n" "$value" "$hash" "$cmd" "$rc" >> "$TRACE_DIR/trace.tsv"
	;;
esac

exit $rc
