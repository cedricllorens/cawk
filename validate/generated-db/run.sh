#!/bin/sh
#==============================================================================
# File        : run.sh
# Purpose     : Non-regression of the generated databases read by the reports and catalogs
#               (database/db_info.txt, database/db_exception.txt): every target reading one has its rule as
#               prerequisite, so a missing file is rebuilt (catalog_build, exceptions_build), also with CATALOG_BUILD=no
# Usage       : gmake check_validate   (or: sh validate/generated-db/run.sh, from the cawk root)
# Note        : both files and db_nist_mappings.json are saved and put back at the end, no audit is created
#==============================================================================

INFO=database/db_info.txt
EXC=database/db_exception.txt
MAP=database/db_nist_mappings.json

if [ ! -f Makefile ] || [ ! -d validate/generated-db ]; then
	echo "cawk error: run this script from the cawk root ----"
	exit 2
fi

W=$(mktemp -d) || exit 2
pass=0
fail=0
for f in "$INFO" "$EXC" "$MAP"; do
	b=$(basename "$f")
	if [ -f "$f" ]; then cp -p "$f" "$W/$b.before" || exit 2; fi
done

cleanup() {
	for f in "$INFO" "$EXC" "$MAP"; do
		b=$(basename "$f")
		if [ -f "$W/$b.before" ]; then cp -p "$W/$b.before" "$f"; else rm -f "$f"; fi
	done
	rm -rf "$W"
}
trap cleanup EXIT
trap 'exit 2' INT TERM

t() {
	desc="$1"; shift
	if "$@" > /dev/null 2>&1; then pass=$((pass+1)); echo "cawk generated-db case pass : $desc"
	else fail=$((fail+1)); echo "cawk generated-db case error : $desc"; fi
}

# dry run: count the rebuild commands planned for a target
plans() { gmake -n "$@" 2> /dev/null | grep -c "^gmake $REBUILD$"; }
rebuilds() { [ "$(plans "$@")" -ge 1 ]; }
no_rebuild() { [ "$(plans "$@")" -eq 0 ]; }

REBUILD=catalog_build
rm -f "$INFO"
for target in "check_repo CATALOG_BUILD=no" "check_run CATALOG_BUILD=no" catalog_nist_mappings nist_coverage_official nist_coverage_repo nist_coverage_run catalog_repo catalog_run; do
	# shellcheck disable=SC2086
	t "missing $INFO: $target rebuilds it" rebuilds $target
done
[ -f "$W/db_info.txt.before" ] && cp -p "$W/db_info.txt.before" "$INFO"
for target in "check_repo CATALOG_BUILD=no" catalog_nist_mappings catalog_repo; do
	# shellcheck disable=SC2086
	t "present $INFO: $target does not rebuild it" no_rebuild $target
done

REBUILD=exceptions_build
rm -f "$EXC"
for target in catalog_exceptions_repo catalog_exceptions_run; do
	t "missing $EXC: $target rebuilds it" rebuilds "$target"
done
[ -f "$W/db_exception.txt.before" ] && cp -p "$W/db_exception.txt.before" "$EXC"
t "present $EXC: catalog_exceptions_repo does not rebuild it" no_rebuild catalog_exceptions_repo

# real run: a missing file is recreated by the rule, not empty
rm -f "$INFO"
gmake catalog_nist_mappings > "$W/real.log" 2>&1
t "missing $INFO: catalog_nist_mappings recreates it, not empty" test -s "$INFO"
rm -f "$EXC"
gmake catalog_exceptions_repo > "$W/real_exc.log" 2>&1
t "missing $EXC: catalog_exceptions_repo recreates it" test -f "$EXC"

echo "cawk generated-db: $pass pass, $fail error ----"
[ "$fail" -eq 0 ] || exit 1
