#!/bin/sh
#==============================================================================
# File        : run.sh
# Purpose     : Non-regression of the consistency between assessment.all.summary.txt and assessment.all.summary.html
# Usage       : gmake check_validate   (or: sh validate/summary-html/run.sh, from the cawk root)
# Note        : a temporary audit is created and deleted ; the counters embedded in the html (stats, recs, excs)
#               are compared with number_of_* of the summary.txt
#==============================================================================

AUDIT=sumhtmltest
SUPPLIER=cisco-ios

if [ ! -f Makefile ] || [ ! -d validate/summary-html ]; then
	echo "cawk error: run this script from the cawk root ----"
	exit 2
fi
if [ -d "reports/run_$AUDIT" ]; then
	echo "cawk error: audit $AUDIT already exists, delete it first ----"
	exit 2
fi

pass=0
fail=0

cleanup() {
	gmake delete_audit audit=$AUDIT FORCE=yes > /dev/null 2>&1
}
trap cleanup EXIT
trap 'exit 2' INT TERM

t() {
	desc="$1"; shift
	if "$@" > /dev/null 2>&1; then pass=$((pass+1)); echo "cawk summary-html case pass : $desc"
	else fail=$((fail+1)); echo "cawk summary-html case error : $desc"; fi
}

gmake create_audit audit=$AUDIT > /dev/null 2>&1 || { echo "cawk error: create_audit failed ----"; exit 2; }
gmake check_run audit=$AUDIT supplier=$SUPPLIER HTML=yes DATA_SET=no VERBOSE=no > /dev/null 2>&1
t "check_run exits 0" test $? -eq 0

dir="reports/run_$AUDIT"
txt="$dir/assessment.all.summary.txt"
html="$dir/assessment.all.summary.html"
[ -f "$txt" ] && [ -f "$html" ] || { echo "cawk error: $txt or $html missing ----"; exit 1; }

# every number_of_* of the txt must be in the html stats with the same value
bad=$(gawk '
	FNR == NR && /^[ \t]*number_of_[a-z_]+[ \t]*=[ \t]*[0-9]+/ {
		k = $1; sub(/^number_of_/, "", k); v = $3; sub(/[^0-9].*/, "", v)
		if (!(k in tv)) tv[k] = v
		next
	}
	FNR != NR && /^"stats":\{/ {
		s = $0; sub(/^"stats":\{/, "", s); sub(/\}.*$/, "", s)
		n = split(s, a, ",")
		for (i = 1; i <= n; i++) { split(a[i], kv, ":"); gsub(/"/, "", kv[1]); hv[kv[1]] = kv[2] }
	}
	END {
		for (k in tv) if (!(k in hv) || hv[k] != tv[k]) print k " txt=" tv[k] " html=" (k in hv ? hv[k] : "missing")
		for (k in hv) if (!(k in tv)) print k " html only"
	}' "$txt" "$html")
t "every number_of_* of the txt is in the html stats with the same value" test -z "$bad"
[ -z "$bad" ] || echo "$bad"

# statuses of the recs and exceptions of the html against the txt
cmp=$(gawk '
	FNR == NR && /^[ \t]*number_of_[a-z_]+[ \t]*=[ \t]*[0-9]+/ {
		k = $1; sub(/^number_of_/, "", k); v = $3; sub(/[^0-9].*/, "", v)
		if (!(k in tv)) tv[k] = v
		next
	}
	FNR != NR && /^\[[0-9]+,"[a-z]+","[a-z]+",[0-9]+,[0-9]+\]+,?$/ {
		split($0, f, ","); sv = f[3]; gsub(/"/, "", sv); rv = f[2]; gsub(/"/, "", rv)
		n[sv] += f[4]; nr[sv "_" rv] += f[4]
	}
	FNR != NR && /^\[[0-9]+,"[a-z]+","[a-z]+",[0-9]+\]+,?$/ { split($0, f, ","); e += f[4]; sub(/\].*/, "", f[4]) }
	END {
		for (s in n) if (s != "clear" && n[s] != tv[s]) print "status " s " recs=" n[s] " txt=" tv[s]
		if (n["clear"] != tv["psirt_clear"]) print "psirt_clear recs=" n["clear"] " txt=" tv["psirt_clear"]
		if (n["psirt"] + 0 != tv["psirt"]) print "psirt recs=" n["psirt"] + 0 " txt=" tv["psirt"]
		tot = n["pass"] + n["error"] + n["warning"] + n["psirt"] + n["clear"] + e
		if (tot != tv["checks"]) print "checks recs+exceptions=" tot " txt=" tv["checks"]
		split("pass error warning", st, " "); split("high medium low info", rk, " ")
		for (i = 1; i <= 3; i++) for (j = 1; j <= 4; j++) if (nr[st[i] "_" rk[j]] + 0 != tv[st[i] "_" rk[j]]) print st[i] "_" rk[j] " recs=" nr[st[i] "_" rk[j]] + 0 " txt=" tv[st[i] "_" rk[j]]
	}' "$txt" "$html")
t "recs and exceptions of the html give the counters of the txt (status, risk, checks, psirt_clear)" test -z "$cmp"
[ -z "$cmp" ] || echo "$cmp"

# no status psirt below high risk in the html recs (the clear status is set by report_html.gawk)
t "no psirt status below high risk in the html recs" test "$(grep -cE '^\[[0-9]+,"(medium|low|info)","psirt",' "$html")" -eq 0

echo "cawk summary-html cases: $pass pass, $fail error ----"
[ "$fail" -eq 0 ]
