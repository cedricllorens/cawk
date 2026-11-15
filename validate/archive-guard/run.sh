#!/bin/sh
#==============================================================================
# File        : run.sh
# Purpose     : Non-regression of the archive protection (clean_archive_* age rule, ALL_ARCHIVE, check_archive_guard)
# Usage       : gmake check_validate   (or: sh validate/archive-guard/run.sh, from the cawk root)
# Note        : a temporary audit is created and deleted, no real assessment is run
#==============================================================================

AUDIT=archguardtest
A="reports/run_${AUDIT}/archives"

if [ ! -f Makefile ] || [ ! -d validate/archive-guard ]; then
	echo "cawk error: run this script from the cawk root ----"
	exit 2
fi
if [ -d "reports/run_$AUDIT" ]; then
	echo "cawk error: audit $AUDIT already exists, delete it first ----"
	exit 2
fi
# archives left by another suite (check removes them at its end): the guard refuses anyway, only its "no archive" case is skipped
foreign=0
for d in reports/*/archives; do
	[ -d "$d" ] || continue
	[ -z "$(find "$d" -type f ! -name '.*' | head -n 1)" ] || foreign=1
done

pass=0
fail=0

cleanup() {
	gmake delete_audit audit=$AUDIT FORCE=yes > /dev/null 2>&1
}
trap cleanup EXIT
trap 'exit 2' INT TERM

t() {
	desc="$1"; shift
	if "$@" > /dev/null 2>&1; then pass=$((pass+1)); echo "cawk archive-guard case pass : $desc"
	else fail=$((fail+1)); echo "cawk archive-guard case FAIL : $desc"; fi
}

refused() { ! "$@"; }
exists() { [ -f "$1" ]; }
missing() { [ ! -e "$1" ]; }

gmake create_audit audit=$AUDIT > /dev/null 2>&1 || { echo "cawk error: create_audit $AUDIT failed ----"; exit 2; }
mkdir -p "$A"
new="$A/run_${AUDIT}_new.tar.gz"
old="$A/run_${AUDIT}_old.tar.gz"
fill() { touch "$new" "$old" && touch -d '200 days ago' "$old"; }

fill
t "default purge keeps the recent archive" gmake clean_archive_run audit=$AUDIT
t "default purge keeps the recent archive (file)" exists "$new"
t "default purge removes the old archive" missing "$old"

fill
t "ARCHIVE_OLDER_DAYS empty is refused" refused gmake clean_archive_run audit=$AUDIT ARCHIVE_OLDER_DAYS=
t "ARCHIVE_OLDER_DAYS=abc is refused" refused gmake clean_archive_run audit=$AUDIT ARCHIVE_OLDER_DAYS=abc
t "ARCHIVE_OLDER_DAYS=10 without FORCE is refused" refused gmake clean_archive_run audit=$AUDIT ARCHIVE_OLDER_DAYS=10
t "nothing removed after the refusals (old)" exists "$old"
t "nothing removed after the refusals (new)" exists "$new"
t "ALL_ARCHIVE=yes without FORCE is refused" refused gmake clean_archive_run audit=$AUDIT ALL_ARCHIVE=yes
t "nothing removed after ALL_ARCHIVE without FORCE" exists "$new"

t "ARCHIVE_OLDER_DAYS=10 FORCE=yes is accepted" gmake clean_archive_run audit=$AUDIT ARCHIVE_OLDER_DAYS=10 FORCE=yes
t "ARCHIVE_OLDER_DAYS=10 FORCE=yes keeps the recent archive" exists "$new"

fill
t "ALL_ARCHIVE=yes FORCE=yes is accepted" gmake clean_archive_run audit=$AUDIT ALL_ARCHIVE=yes FORCE=yes
t "ALL_ARCHIVE=yes FORCE=yes removes the recent archive" missing "$new"
t "ALL_ARCHIVE=yes FORCE=yes removes the old archive" missing "$old"

fill
t "clean_force without ALL_ARCHIVE keeps the recent archive" gmake clean_archive_run_audit
t "clean_archive_run_audit keeps the recent archive" exists "$new"

t "check refused when the run contexts hold archives" refused gmake check_archive_guard
t "check_archive_guard has no bypass" refused gmake check_archive_guard CHECK_ALLOW_DATA=yes FORCE=yes
rm -f "$new" "$old"
[ "$foreign" -eq 1 ] || t "check_archive_guard passes without archive" gmake check_archive_guard

echo "cawk archive-guard: $pass passed, $fail failed ----"
[ "$fail" -eq 0 ]
