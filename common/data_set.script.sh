#!/bin/sh

# ---------------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# data_set of a named audit: one line per date of key values of the last
# assessment, one file per date: database/data_set/run_<audit>/data_set_<audit>_YYYY-MM-DD.txt
# (docs/CAWK_DATABASE_FORMAT.md)
#
# usage (from the cawk root, gmake data_set_*):
#   data_set.script.sh init   AUDIT             create the directory run_AUDIT if missing
#   data_set.script.sh append AUDIT KEEP DATE   write the file of DATE (replace the same date), keep the KEEP last files
# ---------------------------------------------------------------------

LC_ALL=C
export LC_ALL

DS=database/data_set
HEADER='# date;key=value;... (keys: the number_of_* of the summary without the prefix, nist_ref_coverage=covered/total, nist_<family>=covered/total)'

fail() {
	echo "cawk error: $1 ----"
	exit 1
}

[ -f Makefile ] && [ -d database ] || fail "run this script from the cawk root"
cmd="$1"; audit="$2"; keep="$3"; day="$4"
[ -n "$audit" ] || fail "audit= must be set (usage: data_set.script.sh init|append AUDIT [KEEP DATE])"
dir="$DS/run_$audit"
f="$dir/data_set_${audit}_$day.txt"

check_keep() {
	case "$keep" in
	''|*[!0-9]*|0|0[0-9]*) fail "DATA_SET_KEEP=$keep is not a number >= 1" ;;
	esac
}

# header + the line of stdin, written through a swap file (never a truncated data_set)
write_file() {
	{ echo "$HEADER"; cat; } > "$f.swap" || { rm -f "$f.swap"; fail "cannot write $f.swap"; }
	mv "$f.swap" "$f" || { rm -f "$f.swap"; fail "cannot replace $f"; }
}

# only the directories run_<audit>/ follow the norm: a file run_* is a leftover, deleted
purge_stray() {
	for s in "$DS"/run_*; do
		[ -e "$s" ] || [ -L "$s" ] || continue
		[ -d "$s" ] && [ ! -L "$s" ] && continue
		rm -f "$s" || fail "cannot remove $s"
		echo "cawk data_set removed $s (not a run_<audit> directory) ----"
	done
}

case "$cmd" in
init)
	purge_stray
	mkdir -p "$dir" || fail "cannot create $dir"
	;;
append)
	purge_stray
	check_keep
	summary="reports/run_$audit/assessment.all.summary.txt"
	[ -f "$summary" ] || fail "$summary does not exist (run: gmake check_run audit=$audit)"
	printf '%s' "$day" | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' || fail "invalid date <$day>"
	row=$(gawk -v d="$day" '
	BEGIN { stats = 1; out = d }
	/^---- security key indicators ----/ { stats = 0 }
	stats && /^[ \t]*number_of_[a-z_]+[ \t]*=/ {
		k = $1; sub(/^number_of_/, "", k)
		if (k in seen) next
		if ($3 !~ /^[0-9]+$/) { printf "cawk error: %s is not a number in the summary ----\n", $1 > "/dev/stderr"; bad = 1; exit 1 }
		seen[k] = 1; out = out ";" k "=" $3
	}
	/^nist_ref_coverage[ \t]*=/ && match($0, /\(([0-9]+) total, ([0-9]+) covered\)/, m) {
		seen["nist_ref_coverage"] = 1; out = out ";nist_ref_coverage=" m[2] "/" m[1]
	}
	/^nist_[a-z_]+[ \t]*=.*\([0-9]+\/[0-9]+\)[ \t]*$/ && $1 != "nist_ref_coverage" && !($1 in seen) {
		v = $0; sub(/^.*\(/, "", v); sub(/\)[ \t]*$/, "", v)
		seen[$1] = 1; out = out ";" $1 "=" v
	}
	END {
		if (bad) exit 1
		n = split("confs checks pass error warning psirt pass_high pass_medium pass_low pass_info error_high error_medium error_low error_info nist_ref_coverage", req, " ")
		for (i = 1; i <= n; i++) if (!(req[i] in seen)) { printf "cawk error: %s is missing in the summary ----\n", req[i] > "/dev/stderr"; exit 1 }
		print out
	}' "$summary") || fail "cannot read $summary"
	[ -n "$row" ] || fail "empty data_set line from $summary"
	mkdir -p "$dir" || fail "cannot create $dir"
	echo "$row" | write_file
	# rotation: the names sort by date, the oldest files beyond KEEP are dropped
	old=$(ls "$dir"/data_set_"$audit"_[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].txt | sort | gawk -v k="$keep" '{ a[NR] = $0 } END { for (i = 1; i <= NR - k; i++) print a[i] }') || fail "cannot list $dir"
	for o in $old; do rm -f "$o" || fail "cannot remove $o"; done
	echo "cawk data_set $audit done, $day added ($f) ----"
	;;
*)
	fail "unknown command <$cmd> (init, append)"
	;;
esac
