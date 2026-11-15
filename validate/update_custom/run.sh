#!/bin/sh
#==============================================================================
# File        : run.sh
# Purpose     : Non-regression of update_custom_run (runs database/scripts/update_custom.script.sh of the user after a cawk update)
#               FORCE=yes required, no audit=, missing script, script OK, script failing, help
# Usage       : gmake check_validate   (or: sh validate/update_custom/run.sh, from the cawk root)
# Note        : an existing user script is saved and put back ; no network, no assessment
#==============================================================================

S=database/scripts/update_custom.script
LOG=logs/update_custom.err

if [ ! -f Makefile ] || [ ! -d validate/update_custom ]; then
	echo "cawk error: run this script from the cawk root ----"
	exit 2
fi

W=$(mktemp -d) || exit 2
pass=0
fail=0

for f in "$S.sh" "$S" "$LOG"; do
	[ -f "$f" ] && cp -p "$f" "$W/$(basename "$f")"
done

cleanup() {
	rm -f "$S.sh" "$S" "$LOG"
	for f in update_custom.script.sh update_custom.script; do
		[ -f "$W/$f" ] && cp -p "$W/$f" "database/scripts/$f"
	done
	[ -f "$W/update_custom.err" ] && cp -p "$W/update_custom.err" "$LOG"
	rm -rf "$W"
}
trap cleanup EXIT
trap 'exit 2' INT TERM

# expect <description> <expected exit 0|1> <expected text in the output> <command...>
expect() {
	desc="$1"; want="$2"; txt="$3"; shift 3
	out=$("$@" 2>&1); rc=$?
	[ $rc -ne 0 ] && rc=1
	if [ "$rc" = "$want" ] && printf '%s' "$out" | grep -qF -- "$txt"; then
		pass=$((pass+1)); echo "cawk update_custom case pass : $desc"
	else
		fail=$((fail+1)); echo "cawk update_custom case error : $desc (exit $rc, wanted $want, text <$txt>)"
	fi
}

rm -f "$S.sh" "$S"

expect "no FORCE=yes" 1 "FORCE=yes is required" gmake update_custom_run
expect "audit= refused" 1 "takes no audit=" gmake update_custom_run FORCE=yes audit=x
expect "script missing" 1 "update_custom.script.sh does not exist" gmake update_custom_run FORCE=yes

printf '#!/bin/sh\necho ran-ok\ntest "$#" -eq 0 || exit 1\n' > "$S.sh"
expect "script OK" 0 "update_custom_run done" gmake update_custom_run FORCE=yes
expect "script OK, runs it" 0 "execution" gmake update_custom_run FORCE=yes

printf '#!/bin/sh\necho boom >&2\nexit 1\n' > "$S.sh"
expect "script failing" 1 "update_custom.script failed (see logs/update_custom.err)" gmake update_custom_run FORCE=yes
if grep -q boom "$LOG" 2>/dev/null; then pass=$((pass+1)); echo "cawk update_custom case pass : stderr of the script in $LOG"
else fail=$((fail+1)); echo "cawk update_custom case error : stderr of the script not in $LOG"; fi

expect "help backup" 0 "update_custom_run FORCE=yes" gmake help backup
expect "help topic" 0 "update_custom_run" gmake help topic=update_custom

echo "cawk update_custom pass=$pass error=$fail ----"
[ $fail -eq 0 ] || exit 1
exit 0
