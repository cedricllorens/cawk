#!/bin/sh
#==============================================================================
# File        : run.sh
# Purpose     : Non-regression of the data_set of a named audit
#               (database/data_set/run_<audit>/data_set_<audit>_YYYY-MM-DD.txt, one file per date: create_audit, append, DATA_SET_KEEP rotation,
#               same-date replacement, errors, check_database, html dashboard, backup, delete_audit)
# Usage       : gmake check_validate   (or: sh validate/data_set/run.sh, from the cawk root)
# Note        : a temporary audit is created and deleted ; no real assessment is run (a fake summary is written)
#==============================================================================

AUDIT=datasettest
D="database/data_set/run_${AUDIT}"
TODAY=$(date +%Y-%m-%d)
F="$D/data_set_${AUDIT}_$TODAY.txt"
SUMMARY="reports/run_${AUDIT}/assessment.all.summary.txt"

if [ ! -f Makefile ] || [ ! -d validate/data_set ]; then
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

cleanup() {
	gmake delete_audit audit=$AUDIT FORCE=yes > /dev/null 2>&1
	rm -rf "$D"; rm -f "backup/run_audit_${AUDIT}_"*.tar.gz
	rm -rf "$W"
}
trap cleanup EXIT
trap 'exit 2' INT TERM

t() {
	desc="$1"; shift
	if "$@" > /dev/null 2>&1; then pass=$((pass+1)); echo "cawk data_set case pass : $desc"
	else fail=$((fail+1)); echo "cawk data_set case error : $desc"; fi
}
tn() {
	desc="$1"; shift
	if "$@" > /dev/null 2>&1; then fail=$((fail+1)); echo "cawk data_set case error : $desc"
	else pass=$((pass+1)); echo "cawk data_set case pass : $desc"; fi
}

ndates() { ls "$D"/data_set_${AUDIT}_*.txt 2>/dev/null | wc -l; }
all() { cat "$D"/data_set_${AUDIT}_*.txt; }
has() { all | grep -q "$1"; }
# seed DATE [CONF] : the file of a past date (header + one line)
seed() { { echo '# date;key=value;... (keys: the number_of_* of the summary without the prefix, nist_ref_coverage=covered/total, nist_<family>=covered/total)'; echo "$1;confs=${2:-1};checks=1;pass=1;error=0;warning=0;psirt=0;pass_high=1;pass_medium=0;pass_low=0;pass_info=0;error_high=0;error_medium=0;error_low=0;error_info=0;nist_ref_coverage=0/10"; } > "$D/data_set_${AUDIT}_$1.txt"; }
SCRIPT="sh common/data_set.script.sh"
# ds [KEEP [DATE]] : the append done by cawk_report_scope_all
ds() { $SCRIPT append $AUDIT "${1:-52}" "${2:-$TODAY}"; }

fake_summary() {
	cat > "$SUMMARY" <<EOS
number_of_confs  = $1
number_of_confs_badformat = 0
number_of_checks = 100
number_of_checks_exceptions = 2
number_of_pass = $2 (50.0%)
	number_of_pass_high   = 1 (1.0%)
	number_of_pass_medium = 2 (1.0%)
	number_of_pass_low    = 3 (1.0%)
	number_of_pass_info   = 4 (1.0%)
number_of_error = 30 (30.0%)
	number_of_error_high   = 10 (33.3%)
	number_of_error_medium = 5 (16.7%)
	number_of_error_low    = 5 (16.7%)
	number_of_error_info   = 10 (33.3%)
number_of_warning = 20 (20.0%)
number_of_psirt = 1 (1.0%)
---- security key indicators ----
security_compliance (scope pass/error) = 62.5% ([90,100]/excellent)
---- nist sp 800-53 key indicators ----
nist_ref_coverage = 22.9% (118 total, 27 covered)
nist_access_control = 29.0% (9/31)
---- error stats ----
number_of_error_high = 999
EOS
}

# 1. create_audit creates the file with its header only
gmake create_audit audit=$AUDIT > /dev/null 2>&1 || { echo "cawk error: create_audit failed ----"; exit 2; }
t "create_audit creates the run_<audit> directory" test -d "$D"
t "created data_set directory holds no file" test "$(ndates)" = 0
seed 2026-01-01
gmake create_audit audit=$AUDIT supplier=cisco-ios > /dev/null 2>&1
t "create_audit supplier= keeps the history" test "$(ndates)" = 1

