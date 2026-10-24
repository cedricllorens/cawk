#!/bin/sh
#==============================================================================
# File        : local.collector.sh
# Purpose     : Collect the configurations stored as files in a directory of the cawk machine, copying them with cp
# Args        : source_path=LOCAL_DIR
#                 source_path  absolute directory of the cawk machine holding one file per device, e.g. /srv/confs/
# Note        : the copy is automatic: cp -p of the regular files at the top of the directory (no network, no ssh),
#               one per device, named after the device
#==============================================================================

. "$(dirname "$0")/collector_common.sh"

collector_init "$1" "$2" "$3"
collector_require cp

source_path=$(collector_arg source_path "")
collector_valid_remote_path "$source_path" || { echo "cawk error: local source_path=<$source_path> must be an absolute directory (letters, digits, dot, dash, underscore, slash) ----" >&2; exit 2; }

if [ ! -d "$source_path" ]; then
	echo "cawk error: local source_path=<$source_path> is not a directory, previous configurations kept ----" >&2
	exit 1
fi

for conf in "${source_path%/}"/*; do
	[ -f "$conf" ] && [ ! -L "$conf" ] || continue
	collector_store "${conf##*/}" "$conf"
done

collector_scope "$COLLECT_TMP/seen"
collector_finish
