#!/bin/sh
# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------
#
# Explain why the last "gmake check_track" is NOK: which phases differ from
# checkdiff.old, with which command and exit status, which counted content changed
# against the reference of "gmake check_track_update", what changed in the environment,
# and where the run stopped if it did not reach the end.
#
# usage: explain_diff.sh   (from the cawk root directory)

TRACK_DIR="${CAWK_TRACK_DIR:-checkdiff/track}"
TRACE="$TRACK_DIR/trace"
REF="$TRACK_DIR/ref"
REPORT="$TRACE/report.txt"
TMP="$TRACE/.explain.$$"

[ -f checkdiff/checkdiff.new ] && [ -f checkdiff/checkdiff.old ] || { echo "cawk error: checkdiff.new or checkdiff.old missing, run gmake check_track first ----"; exit 1; }
[ -f "$TRACE/trace.tsv" ] || { echo "cawk error: $TRACE/trace.tsv missing, run gmake check_track first ----"; exit 1; }

trap 'rm -f "$TMP".*' EXIT

# trace.tsv columns: phase, counter value, snapshot sha256 (or -), command, exit status
{
echo "cawk check_track report ($(date '+%Y-%m-%d %H:%M:%S'))"
echo "------------------------------------------------------"

# last recipe line run: where the run stopped if it did not reach the end
if [ -f "$TRACE/last.txt" ]; then
	IFS='	' read -r lrc lcmd < "$TRACE/last.txt"
	echo "last recipe line run (rc=$lrc): $lcmd"
fi

# phases that differ, with the command and exit status recorded by the trace
gawk -F'\t' '
	FILENAME == ARGV[1] { cmd[$1] = $4; rc[$1] = $5; last = $1; next }
	FILENAME == ARGV[2] { new[FNR] = $0; newnb = FNR; next }
	{ old[FNR] = $0; if (FNR > oldnb) oldnb = FNR }
	END {
		nb = (newnb > oldnb ? newnb : oldnb)
		if (last > nb) nb = last
		if (last != newnb) printf "cawk warning: trace.tsv holds %d phases, checkdiff.new holds %d counters, the run stopped midway or the trace is incomplete ----\n", last, newnb
		ndiff = 0
		for (i = 1; i <= nb; i++)
			if (new[i] != old[i]) {
				ndiff++
				printf "phase %d: %s (checkdiff.old: %s) rc=%s\n    %s\n", i, new[i], old[i], (i in rc ? rc[i] : "-"), (i in cmd ? cmd[i] : "(no trace)")
			}
		if (ndiff == 0) print "no phase differs from checkdiff.old"
	}
' "$TRACE/trace.tsv" checkdiff/checkdiff.new checkdiff/checkdiff.old
echo "------------------------------------------------------"

# content of the counted phases changed against the reference
if [ -f "$REF/trace.tsv" ]; then
	# a phase whose command changed since the reference is misaligned: the reference is stale
	gawk -F'\t' '
		FILENAME == ARGV[1] { refcmd[$1] = $4; refhash[$1] = $3; refnb = $1; if (NF < 5) oldfmt = 1; next }
		{
			changed = ($3 != "-" && ($1 in refhash) && refhash[$1] != $3)
			if ($1 in refcmd && refcmd[$1] != $4) stale = stale (stale == "" ? "" : " ") $1
			else if (!($1 in refcmd)) newph = newph (newph == "" ? "" : " ") $1
			else if (changed) printf "%s\t%s\t%s\n", $1, $3, refhash[$1]
		}
		END {
			if (oldfmt) print "cawk warning: the reference trace.tsv has no rc column (outdated format), rerun gmake check_track_update ----"
			if (stale != "") print "cawk warning: reference stale, the recipe of phase " stale " changed since check_track_update, the phase numbers below may be misaligned, rerun gmake check_track_update ----"
			if (newph != "") print "cawk warning: phase " newph " have no reference, rerun gmake check_track_update ----"
		}
	' "$REF/trace.tsv" "$TRACE/trace.tsv" > "$TMP.changed"
	stale_warning=$(grep '^cawk warning:' "$TMP.changed")
	[ -n "$stale_warning" ] && { echo "$stale_warning"; echo "------------------------------------------------------"; }
	grep -v '^cawk warning:' "$TMP.changed" > "$TMP.pairs"
	if [ -s "$TMP.pairs" ]; then
		while IFS='	' read -r p cur refh; do
			echo "phase $p: counted content changed against the reference (< reference, > current)"
			gzip -dc "$REF/snap/$refh.gz" > "$TMP.ref" 2>/dev/null || { echo "cawk error: reference snapshot $REF/snap/$refh.gz missing ----"; continue; }
			gzip -dc "$TRACE/snap/$cur.gz" > "$TMP.cur"
			diff "$TMP.ref" "$TMP.cur" | head -n 40
		done < "$TMP.pairs"
	else
		echo "no counted phase differs from the reference"
	fi
	# phases counted since the reference only: no snapshot to diff yet
	gawk -F'\t' 'FILENAME == ARGV[1] { rh[$1] = $3; next } $3 != "-" && $1 in rh && rh[$1] == "-" { print $1 }' "$REF/trace.tsv" "$TRACE/trace.tsv" | while read -r p; do
		echo "phase $p: no reference snapshot (counted content is new), rerun gmake check_track_update to track it ----"
	done
else
	echo "no reference in $REF: run gmake check_track_update on a known good run to get the changed lines"
fi
echo "------------------------------------------------------"

# second criterion of the check: the sha512 image of checkdiff.new
newsha=$(sha512sum checkdiff/checkdiff.new 2>/dev/null | cut -d' ' -f1)
oldsha=$(cut -d' ' -f1 checkdiff/cawk-crypto-image.old 2>/dev/null)
if [ -n "$oldsha" ] && [ "$newsha" != "$oldsha" ]; then
	if diff checkdiff/checkdiff.new checkdiff/checkdiff.old >/dev/null; then
		echo "cawk crypto image differs while every counter matches: byte-level difference in checkdiff.new (trailing newline, line endings) ----"
	else
		echo "cawk crypto image differs ----"
	fi
fi

# known causes
if [ -f "$REF/env.txt" ]; then
	echo "environment changes against the reference:"
	diff "$REF/env.txt" "$TRACE/env.txt" | grep '^[<>]' | grep -v '^[<>] date:'
fi
gawk '/^  validate\/test-sync\/source\// && $2 > 30 { print "known cause: fixture " $1 " is " $2 " days old (cawk_deadbeef_internal_test reports configurations older than 30 days)" }' "$TRACE/env.txt"
} 2>&1 | tee "$REPORT"
