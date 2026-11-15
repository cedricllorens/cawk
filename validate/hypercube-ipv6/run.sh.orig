#!/bin/sh
# ---------------------------------------------------------------------
# cawk is subject to an MIT open-source licence
# please refer to the MIT licence file for further information
# ---------------------------------------------------------------------
#
# non-regression of common/common_hypercube-lib.gawk (the rules cube of every
# acl_configconsistency_set test) on its ipv4 verdicts and its ipv6 support
# each directory of validate/hypercube-ipv6 holds one case :
#   rules.gawk   calls to cawk_add_hypercube_rules() inside BEGIN
#   expected.txt the expected output (stubbed print_err lines then the verdict line)
#
# usage : validate/hypercube-ipv6/run.sh [record]
#   record : rewrite every expected.txt from the current cube
# ---------------------------------------------------------------------

cd "$(dirname "$0")/../.." || exit 1

[ -x common/common_hypercube-lib.gawk ] || gmake tests_target_common > /dev/null 2>&1

tmp=$(mktemp -d) || exit 1
trap 'rm -rf "$tmp"' EXIT

# print_err() of common.gawk without its dependencies
cat > "$tmp/common_stub.gawk" <<'STUB'
function print_err(test_name, test_msg, linenu, test_risk, test_status) {
	print test_name ";" test_msg ";" linenu ";" test_risk ";" test_status
}
STUB

mode="$1"
ko=0
n=0
for dir in validate/hypercube-ipv6/*/; do
	name=$(basename "$dir")
	HYPERCUBE_INCONSISTENCY=yes HYPERCUBE_REDUNDANCY=yes gawk -f "$tmp/common_stub.gawk" -f common/common_hypercube-lib.gawk -f "${dir}rules.gawk" /dev/null > "$tmp/actual.txt" 2>&1
	if [ "$mode" = "record" ]; then
		cp "$tmp/actual.txt" "${dir}expected.txt"
		echo "recorded $name"
	elif diff "${dir}expected.txt" "$tmp/actual.txt" > "$tmp/diff.txt"; then
		echo "cawk hypercube-ipv6 case pass : $name"
	else
		echo "cawk hypercube-ipv6 case error : $name"
		sed 's/^/    /' "$tmp/diff.txt"
		ko=$((ko+1))
	fi
	n=$((n+1))
done
# defaults (both reported) and explicit switches, on a redundant and an inconsistent case
for spec in "01_v4_identical_redundant:redundant rules" "04_v4_wildcard_inconsistent:inconsistent rules"; do
	dir=validate/hypercube-ipv6/${spec%%:*}/; word=${spec#*:}
	for opts in "HYPERCUBE_INCONSISTENCY=yes HYPERCUBE_REDUNDANCY=no" "HYPERCUBE_INCONSISTENCY=no HYPERCUBE_REDUNDANCY=yes" "HYPERCUBE_INCONSISTENCY=no HYPERCUBE_REDUNDANCY=no" "-"; do
		if [ "$opts" = "-" ]; then out=$(env -u HYPERCUBE_INCONSISTENCY -u HYPERCUBE_REDUNDANCY gawk -f "$tmp/common_stub.gawk" -f common/common_hypercube-lib.gawk -f "${dir}rules.gawk" /dev/null 2>&1); opts="HYPERCUBE_INCONSISTENCY=yes HYPERCUBE_REDUNDANCY=yes"; else out=$(env $opts gawk -f "$tmp/common_stub.gawk" -f common/common_hypercube-lib.gawk -f "${dir}rules.gawk" /dev/null 2>&1); fi
		case " $opts " in *" HYPERCUBE_$(echo "$word" | sed "s/redundant rules/REDUNDANCY=yes/;s/inconsistent rules/INCONSISTENCY=yes/") "*) want=1 ;; *) want=0 ;; esac
		got=0; case "$out" in *"$word"*) got=1 ;; esac
		if [ "$got" = "$want" ]; then echo "cawk hypercube-ipv6 options pass : ${spec%%:*} $opts"; else echo "cawk hypercube-ipv6 options error : ${spec%%:*} $opts (expected $want got $got)"; ko=$((ko+1)); fi
		n=$((n+1))
	done
done
echo "cawk hypercube-ipv6 : $n cases, $ko NOK ----"
exit $((ko > 0))
