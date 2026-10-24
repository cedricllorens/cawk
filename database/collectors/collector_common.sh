#!/bin/sh
#==============================================================================
# File        : collector_common.sh
# Purpose     : Shared helpers of the cawk collectors
# Note        : Include-only file; source it from a collector via:
#               . "$(dirname "$0")/collector_common.sh"
#               Must NOT be executed directly.
#
# A collector is an optional external script (it may use scp, rsync: cawk
# itself only needs gawk, gmake and m4) called from the repository root as:
#
#   sh database/collectors/<name>.collector.sh AUDIT DEST_DIR [ARGS]
#
#   AUDIT     audit name
#   DEST_DIR  confs/collect_<audit>: one plain-text file per device, named after
#             the device (the sync matches this file name against the inventory)
#   ARGS      comma-separated key=value pairs, "none" when empty (no space, no comma in a value)
#
# A collector only fills DEST_DIR (never anything else under confs/): the cawk
# sync (db_sync.txt, sync_paths=../collect_<audit>/) links the files into
# confs/run_<audit>/confs.<supplier>/. Exit code: 0 all devices collected,
# 1 at least one device failed (previous files are kept), 2 usage/dependency error.
#==============================================================================

[ -f database/include/scripts_config.sh ] && . database/include/scripts_config.sh

# $1 = audit, $2 = destination directory, $3 = args
collector_init() {
	COLLECT_AUDIT=$1
	COLLECT_DEST=$2
	COLLECT_ARGS=${3:-none}
	if [ -z "$COLLECT_AUDIT" ] || [ -z "$COLLECT_DEST" ]; then
		echo "cawk error: usage: <name>.collector.sh AUDIT DEST_DIR [ARGS] ----" >&2
		exit 2
	fi
	mkdir -p "$COLLECT_DEST" tmp || exit 2
	COLLECT_TMP=$(mktemp -d -p tmp) || exit 2
	: > "$COLLECT_TMP/seen"
	COLLECT_FAILED=0
	trap 'rm -rf "$COLLECT_TMP"' EXIT
	trap 'exit 2' INT TERM
}

# $1 = key, $2 = default value
collector_arg() {
	_val=$(printf '%s\n' "$COLLECT_ARGS" | tr ',' '\n' | sed -n "s/^$1=//p" | sed -n 1p)
	if [ -n "$_val" ]; then printf '%s\n' "$_val"; else printf '%s\n' "$2"; fi
}

collector_require() {
	for _cmd in "$@"; do
		command -v "$_cmd" >/dev/null 2>&1 || { echo "cawk error: $_cmd is required by this collector ----" >&2; exit 2; }
	done
}

# a device name becomes a file name and may reach a command line: letters, digits, dot, dash, underscore
collector_valid_name() {
	case $1 in
		''|.*|*[!A-Za-z0-9._-]*) return 1 ;;
	esac
	return 0
}

# host name or IP address of a central system: letters, digits, dot, dash, colon (IPv6), no leading dash
collector_valid_host() {
	case $1 in
		''|-*|*[!A-Za-z0-9.:-]*) return 1 ;;
	esac
	return 0
}

# absolute directory of the central system holding the confs: letters, digits, dot, dash, underscore, slash
collector_valid_remote_path() {
	case $1 in
		/*) ;;
		*) return 1 ;;
	esac
	case $1 in
		*[!A-Za-z0-9._/-]*) return 1 ;;
	esac
	return 0
}

# extra command line options of a collector (options=): words separated by "+" (an arg has no space), only
# characters that cannot open a shell or glob expansion
collector_valid_options() {
	case $1 in
		*[!A-Za-z0-9._=:/@%+-]*) return 1 ;;
	esac
	return 0
}

collector_valid_number() {
	case $1 in
		''|*[!0-9]*) return 1 ;;
	esac
	return 0
}

# $1 = device name, $2 = configuration file (the modification time is kept: it feeds the deadbeef scan)
# The previous file is only replaced by a non-empty one, atomically.
collector_store() {
	if ! collector_valid_name "$1"; then
		echo "cawk error: invalid device name <$1>, skipped ----" >&2
		COLLECT_FAILED=1
		return 1
	fi
	if [ ! -s "$2" ]; then
		echo "cawk error: empty configuration for <$1>, previous configuration kept ----" >&2
		COLLECT_FAILED=1
		return 1
	fi
	cp -p "$2" "$COLLECT_TMP/store.$1" && mv -f "$COLLECT_TMP/store.$1" "$COLLECT_DEST/$1" || { COLLECT_FAILED=1; return 1; }
	echo "$1" >> "$COLLECT_TMP/seen"
}

# $1 = inventory file (device name = first field, separators ; : , space tab): scope file of the sync (db_sync.txt field 4)
collector_scope() {
	mkdir -p "${DATABASE_PATH:-database}/sync_scopes" || return 1
	awk -F'[;:, \t]+' '!/^[ \t]*(#|$)/ { print $1 }' "$1" | sort -u > "${DATABASE_PATH:-database}/sync_scopes/collect_$COLLECT_AUDIT.txt"
}

# Devices that are no longer collected are removed, but only after a fully successful run that saw
# at least one device (an unreachable source must never empty the destination).
collector_finish() {
	if [ "$COLLECT_FAILED" -eq 0 ] && [ -s "$COLLECT_TMP/seen" ]; then
		for _f in "$COLLECT_DEST"/*; do
			[ -f "$_f" ] || continue
			grep -qx -- "${_f##*/}" "$COLLECT_TMP/seen" || rm -f -- "$_f"
		done
	fi
	exit "$COLLECT_FAILED"
}
