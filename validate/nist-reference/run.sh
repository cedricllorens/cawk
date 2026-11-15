#!/bin/sh
#==============================================================================
# File        : run.sh
# Purpose     : Non-regression of the working copy of the shipped NIST reference
#               (common/database/db_nist800-53.txt -> database/db_nist800-53.txt, rule $(NIST_REFERENCE)):
#               every target that reads it has it as prerequisite, and a missing or older copy is replaced
# Usage       : gmake check_validate   (or: sh validate/nist-reference/run.sh, from the cawk root)
# Note        : database/db_nist800-53.txt and its .orig are saved and put back at the end, no audit is created
#==============================================================================

SRC=common/database/db_nist800-53.txt
DST=database/db_nist800-53.txt

if [ ! -f Makefile ] || [ ! -d validate/nist-reference ]; then
	echo "cawk error: run this script from the cawk root ----"
	exit 2
fi
if [ ! -f "$SRC" ]; then
	echo "cawk error: $SRC is missing ----"
	exit 2
fi

W=$(mktemp -d) || exit 2
pass=0
fail=0
[ -f "$DST" ] && cp -p "$DST" "$W/dst.before"
[ -f "$DST.orig" ] && cp -p "$DST.orig" "$W/orig.before"

cleanup() {
	if [ -f "$W/dst.before" ]; then cp -p "$W/dst.before" "$DST"; else rm -f "$DST"; fi
	if [ -f "$W/orig.before" ]; then cp -p "$W/orig.before" "$DST.orig"; else rm -f "$DST.orig"; fi
	rm -rf "$W"
}
trap cleanup EXIT
trap 'exit 2' INT TERM

t() {
	desc="$1"; shift
	if "$@" > /dev/null 2>&1; then pass=$((pass+1)); echo "cawk nist-reference case pass : $desc"
	else fail=$((fail+1)); echo "cawk nist-reference case error : $desc"; fi
}

# a target must run the copy rule when the shipped source is newer (dry run, nothing executed)
has_copy_rule() {
	gmake -n -W "$SRC" "$@" 2> /dev/null | grep -q "^cp -p \"$SRC\" \"$DST\""
}

for target in check_database check_integrity catalog_build catalog_build_repo catalog_build_run nist_coverage_official check_repo check_run; do
	t "$target has the copy rule as prerequisite" has_copy_rule "$target"
done
t "catalog_build_audit has the copy rule as prerequisite" has_copy_rule catalog_build_audit audit=nistrefaudit

# the shipped source is the reference: a missing, a modified and an older copy are all replaced
rm -f "$DST"
gmake check_database > "$W/missing.log" 2>&1
t "missing copy: check_database recreates it identical to the source" cmp -s "$SRC" "$DST"
t "missing copy: update shown" grep -q "^cawk $DST updated from $SRC" "$W/missing.log"

echo "cawk nist-reference stale copy ----" >> "$DST"
touch -d '2000-01-01 00:00:00' "$DST"
gmake catalog_build_repo > "$W/stale.log" 2>&1
t "older copy: catalog_build_repo replaces it by the source" cmp -s "$SRC" "$DST"
t "older copy: no invalid nist800-53 id reported" test "$(grep -c 'invalid nist800-53 id' "$W/stale.log")" -eq 0

touch -d '2000-01-01 00:00:00' "$DST"
gmake check_integrity > /dev/null 2>&1
t "older copy: check_integrity replaces it by the source" cmp -s "$SRC" "$DST"

gmake check_database > "$W/uptodate.log" 2>&1
t "up to date copy: not copied again" test "$(grep -c "^cawk $DST updated" "$W/uptodate.log")" -eq 0

echo "cawk nist-reference cases : $pass pass, $fail error ----"
[ "$fail" -eq 0 ]
