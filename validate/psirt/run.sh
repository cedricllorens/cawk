#!/bin/sh
# ---------------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# non-regression of the psirt engine (common/test_generic_psirt.gawk.template)
# each directory of validate/psirt holds one case :
#   rule.include   the USER section of a psirt test (load_psirt_config)
#   inventory.txt  psirt_os_inventory_scope.txt of the case (optional)
#   c_* x_*        the configurations given to the engine
#   expected.txt   the expected engine output
#
# usage: validate/psirt/run.sh [record]
#   record : rewrite every expected.txt from the current engine
# ---------------------------------------------------------------------

cd "$(dirname "$0")/../.." || exit 1
root=$(pwd)
tpl=${PSIRT_TPL:-common/test_generic_psirt.gawk.template}
tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT

# print_err() of common.gawk without its dependencies
cat > "$tmp/common_stub.gawk" <<'STUB'
function print_err(test_name, test_msg, linenu, test_risk, test_status) {
	print FILENAME ";" test_name ";" test_msg ";" linenu ";" test_risk ";" test_status
}
STUB

mode="$1"
ko=0
for dir in validate/psirt/*/; do
	name=$(basename "$dir")
	work="$tmp/$name"
	mkdir -p "$work/database/psirt_scopes"
	cp "$dir"c_* "$dir"x_* "$work"/ 2>/dev/null
	[ -f "$dir/inventory.txt" ] && cp "$dir/inventory.txt" "$work/database/psirt_scopes/psirt_os_inventory_scope.txt"
	sed -e "s|%SED_INCLUDE_PATH%|\"$tmp/common_stub.gawk\"|" \
	    -e "s|CAWK_PSIRT_NAME|$root/${dir}rule.include|g" \
	    -e 's|CAWK_PSIRT_TESTNAME|t|g' -e 's|CAWK_PSIRT_OS|os|g' "$tpl" > "$work/engine.gawk"
	# only the files that exist : an unmatched glob would be passed literally
	(cd "$work" && set -- && for f in c_* x_*; do [ -e "$f" ] && set -- "$@" "$f"; done; gawk -f engine.gawk "$@" 2>&1) > "$work/actual.txt"
	if [ "$mode" = "record" ]; then
		cp "$work/actual.txt" "${dir}expected.txt"
		echo "recorded $name"
	elif diff "${dir}expected.txt" "$work/actual.txt" > "$work/diff.txt"; then
		echo "cawk psirt case pass : $name"
	else
		echo "cawk psirt case error : $name"
		sed 's/^/    /' "$work/diff.txt"
		ko=1
	fi
done
exit $ko
