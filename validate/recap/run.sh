#!/bin/sh
#==============================================================================
# File        : run.sh
# Purpose     : Non-regression of the final recap of check_run (cawk_check_recap) and of VERBOSE
# Usage       : gmake check_validate   (or: sh validate/recap/run.sh, from the cawk root)
# Note        : a temporary audit is created and deleted ; the recap totals are compared with
#               assessment.all.csv and with the files of the audit
#==============================================================================

AUDIT=recaptest
SUPPLIER=cisco-ios

if [ ! -f Makefile ] || [ ! -d validate/recap ]; then
	echo "cawk error: run this script from the cawk root ----"
	exit 2
fi
if [ -d "reports/run_$AUDIT" ]; then
	echo "cawk error: audit $AUDIT already exists, delete it first ----"
	exit 2
fi

W=$(mktemp -d) || exit 2
pass=0
fail=0

cleanup() {
	gmake delete_audit audit=$AUDIT FORCE=yes > /dev/null 2>&1
	rm -rf "$W"
}
trap cleanup EXIT
trap 'exit 2' INT TERM

t() {
	desc="$1"; shift
	if "$@" > /dev/null 2>&1; then pass=$((pass+1)); echo "cawk recap case pass : $desc"
	else fail=$((fail+1)); echo "cawk recap case error : $desc"; fi
}

gmake create_audit audit=$AUDIT > /dev/null 2>&1 || { echo "cawk error: create_audit failed ----"; exit 2; }

# VERBOSE=no: the recap is the only informative output ; VERBOSE=yes (default): the phase lines too
gmake check_run audit=$AUDIT supplier=$SUPPLIER VERBOSE=no > "$W/quiet.log" 2>&1
t "check_run exits 0" test $? -eq 0
gmake check_run audit=$AUDIT supplier=$SUPPLIER VERBOSE=yes > "$W/verbose.log" 2>&1
t "check_run VERBOSE=yes exits 0" test $? -eq 0
gmake check_run audit=$AUDIT supplier=$SUPPLIER VERBOSE=no > "$W/quiet.log" 2>&1

t "VERBOSE=no: no compute line" test "$(grep -c '^cawk compute' "$W/quiet.log")" -eq 0
t "VERBOSE=yes: compute line" test "$(grep -c '^cawk compute' "$W/verbose.log")" -eq 1
t "VERBOSE=no: shorter than VERBOSE=yes" test "$(wc -l < "$W/quiet.log")" -lt "$(wc -l < "$W/verbose.log")"
t "recap header" grep -qx 'cawk recap check_run ----' "$W/quiet.log"
t "recap in VERBOSE=yes too" grep -qx 'cawk recap check_run ----' "$W/verbose.log"
t "done line kept" grep -qx 'cawk check_run done ----' "$W/quiet.log"

csv="reports/run_$AUDIT/assessment.all.csv"
total=$(sed -n 's/^cawk results       : error \([0-9]*\) | warning \([0-9]*\) | psirt \([0-9]*\) | pass \([0-9]*\)$/\1 \2 \3 \4/p' "$W/quiet.log" | awk '{ print $1 + $2 + $3 + $4 }')
t "results total = lines of assessment.all.csv" test "$total" = "$(wc -l < "$csv" | tr -d ' ')"
t "report path" grep -qx "cawk report        : $csv" "$W/quiet.log"

# 1 supplier, tests x confs counted on the files of the audit
nt=$(find "tests/run_$AUDIT/tests.$SUPPLIER" "tests/run_$AUDIT/tests.$SUPPLIER.psirt" -type f -name '*.gawk' 2>/dev/null | wc -l | tr -d ' ')
nc=$(find "confs/run_$AUDIT/confs.$SUPPLIER" -maxdepth 1 -type f | wc -l | tr -d ' ')
t "tests x confs line" grep -qx "cawk tests x confs : $nt tests, $nc confs, $((nt*nc)) executions" "$W/quiet.log"
t "suppliers line" grep -qx 'cawk suppliers     : 1' "$W/quiet.log"
t "execution err line" grep -qx 'cawk execution err : 0' "$W/quiet.log"

# STANDARD_ONLY / PSIRT_ONLY are honoured by the count
gmake check_run audit=$AUDIT supplier=$SUPPLIER STANDARD_ONLY=yes > "$W/std.log" 2>&1
nts=$(find "tests/run_$AUDIT/tests.$SUPPLIER" -type f -name '*.gawk' | wc -l | tr -d ' ')
t "STANDARD_ONLY counts the standard tests only" grep -qx "cawk tests x confs : $nts tests, $nc confs, $((nts*nc)) executions" "$W/std.log"

echo "cawk recap : $pass pass, $fail NOK ----"
[ "$fail" -eq 0 ]