# 2. append: missing summary, then one line
rm -f "$SUMMARY"
tn "append without summary fails" ds
fake_summary 10 50
t "append adds the line of the day" ds
t "the file name holds the date" test -f "$F"
t "the line holds the counters" sh -c "tail -n 1 '$F' | grep -q ';confs=10;.*;checks=100;.*;pass=50;.*;pass_info=4;.*;error_high=10;'"
t "the second error_high of the summary is ignored" sh -c "! tail -n 1 '$F' | grep -q 'error_high=999'"
t "the nist lines are stored as covered/total" sh -c "tail -n 1 '$F' | grep -q ';nist_ref_coverage=27/118;nist_access_control=9/31\$'"
t "the previous date is kept" has '^2026-01-01;'

# 3. same date: replaced, not duplicated
fake_summary 11 55
t "append twice the same day" ds
t "same date replaced, not duplicated" test "$(grep -c "^$TODAY;" "$F")" = 1
t "same date holds the new values" has "^$TODAY;confs=11;.*;pass=55;"

# 4. rotation
for d in 2026-01-02 2026-01-03 2026-01-04 2026-01-05; do seed $d; done
t "append with DATA_SET_KEEP=3" ds 3
t "rotation keeps 3 dates" test "$(ndates)" = 3
t "rotation drops the oldest dates" sh -c "! ls $D | grep -q '_2026-01-0[1-3].txt'"
t "rotation keeps the newest date" has "^$TODAY;"
t "DATA_SET_KEEP=1 keeps 1 date" ds 1
t "one date left" test "$(ndates)" = 1

# 5. invalid values and arguments
for k in 0 abc -1 ""; do tn "DATA_SET_KEEP=<$k> rejected" $SCRIPT append $AUDIT "$k" "$TODAY"; done
tn "invalid date rejected" ds 52 2026-13
tn "no audit rejected" $SCRIPT append "" 52 "$TODAY"
tn "DATA_SET=maybe rejected" gmake check_supplier DATA_SET=maybe
tn "DATA_SET_KEEP=0 rejected by check_supplier" gmake check_supplier DATA_SET_KEEP=0

# 6. check_database
t "check_database accepts the data_set" gmake check_database
printf '%s\n' 'bad;line' >> "$F"
tn "check_database rejects a bad line" gmake check_database
sed -i '$d' "$F"
seed 2026-02-02; mv "$D/data_set_${AUDIT}_2026-02-02.txt" "$D/data_set_${AUDIT}_2026-02-03.txt"
tn "check_database rejects a date different from the file name" gmake check_database
rm -f "$D/data_set_${AUDIT}_2026-02-03.txt"
: > "$D/data_set_other.txt"
tn "check_database rejects a bad file name" gmake check_database
rm -f "$D/data_set_other.txt"

# 6b. html dashboard: the evolution section is embedded for a named audit data_set only
gmake common/report_html.gawk > /dev/null 2>&1; : > "$W/empty.csv"
seed 2026-01-01; seed 2026-01-02
html() { ./common/report_html.gawk -v HTML_SKELETON=common/report_html.skeleton.html -v CONTEXT=$AUDIT -v AUDIT=$AUDIT -v CAWK_RELEASE=x "$@" database/db_info.txt "$W/empty.csv"; }
html_has() { html "$@" | grep -q '"dataset":\['; }
t "html embeds the dataset" html_has -v "DATA_SET_FILES=$(ls $D/data_set_${AUDIT}_2026-01-0[12].txt | tr '\n' ' ')"
tn "html without DATA_SET_FILES has no dataset" html_has
rm -f "$D"/data_set_${AUDIT}_2026-01-0[12].txt
# the files must be listed by the shell after the append of the day, never by $(wildcard) at make expansion time
t "check_run lists the data_set files at run time" sh -c "gmake -n check_run audit=$AUDIT HTML=yes 2>/dev/null | grep -q 'DATA_SET_FILES=\$(ls '"

# 7. backup, delete
gmake backup_run audit=$AUDIT > /dev/null 2>&1
t "backup_run holds the data_set" sh -c "tar -tzf backup/run_audit_${AUDIT}_*.tar.gz | grep -q 'run_${AUDIT}/data_set_${AUDIT}_'"
t "delete_audit removes the data_set directory" sh -c "gmake delete_audit audit=$AUDIT FORCE=yes && [ ! -d '$D' ]"

echo "cawk data_set cases : $pass pass, $fail error ----"
[ "$fail" -eq 0 ]
