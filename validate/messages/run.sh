#!/bin/sh
# non-regression of the cawk error messages: one format, early audit validation, help sections, unknown target
[ -f Makefile ] && [ -d support ] || { echo "cawk error: run this script from the cawk root ----"; exit 1; }
AUDIT=zz_messages_unknown
fail=0
nok() { echo "cawk error: validate/messages: $1 ----"; fail=1; }

# 1 format: "cawk error: <message> ----" in every source file, no internal placeholder; ANSI codes stripped before the check
FILES=$(find . -type f \( -name '*.mk' -o -name '*.sh' -o -name '*.template' -o -name '*.m4' -o -name 'Makefile*' -o -name '*.bash' -o -path './roles/*' \) -not -path './.git/*' -not -name '*.orig' -not -path './validate/*' -not -path './docs/*' -not -path './logs/*' -not -path './reports/*' -not -path './tmp/*' -not -path './backup/*' 2>/dev/null | LC_ALL=C sort)
esc=$(printf '\033')
# only emitted messages count: a quote or a backtick right before "cawk error" (comments, help text and grep patterns are skipped)
pat="[\"'\`]cawk error"
msgs=$(for f in $FILES; do sed -e "s/\\\\033\\[[0-9;]*m//g" -e "s/${esc}\\[[0-9;]*m//g" "$f" | grep -nE "$pat" | sed "s|^|$f:|"; done)
bad=$(printf '%s\n' "$msgs" | grep -E 'cawk error([^:]|$)')
[ -z "$bad" ] || nok "cawk error without colon: $bad"
bad=$(printf '%s\n' "$msgs" | grep -vE 'cawk error: .* ----' | grep -v 'cawk error: \$\$')
[ -z "$bad" ] || nok "cawk error without the ' ----' suffix: $bad"
bad=$(printf '%s\n' "$msgs" | grep -E '(=|<[^>]*=)AUDIT_NAME')
[ -z "$bad" ] || nok "internal placeholder AUDIT_NAME in cawk error: $bad"
bad=$(for f in $FILES; do grep -n 'audit=AUDIT_NAME must be set\|audit=\$(audit) do not exist' "$f" | sed "s|^|$f:|"; done)
[ -z "$bad" ] || nok "old audit message: $bad"
# POSIX only: every .sh script starts with #!/bin/sh (the .bash completion is sourced by bash on purpose)
bad=$(for f in $FILES; do case "$f" in *.sh) head -1 "$f" | grep -q '^#!/bin/sh$' || printf '%s: %s\n' "$f" "$(head -1 "$f")";; esac; done)
[ -z "$bad" ] || nok "non-POSIX shebang, must be #!/bin/sh: $bad"

# 2 unknown audit: fails at once, with the action, before any clean, build or scan
for t in check_run tests_run view_run view_run_error censor_run censor_logs_run censor_report_run; do
	out=$(gmake $t audit=$AUDIT 2>&1); rc=$?
	[ $rc -ne 0 ] || nok "$t audit=$AUDIT exits 0"
	echo "$out" | grep -q "^cawk error: audit $AUDIT does not exist (create it with: gmake create_audit audit=$AUDIT" || nok "$t audit=$AUDIT: no explicit message"
	[ "$(echo "$out" | grep -c '^cawk ')" -eq 1 ] || nok "$t audit=$AUDIT ran something before failing"
done
[ ! -e reports/run_$AUDIT ] || nok "reports/run_$AUDIT created"

# 3 missing audit= on delete_audit
out=$(gmake delete_audit FORCE=yes 2>&1); rc=$?
[ $rc -ne 0 ] && echo "$out" | grep -q '^cawk error: audit= must be set (usage: gmake <target> audit=<name>' || nok "delete_audit without audit="

# 4 help: list of the sections, then each section
out=$(gmake help 2>&1) || nok "gmake help failed"
sections=$(sed -n 's/^HELP_SECTIONS = //p' support/Makefile.support.vars.mk)
[ -n "$sections" ] || nok "HELP_SECTIONS not found"
for s in $sections; do
	echo "$out" | grep -q "^# $s  *:" || nok "gmake help does not list the section $s"
	gmake help $s > /dev/null 2>&1 || nok "gmake help $s failed"
	gmake help $s 2>&1 | grep -q '^  ###   #   #  #   #  #   #' || nok "gmake help $s has no logo"
	gmake help $s 2>&1 | grep -q '^# gmake\|^# NOTE\|^# note' || nok "gmake help $s is empty"
done
gmake help all > /dev/null 2>&1 || nok "gmake help all failed"
gmake help nosuchsection > /dev/null 2>&1 && nok "unknown help section exits 0"
gmake help sync collect > /dev/null 2>&1 && nok "two help sections exit 0"

# 5 unknown target: explicit message, not the raw gmake one
out=$(gmake check_ru 2>&1); rc=$?
[ $rc -ne 0 ] && echo "$out" | grep -q '^cawk error: unknown target <check_ru>, similar targets: .*check_run' || nok "unknown target message"

out=$(gmake chek_run 2>&1); rc=$?
[ $rc -ne 0 ] && echo "$out" | grep -q '^cawk error: unknown target <chek_run>, similar targets: .*check_run' || nok "typo of an unknown target is not suggested"
out=$(gmake zzzzzz 2>&1); rc=$?
[ $rc -ne 0 ] && echo "$out" | grep -q '^cawk error: unknown target <zzzzzz> (list the sections' || nok "unknown target without a similar one"

