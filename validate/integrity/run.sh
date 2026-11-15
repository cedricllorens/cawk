#!/bin/sh
#==============================================================================
# File        : run.sh
# Purpose     : Non-regression of the integrity control run first by check_repo and check_run
#               (check_integrity: errors are shown as cawk error: without exit 1, the assessment goes on)
# Usage       : gmake check_validate   (or: sh validate/integrity/run.sh, from the cawk root)
# Note        : DEPRECATED_FILES is overridden with an existing file, nothing is created nor removed
#==============================================================================

if [ ! -f Makefile ] || [ ! -d validate/integrity ]; then
	echo "cawk error: run this script from the cawk root ----"
	exit 2
fi

W=$(mktemp -d) || exit 2
pass=0
fail=0
trap 'rm -rf "$W"' EXIT
trap 'exit 2' INT TERM

t() {
	desc="$1"; shift
	if "$@" > /dev/null 2>&1; then pass=$((pass+1)); echo "cawk integrity case pass : $desc"
	else fail=$((fail+1)); echo "cawk integrity case error : $desc"; fi
}

OBS="DEPRECATED_FILES=Makefile:common/new_makefile"
gmake check_integrity > "$W/ok.log" 2>&1; rc_ok=$?
t "no obsolete file: exit 0" test "$rc_ok" -eq 0
t "no obsolete file: trace" grep -qx 'cawk integrity check done: no obsolete file ----' "$W/ok.log"

gmake check_integrity "$OBS" > "$W/ko.log" 2>&1; rc_ko=$?
t "obsolete file: error shown, no exit 1" test "$rc_ko" -eq 0
t "obsolete file: message with the action" grep -qx 'cawk error: obsolete file Makefile detected (now common/new_makefile), remove it: rm Makefile ----' "$W/ko.log"

gmake check_repo "$OBS" > "$W/repo.log" 2>&1; rc_repo=$?
t "check_repo goes on: error shown, computation runs" test "$(grep -c '^cawk compute' "$W/repo.log")" -ne 0
t "check_repo: error shown" grep -q 'cawk error: obsolete file Makefile detected' "$W/repo.log"
t "check_repo: not stopped by integrity" test "$(grep -c 'check_integrity' "$W/repo.log")" -eq 0
t "check_repo: integrity error written to logs/repo/integrity.repo.err" grep -q '^obsolete file Makefile detected (now common/new_makefile), remove it: rm Makefile ----$' logs/repo/integrity.repo.err
t "check_repo: integrity error scanned at the end" grep -q '^cawk error: obsolete file Makefile detected.*----$' "$W/repo.log"
t "check_repo: no staging file left" test -z "$(ls logs/phase_err 2>/dev/null)"

[ -d "reports/run_integrtest" ] && { echo "cawk error: audit integrtest already exists, delete it first ----"; exit 2; }
trap 'gmake delete_audit audit=integrtest FORCE=yes > /dev/null 2>&1; rm -rf "$W"' EXIT
gmake create_audit audit=integrtest > /dev/null 2>&1
gmake check_run audit=integrtest "$OBS" > "$W/run.log" 2>&1; rc_run=$?
t "check_run goes on: error shown" grep -q 'cawk error: obsolete file Makefile detected' "$W/run.log"
t "check_run goes on: computation runs" test "$(grep -c '^cawk compute' "$W/run.log")" -ne 0
t "check_run: integrity error written to logs/run_integrtest/integrity.integrtest.err" grep -q '^obsolete file Makefile detected' logs/run_integrtest/integrity.integrtest.err
gmake check_repo > "$W/repo_ok.log" 2>&1
t "check_repo without error: no integrity log" test ! -e logs/repo/integrity.repo.err

# working copy of the NIST reference (database/db_nist800-53.txt): saved and put back at the end
N=database/db_nist800-53.txt; S=common/database/db_nist800-53.txt
cp -p "$N" "$W/nist.keep"; [ -f "$N.orig" ] && cp -p "$N.orig" "$W/nist.orig.keep"
trap 'cp -p "$W/nist.keep" "$N"; rm -f "$N.orig"; [ -f "$W/nist.orig.keep" ] && cp -p "$W/nist.orig.keep" "$N.orig"; gmake delete_audit audit=integrtest FORCE=yes > /dev/null 2>&1; rm -rf "$W"' EXIT
rm -f "$N.orig"
printf '\nadded by the user\n' >> "$N"; touch "$N"
gmake check_integrity > "$W/n1.log" 2>&1
t "NIST copy newer than the shipped one: kept" grep -q '^added by the user$' "$N"
t "NIST copy newer: no update trace" test "$(grep -c 'updated from' "$W/n1.log")" -eq 0
touch -d '2000-01-01' "$N"
gmake check_integrity > "$W/n2.log" 2>&1
t "NIST copy older: replaced by the shipped one" cmp -s "$N" "$S"
t "NIST copy older: .orig keeps the previous copy" grep -q '^added by the user$' "$N.orig"
t "NIST copy older: update trace" grep -q 'cawk database/db_nist800-53.txt updated from common/database/db_nist800-53.txt' "$W/n2.log"
rm -f "$N" "$N.orig"
gmake check_integrity > "$W/n3.log" 2>&1
t "NIST copy missing: created from the shipped one" cmp -s "$N" "$S"
t "NIST copy missing: no .orig" test ! -f "$N.orig"
gmake clean > /dev/null 2>&1
printf '\nadded again\n' >> "$N"; touch "$N"
gmake check_integrity > /dev/null 2>&1
t "clean does not touch the shipped NIST file (the copy stays)" grep -q '^added again$' "$N"

