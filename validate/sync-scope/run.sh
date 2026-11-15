#!/bin/sh
#==============================================================================
# File        : run.sh
# Purpose     : Non-regression of the default sync scope created with an audit
#               (database/sync_scopes/<audit>_inventory_sync_scope.txt, db_sync.txt field 4)
# Usage       : gmake check_validate   (or: sh validate/sync-scope/run.sh, from the cawk root)
# Note        : a temporary audit is created and deleted ; db_sync.txt is verified unchanged at the end
#==============================================================================

AUDIT=scopetest
SCOPE="database/sync_scopes/${AUDIT}_inventory_sync_scope.txt"

if [ ! -f Makefile ] || [ ! -d validate/sync-scope ]; then
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
[ -f database/db_sync.txt ] && cp -p database/db_sync.txt "$W/db_sync.before"

cleanup() {
	gmake delete_audit audit=$AUDIT FORCE=yes > /dev/null 2>&1
	rm -f "$SCOPE"
	if [ -f "$W/db_sync.before" ]; then cp -p "$W/db_sync.before" database/db_sync.txt; fi
	rm -rf "$W"
}
trap cleanup EXIT
trap 'exit 2' INT TERM

t() {
	desc="$1"; shift
	if "$@" > /dev/null 2>&1; then pass=$((pass+1)); echo "cawk sync-scope case pass : $desc"
	else fail=$((fail+1)); echo "cawk sync-scope case error : $desc"; fi
}
tn() {
	desc="$1"; shift
	if "$@" > /dev/null 2>&1; then fail=$((fail+1)); echo "cawk sync-scope case error : $desc"
	else pass=$((pass+1)); echo "cawk sync-scope case pass : $desc"; fi
}

# two fake confs of the same supplier
mkdir "$W/confs" && cp confs/repo/confs.cisco-ios/conf_0 "$W/confs/r1" && cp "$W/confs/r1" "$W/confs/r2" || exit 2

nlinks() { find "confs/run_$AUDIT" -type l 2>/dev/null | wc -l | tr -d ' '; }
setdir() {
	gmake database_sync_update audit=$AUDIT dir="$W/confs/" regexinventory='.*' scope="$1" regexos='.*' regexpathexclude=none regexinventoryexclude=none > /dev/null 2>&1
}

gmake create_audit audit=$AUDIT > /dev/null 2>&1 || { echo "cawk error: create_audit failed ----"; exit 2; }

t "create_audit: db_sync.txt scope is the default file" grep -q "^$AUDIT .* $SCOPE .*" database/db_sync.txt
t "create_audit: default scope file created" test -f "$SCOPE"
t "create_audit: default scope file is empty" test ! -s "$SCOPE"
t "check_database accepts a named audit (db_info.txt, db_exception.txt) and the default scope entry" gmake check_database

setdir "$SCOPE"
gmake sync_run audit=$AUDIT > "$W/s1.log" 2>&1
t "empty default scope: no filter, both confs synced" test "$(nlinks)" = 2

echo "# comment" > "$SCOPE"; echo "" >> "$SCOPE"; echo "r1" >> "$SCOPE"
gmake sync_run audit=$AUDIT > "$W/s2.log" 2>&1
t "scope with one device: only that conf synced" test "$(nlinks)" = 1

echo "/some/path/r2" > "$SCOPE"
gmake sync_run audit=$AUDIT > "$W/s3.log" 2>&1
t "scope with a path: the device name is the base name" test "$(nlinks)" = 1

rm -f "$SCOPE"
gmake sync_run audit=$AUDIT > "$W/s4.log" 2>&1
tn "missing scope file: sync_run fails" test $? -eq 0
t "missing scope file: explicit message" grep -q "scope file .* not found" "logs/run_$AUDIT/sync_cawk_conf.$AUDIT.err"

setdir none
gmake sync_run audit=$AUDIT > "$W/s5.log" 2>&1
t "scope=none: no filter" test "$(nlinks)" = 2

: > "$SCOPE"
gmake delete_audit audit=$AUDIT FORCE=yes > /dev/null 2>&1
tn "delete_audit removes the default scope file" test -e "$SCOPE"

echo "cawk sync-scope : $pass pass, $fail NOK ----"
[ "$fail" -eq 0 ]