# 6 help topic=WORD: the lines holding the word, error when none; a positional word never builds a target
out=$(gmake help topic=censor_file 2>&1) || nok "help topic=censor_file failed"
echo "$out" | grep -q '^# gmake censor_file ' || nok "help topic=censor_file finds no censor_file line"
out=$(gmake help topic=zz_no_such_word 2>&1); rc=$?
[ $rc -ne 0 ] && echo "$out" | grep -q '^cawk error: no help line holds <zz_no_such_word>' || nok "help topic of an unknown word"
out=$(gmake help clean 2>&1); rc=$?
[ $rc -ne 0 ] && echo "$out" | grep -q 'search a word with: gmake help topic=clean' && ! echo "$out" | grep -q '^cawk clean' || nok "gmake help <target> must fail without building the target"
gmake help 2>&1 | grep -q '^# quick start' || nok "gmake help has no quick start"

# 7 status: needs an existing audit, shows the next command
out=$(gmake status audit=$AUDIT 2>&1); rc=$?
[ $rc -ne 0 ] && echo "$out" | grep -q "^cawk error: audit $AUDIT does not exist" || nok "status of an unknown audit"
gmake create_audit audit=zz_messages_status > /dev/null 2>&1 || nok "cannot create the audit zz_messages_status"
out=$(gmake status audit=zz_messages_status 2>&1) || nok "status of an existing audit failed"
for k in 'confs      :' 'tests      :' 'assessment : none yet' 'exceptions :' 'censored   :' 'next step  : gmake clean check_run view_run audit=zz_messages_status'; do
	echo "$out" | grep -q "^  $k" || nok "status misses <$k>"
done
out=$(gmake status 2>&1) || nok "status without audit= failed"
echo "$out" | grep -q '^cawk status of audit <zz_messages_status> ----' || nok "status without audit= does not list the audit zz_messages_status"
gmake delete_audit audit=zz_messages_status FORCE=yes > /dev/null 2>&1 || nok "cannot delete the audit zz_messages_status"

# 8 usage hints of the censor and backup messages
out=$(gmake censor_file 2>&1); echo "$out" | grep -q '^cawk error: censor_file needs in=PATH_FILE and out=PATH_FILE_OUT (usage: gmake censor_file in=' || nok "censor_file usage hint"

# 9 unknown option on the command line: cawk error with the closest option, exit != 0, nothing else runs, whatever the target
for t in check_repo clean_tmp help version list_audit; do
	out=$(gmake $t PSIRT_ONY=yes 2>&1); rc=$?
	[ $rc -ne 0 ] || nok "$t PSIRT_ONY=yes exits 0"
	echo "$out" | grep -q '^cawk error: unknown option <PSIRT_ONY>, did you mean: .*PSIRT_ONLY' || nok "$t PSIRT_ONY=yes: no explicit message with the closest option"
	[ "$(echo "$out" | grep -c '^cawk ')" -eq 1 ] || nok "$t PSIRT_ONY=yes ran something before failing"
done
out=$(gmake clean_tmp psirt_only=yes CENSOR_LEVL=external 2>&1); rc=$?
[ $rc -ne 0 ] && [ "$(echo "$out" | grep -c '^cawk error: unknown option')" -eq 2 ] && echo "$out" | grep -q 'unknown option <CENSOR_LEVL>, did you mean: CENSOR_LEVEL' && echo "$out" | grep -q 'unknown option <psirt_only>, did you mean: PSIRT_ONLY' || nok "every unknown option must be reported (case typo and letter typo)"
# the PSIRT_ONY typo above must not hide valid words: options of vars.mk, parameters, values with spaces, commas and '='
out=$(gmake clean_tmp PSIRT_ONLY=no audit=zz_messages_unknown FORCE=yes args=host=1.2.3.4,user=a,remote_path=/x HELP_NOLOGO=yes 2>&1); echo "$out" | grep -q 'unknown option' && nok "a valid option or parameter is reported as unknown"

# 10 database_view_*: an incomplete line is shown with default values, never an error (the strict format check is check_database)
DBV=$(mktemp -d) || nok "cannot create a temporary database directory"
printf 'c1 /conf/ .*sw.* none cisco-ios _x none\nc2 /conf/\nc3\n' > "$DBV/db_sync.txt"
printf 'c1 a@x.com cc@x.com\nc2\n' > "$DBV/db_email.txt"
printf 'c1 rsync host=h\nc2\n' > "$DBV/db_collect.txt"
printf 'c1\nc2 extra\n' > "$DBV/db_postaudit.txt"
out=$(gmake database_view DATABASE_PATH="$DBV" 2>&1) || nok "database_view fails on incomplete lines"
echo "$out" | grep -q '^regexos               : \.\* (default)' || nok "database_view_sync: no default value shown"
echo "$out" | grep -q '^sync_paths            : (missing, required)' || nok "database_view_sync: missing sync_paths not shown"
echo "$out" | grep -q '^dst_emails : (missing, required)' || nok "database_view_email: missing dst_emails not shown"
echo "$out" | grep -q '^args      : none (default)' || nok "database_view_collect: no default args shown"
echo "$out" | grep -q '^cawk warning: .*extra fields ignored' || nok "database_view_postaudit: extra field not reported as a warning"
echo "$out" | grep -q '^cawk 3 entries, 2 incomplete' || nok "database_view_sync: no summary"
[ "$(echo "$out" | grep -c '^- - - - - -')" -ge 12 ] || nok "database_view: separator missing between entries"
echo "$out" | grep -q '^cawk error' && nok "database_view reports an error on incomplete lines"
rm -rf "$DBV"

[ $fail -eq 0 ] || exit 1
echo "cawk validate messages done ----"
