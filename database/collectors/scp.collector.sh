#!/bin/sh
#==============================================================================
# File        : scp.collector.sh
# Purpose     : Collect the configurations stored as files on a central unix/linux system, copying them with scp
# Args        : host=ADDRESS,user=USER,remote_path=REMOTE_DIR[,key=IDENTITY_FILE][,port=N][,timeout=SECONDS][,hostkey=yes|accept-new][,options=OPTS]
#                 host     host name or IP address of the central system
#                 user     account used to log in
#                 remote_path  absolute directory of the central system holding one file per device, e.g. /srv/confs/
#                 key      identity file (the ssh agent or the default keys when not given)
#                 hostkey  StrictHostKeyChecking value, yes by default (the host must be in known_hosts)
#                 options  extra scp options, words separated by + (an arg has no space), e.g. -4+-o+ServerAliveInterval=5
#                          or -J+bastion; they come after the options set by the other args
# Note        : the copy is automatic: scp -rpq of REMOTE_DIR/* (with OpenSSH 9.0 or later scp uses the sftp
#               protocol); only the regular files at the top of the directory are collected, one per device,
#               named after the device; key or agent authentication only (BatchMode), never a password
#==============================================================================

. "$(dirname "$0")/collector_common.sh"

collector_init "$1" "$2" "$3"
collector_require scp

host=$(collector_arg host "")
user=$(collector_arg user "")
remote_path=$(collector_arg remote_path "")
key=$(collector_arg key "")
port=$(collector_arg port 22)
timeout=$(collector_arg timeout 20)
hostkey=$(collector_arg hostkey yes)
options=$(collector_arg options "")
collector_valid_host "$host" || { echo "cawk error: scp host=<$host> must be a host name or an IP address ----" >&2; exit 2; }
collector_valid_name "$user" || { echo "cawk error: scp user=<$user> must be set (letters, digits, dot, dash, underscore) ----" >&2; exit 2; }
collector_valid_remote_path "$remote_path" || { echo "cawk error: scp remote_path=<$remote_path> must be an absolute directory (letters, digits, dot, dash, underscore, slash) ----" >&2; exit 2; }
collector_valid_number "$port" || { echo "cawk error: scp port=<$port> must be a number ----" >&2; exit 2; }
collector_valid_number "$timeout" || { echo "cawk error: scp timeout=<$timeout> must be a number ----" >&2; exit 2; }
case $hostkey in yes|accept-new) ;; *) echo "cawk error: scp hostkey=<$hostkey> must be yes or accept-new ----" >&2; exit 2 ;; esac
collector_valid_options "$options" || { echo "cawk error: scp options=<$options> has an unsupported character (words are separated by +) ----" >&2; exit 2; }

# an IPv6 address needs brackets in an scp source
case $host in *:*) src="$user@[$host]:${remote_path%/}/*" ;; *) src="$user@$host:${remote_path%/}/*" ;; esac

set -- -rpq -B -o "ConnectTimeout=$timeout" -o "StrictHostKeyChecking=$hostkey" -P "$port"
[ -z "$key" ] || set -- "$@" -i "$key"
if [ -n "$options" ]; then
	set -f
	# shellcheck disable=SC2046
	set -- "$@" $(printf '%s' "$options" | tr '+' ' ')
	set +f
fi

pulled="$COLLECT_TMP/pulled"
mkdir -p "$pulled"
if ! scp "$@" "$src" "$pulled/" > /dev/null 2> "$COLLECT_TMP/err"; then
	echo "cawk error: scp collection from <$src> failed: $(sed -n 1p "$COLLECT_TMP/err"), previous configurations kept ----" >&2
	exit 1
fi

for conf in "$pulled"/*; do
	[ -f "$conf" ] && [ ! -L "$conf" ] || continue
	# network devices configurations may come with CRLF, which the cawk assessments reject
	tr -d '\r' < "$conf" > "$COLLECT_TMP/norm"
	touch -r "$conf" "$COLLECT_TMP/norm"
	collector_store "${conf##*/}" "$COLLECT_TMP/norm"
done

collector_scope "$COLLECT_TMP/seen"
collector_finish
