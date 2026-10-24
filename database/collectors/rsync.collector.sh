#!/bin/sh
#==============================================================================
# File        : rsync.collector.sh
# Purpose     : Collect the configurations stored as files on a central unix/linux system, with rsync over ssh
# Args        : host=ADDRESS,user=USER,remote_path=REMOTE_DIR[,key=IDENTITY_FILE][,port=N][,timeout=SECONDS][,hostkey=yes|accept-new][,options=OPTS]
#                 host     host name or IP address of the central system
#                 user     account used to log in
#                 remote_path  absolute directory of the central system holding one file per device, e.g. /srv/confs/
#                 key      identity file (the ssh agent or the default keys when not given)
#                 hostkey  StrictHostKeyChecking value, yes by default (the host must be in known_hosts)
#                 options  extra rsync options, words separated by + (an arg has no space), e.g. --bwlimit=1000+--compress;
#                          they come after the options set by the other args
# Note        : the copy is automatic: rsync -rt of REMOTE_DIR/ over ssh (BatchMode); only the regular files at
#               the top of the directory are collected, one per device, named after the device; key or agent
#               authentication only, never a password
#==============================================================================

. "$(dirname "$0")/collector_common.sh"

collector_init "$1" "$2" "$3"
collector_require rsync ssh

host=$(collector_arg host "")
user=$(collector_arg user "")
remote_path=$(collector_arg remote_path "")
key=$(collector_arg key "")
port=$(collector_arg port 22)
timeout=$(collector_arg timeout 30)
hostkey=$(collector_arg hostkey yes)
options=$(collector_arg options "")
collector_valid_host "$host" || { echo "cawk error: rsync host=<$host> must be a host name or an IP address ----" >&2; exit 2; }
collector_valid_name "$user" || { echo "cawk error: rsync user=<$user> must be set (letters, digits, dot, dash, underscore) ----" >&2; exit 2; }
collector_valid_remote_path "$remote_path" || { echo "cawk error: rsync remote_path=<$remote_path> must be an absolute directory (letters, digits, dot, dash, underscore, slash) ----" >&2; exit 2; }
collector_valid_number "$port" || { echo "cawk error: rsync port=<$port> must be a number ----" >&2; exit 2; }
collector_valid_number "$timeout" || { echo "cawk error: rsync timeout=<$timeout> must be a number ----" >&2; exit 2; }
case $hostkey in yes|accept-new) ;; *) echo "cawk error: rsync hostkey=<$hostkey> must be yes or accept-new ----" >&2; exit 2 ;; esac
collector_valid_options "$options" || { echo "cawk error: rsync options=<$options> has an unsupported character (words are separated by +) ----" >&2; exit 2; }

# the trailing slash copies the content of the directory; an IPv6 address needs brackets in an rsync source
case $host in *:*) src="$user@[$host]:${remote_path%/}/" ;; *) src="$user@$host:${remote_path%/}/" ;; esac

rsh="ssh -o BatchMode=yes -o StrictHostKeyChecking=$hostkey -p $port"
[ -z "$key" ] || rsh="$rsh -i $key"
set -- -rt "--timeout=$timeout" -e "$rsh"
if [ -n "$options" ]; then
	set -f
	# shellcheck disable=SC2046
	set -- "$@" $(printf '%s' "$options" | tr '+' ' ')
	set +f
fi

pulled="$COLLECT_TMP/pulled"
mkdir -p "$pulled"
if ! rsync "$@" "$src" "$pulled/" > /dev/null 2> "$COLLECT_TMP/err"; then
	echo "cawk error: rsync collection from <$src> failed: $(sed -n 1p "$COLLECT_TMP/err"), previous configurations kept ----" >&2
	exit 1
fi

for conf in "$pulled"/*; do
	[ -f "$conf" ] && [ ! -L "$conf" ] || continue
	collector_store "${conf##*/}" "$conf"
done

collector_scope "$COLLECT_TMP/seen"
collector_finish