# censor rules of the installation: the include of the core rules shipped by cawk is mandatory
C=database/censor/censor_regex.m4; T=common/censor/censor_regex.m4
cp -p "$C" "$W/censor.keep"; [ -f "$C.orig" ] && cp -p "$C.orig" "$W/censor.orig.keep"
trap 'cp -p "$W/censor.keep" "$C"; rm -f "$C.orig"; [ -f "$W/censor.orig.keep" ] && cp -p "$W/censor.orig.keep" "$C.orig"; cp -p "$W/nist.keep" "$N"; rm -f "$N.orig"; [ -f "$W/nist.orig.keep" ] && cp -p "$W/nist.orig.keep" "$N.orig"; gmake delete_audit audit=integrtest FORCE=yes > /dev/null 2>&1; rm -rf "$W"' EXIT
rm -f "$C.orig"
printf 'censor_match(`MYSECRET-[0-9]+\x27)\n' | sed "s/\\x27/'/" > "$W/mine.rule"
{ grep -v '^include(' "$T"; cat "$W/mine.rule"; } > "$C"
gmake check_integrity > "$W/c1.log" 2>&1; rc_c1=$?
t "censor file without include: replaced by the template" cmp -s "$C" "$T"
t "censor file without include: previous file saved in .orig with the user rule" grep -q 'MYSECRET' "$C.orig"
t "censor file without include: check_integrity reports without exit 1" test "$rc_c1" -eq 0
t "censor file without include: explicit message" grep -q 'cawk error: database/censor/censor_regex.m4.orig holds the previous censor rules' "$W/c1.log"
gmake check_integrity > "$W/c2.log" 2>&1; rc_c2=$?
t "censor .orig still there: error kept, no exit 1" test "$rc_c2" -eq 0
cp "$C.orig" "$W/orig.copy"; rm -f "$C.orig"
t "censor .orig destroyed: check_integrity passes" gmake check_integrity
printf 'previous\n' > "$C.orig"; grep -v '^include(' "$T" > "$C"
gmake check_integrity > "$W/c3.log" 2>&1
t "censor file without include and .orig existing: nothing overwritten" grep -qx 'previous' "$C.orig"
t "censor file without include and .orig existing: explicit message" grep -q 'already exists' "$W/c3.log"
rm -f "$C.orig"; cp -p "$W/censor.keep" "$C"
t "censor file with the core include: check_integrity passes" gmake check_integrity

# the censor_* targets run the same control first: the error is shown (exit 1 only with INTEGRITY_FATAL=yes)
grep -v '^include(' "$T" > "$C"
gmake censor_stdout in=Makefile > "$W/c4.log" 2>&1; rc_c4=$?
t "censor_stdout with a censor file without include: error shown, no exit 1" test "$rc_c4" -eq 0
t "censor_stdout with a censor file without include: explicit message" grep -q 'cawk error: database/censor/censor_regex.m4.orig holds the previous censor rules' "$W/c4.log"
rm -f "$C.orig"; cp -p "$W/censor.keep" "$C"
t "censor_stdout with the core include: runs" gmake censor_stdout in=Makefile

# phases run before the logs of the context exist: the error is staged in logs/phase_err, then moved into the logs of the context
gmake check_integrity > /dev/null 2>&1
gmake catalog_build_run audit=nophaseaudit > "$W/p1.log" 2>&1
gmake exceptions_build_run audit=nophaseaudit > "$W/p2.log" 2>&1
t "catalog_dir: error shown" grep -q 'cawk error: tests/run_nophaseaudit directory does not exist ----' "$W/p1.log"
t "catalog_dir: error staged" grep -qx 'tests/run_nophaseaudit directory does not exist ----' logs/phase_err/catalog_dir.err
t "exceptions_dir: error staged" grep -qx 'exceptions/run_nophaseaudit directory does not exist ----' logs/phase_err/exceptions_dir.err
gmake check_integrity > /dev/null 2>&1
t "check_integrity resets the staging" test -z "$(ls logs/phase_err 2>/dev/null)"
gmake catalog_build_run audit=nophaseaudit > /dev/null 2>&1
gmake check_run audit=integrtest > "$W/p3.log" 2>&1
t "check_run: staged error of a previous phase is not carried into the context logs" test ! -e logs/run_integrtest/catalog_dir.integrtest.err

echo "cawk integrity cases : $pass pass, $fail error ----"
[ "$fail" -eq 0 ]
