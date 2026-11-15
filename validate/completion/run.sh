#!/bin/sh
# non-regression of support/cawk-completion.bash: targets, audit=, supplier=, options, fallback outside a cawk root
[ -f Makefile ] && [ -d support ] || { echo "cawk error: run this script from the cawk root ----"; exit 1; }
if ! command -v bash > /dev/null 2>&1; then
	echo "cawk validate completion skipped, bash not found (the completion is a bash script) ----"
	exit 0
fi
AUDIT=zz_completion_audit
fail=0
nok() { echo "cawk error: validate/completion: $1 ----"; fail=1; }
gmake create_audit audit=$AUDIT > /dev/null 2>&1 || { echo "cawk error: validate/completion: cannot create the audit $AUDIT ----"; exit 1; }

# complete "<words...>" (the last word is the one completed): prints the candidates, one line
complete_words() {
	bash -c '. support/cawk-completion.bash; COMP_WORDS=("$@"); COMP_CWORD=$(($# - 1)); _cawk_complete; echo "${COMPREPLY[@]}"' _ "$@"
}

out=$(complete_words gmake stat) || nok "completion of a target failed"
echo "$out" | grep -qw status || nok "stat does not complete to status: $out"
out=$(complete_words gmake check_run audit=zz_completion) || nok "completion of audit= failed"
[ "$out" = "audit=$AUDIT" ] || nok "audit= completion gives <$out>"
out=$(complete_words gmake check_run supplier=cisco-x) || nok "completion of supplier= failed"
[ "$out" = "supplier=cisco-xe supplier=cisco-xr" ] || nok "supplier= completion gives <$out>"
out=$(complete_words gmake check_run FORCE=) || nok "completion of FORCE= failed"
[ "$out" = "FORCE=yes FORCE=no" ] || nok "FORCE= completion gives <$out>"
out=$(complete_words gmake check_run PSIRT_ONLY=) || nok "completion of PSIRT_ONLY= failed"
[ "$out" = "PSIRT_ONLY=yes PSIRT_ONLY=no" ] || nok "PSIRT_ONLY= completion gives <$out>"
out=$(complete_words gmake censor_run CENSOR_LEVEL=) || nok "completion of CENSOR_LEVEL= failed"
[ "$out" = "CENSOR_LEVEL=internal CENSOR_LEVEL=external" ] || nok "CENSOR_LEVEL= completion gives <$out>"
out=$(complete_words gmake database_collect_add collector=) || nok "completion of collector= failed"
[ "$out" = "collector=local collector=rsync collector=scp" ] || nok "collector= completion gives <$out>"
out=$(complete_words gmake help topic=censor_f) || nok "completion of topic= failed"
echo "$out" | grep -qw topic=censor_file || nok "topic= completion gives <$out>"
out=$(complete_words gmake check_run SECRETS) || nok "completion of an option name failed"
[ "$out" = "SECRETSCAN=" ] || nok "option name completion gives <$out>"
out=$(complete_words gmake check_run NOSUCH=) || nok "completion of an unknown option failed"
[ -z "$out" ] || nok "unknown option completes to <$out>"
out=$(complete_words gmake zzzz_no_such_target) || nok "completion of an unknown word failed"
[ -z "$out" ] || nok "unknown word completes to <$out>"

# outside a cawk root: no candidate from cawk, no error
tmpdir=$(mktemp -d) || { echo "cawk error: validate/completion: mktemp failed ----"; exit 1; }
root=$(pwd)
out=$(cd "$tmpdir" && bash -c ". $root/support/cawk-completion.bash; COMP_WORDS=(gmake stat); COMP_CWORD=1; _cawk_complete; echo \"\${COMPREPLY[@]}\"" 2>&1) || nok "completion outside a cawk root fails"
echo "$out" | grep -qw status && nok "cawk targets completed outside a cawk root"
rmdir "$tmpdir"

gmake delete_audit audit=$AUDIT FORCE=yes > /dev/null 2>&1 || nok "cannot delete the audit $AUDIT"
[ $fail -eq 0 ] || exit 1
echo "cawk validate completion done ----"
