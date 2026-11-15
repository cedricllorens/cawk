#!/bin/sh

# ---------------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# this script checks one by one every cawk flat-file database (.txt)
# against its expected format (docs/CAWK_DATABASE_FORMAT.md) and prints
# every line that does not follow it
#
# usage: check_database.script.sh "<supplier scope>"   (gmake check_database)
# ---------------------------------------------------------------------

LC_ALL=C
export LC_ALL

DB=database

if [ ! -f Makefile ] || [ ! -d "$DB" ]; then
	echo "cawk error: run this script from the cawk root ----"
	exit 2
fi
if [ -z "$1" ]; then
	echo "cawk error: the supplier scope is missing ----"
	exit 2
fi

CAWK_SUPPLIERS="$1"
export CAWK_SUPPLIERS

# RFC 5322 official standard email address (quoted local parts and comments
# are not expressible in the flat-file format: no space, no comma in a field)
CAWK_MAIL_RE="[A-Za-z0-9!#\$%&'*+/=?^_\`{|}~-]+(\\.[A-Za-z0-9!#\$%&'*+/=?^_\`{|}~-]+)*@([A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?\\.)+[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?"
export CAWK_MAIL_RE

W=$(mktemp -d) || { echo "cawk error: cannot create a temporary directory ----"; exit 2; }
trap 'rm -rf "$W"' EXIT INT TERM

TAB=$(printf '\t')
TOTAL=0

# ---------------------------------------------------------------------
# run one gawk pass on a database, then resolve the requests it emitted
# (regex validity, file/audit existence: outside of gawk on purpose)
# ---------------------------------------------------------------------

check_db() {
	f="$1"
	: > "$W/req"
	: > "$W/dberr"
	gawk -v db="$f" -v reqpath="$W/req" -v fdate="$3" "$2" "$f" >> "$W/dberr" 2>&1 || {
		echo "cawk error: gawk failed on $f ----" >> "$W/dberr"
	}
	while IFS="$TAB" read -r kind db line field value; do
		case "$kind" in
		audit)
			if [ "$value" != "repo" ] && [ ! -d "tests/run_$value" ]; then
				echo "cawk error: $db: line $line: field $field: audit $value does not exist (tests/run_$value is missing) ----" >> "$W/dberr"
			fi
			;;
		context)
			case "$value" in
			repo|run) ;;
			*)
				# the catalogs write the audit name itself (repo | run | AUDIT_NAME), the audit being tests/run_AUDIT_NAME
				[ -d "tests/run_$value" ] || echo "cawk error: $db: line $line: field $field: $value is not an audit context (repo | run | an existing AUDIT_NAME, tests/run_$value is missing) ----" >> "$W/dberr"
				;;
			esac
			;;
		regex)
			printf '' | grep -Eq -- "$value" 2>/dev/null
			if [ $? -eq 2 ]; then
				echo "cawk error: $db: line $line: field $field: $value is not a valid extended regex ----" >> "$W/dberr"
			fi
			;;
		file)
			[ -f "$value" ] || echo "cawk error: $db: line $line: field $field: scope file $value does not exist ----" >> "$W/dberr"
			;;
		collector)
			[ -f "$DB/collectors/$value.collector.sh" ] || echo "cawk error: $db: line $line: field $field: collector script $DB/collectors/$value.collector.sh does not exist ----" >> "$W/dberr"
			;;
		esac
	done < "$W/req"
	if [ -s "$W/dberr" ]; then
		cat "$W/dberr"
		TOTAL=$((TOTAL + 1))
	else
		echo "cawk check_database $f OK ----"
	fi
}

missing_db() {
	echo "cawk error: $1 is missing $2 ----"
	TOTAL=$((TOTAL + 1))
}

# ---------------------------------------------------------------------
# db_sync.txt : audit sync_paths regexinventory scope regexos regexpathexclude regexinventoryexclude
# ---------------------------------------------------------------------

DB_SYNC='
function fail(line, msg) { printf "cawk error: %s: line %d: %s ----\n", db, line, msg }
function req(kind, line, field, value) {
	if (!((kind, value) in asked)) {
		asked[kind, value]
		printf "%s\t%s\t%s\t%s\t%s\n", kind, db, line, field, value >> reqpath
	}
}
{
	line = FNR
	if ($0 ~ /\r$/) { fail(line, "carriage return at end of line (the databases are LF only)"); next }
	if (NF == 0) { fail(line, "empty line"); next }
	if (NF != 7) { fail(line, "expected 7 space-separated fields (audit sync_paths regexinventory scope regexos regexpathexclude regexinventoryexclude), got " NF); next }
	if (++seen[$1] > 1) fail(line, "duplicate audit " $1)
	if ($2 ~ /(^,|,,|,$)/) fail(line, "field 2 (sync_paths): empty element in the comma-separated list")
	req("audit", line, 1, $1)
	req("regex", line, 3, $3)
	if ($4 != "none") req("file", line, 4, $4)
	req("regex", line, 5, $5)
	if ($6 != "none") req("regex", line, 6, $6)
	if ($7 != "none") req("regex", line, 7, $7)
}'

# ---------------------------------------------------------------------
# db_collect.txt : audit collector args
# ---------------------------------------------------------------------

DB_COLLECT='
function fail(line, msg) { printf "cawk error: %s: line %d: %s ----\n", db, line, msg }
function req(kind, line, field, value) {
	if (!((kind, value) in asked)) {
		asked[kind, value]
		printf "%s\t%s\t%s\t%s\t%s\n", kind, db, line, field, value >> reqpath
	}
}
{
	line = FNR
	if ($0 ~ /\r$/) { fail(line, "carriage return at end of line (the databases are LF only)"); next }
	if (NF == 0) { fail(line, "empty line"); next }
	if (NF != 3) { fail(line, "expected 3 space-separated fields (audit collector args), got " NF); next }
	if (++seen[$1] > 1) fail(line, "duplicate audit " $1)
	req("audit", line, 1, $1)
	collector = $2
	if (collector !~ /^(none|scp|rsync|local)$/) { fail(line, "field 2 (collector): " collector " is not one of none | scp | rsync | local"); next }
	if (collector != "none") req("collector", line, 2, collector)
	if (collector == "none" && $3 != "none") { fail(line, "field 3 (args): collector none takes args none"); next }
	if (collector != "none" && $3 == "none") { fail(line, "field 3 (args): collector " collector " requires comma-separated key=value args"); next }
	if ($3 == "none") next
	delete argseen
	n = split($3, p, ",")
	for (i = 1; i <= n; i++) {
		eq = index(p[i], "=")
		if (eq < 2) { fail(line, "field 3 (args): " p[i] " is not a key=value pair"); continue }
		k = substr(p[i], 1, eq - 1)
		v = substr(p[i], eq + 1)
		if (k !~ /^[a-z_]+$/) { fail(line, "field 3 (args): " k " is not a valid key"); continue }
		if (v == "") { fail(line, "field 3 (args): empty value for key " k); continue }
		if (k in argseen) { fail(line, "field 3 (args): duplicate key " k); continue }
		argseen[k] = v
	}
	if (collector == "scp" || collector == "rsync") {
		for (k in argseen)
			if (k !~ /^(host|user|remote_path|key|port|timeout|hostkey|options)$/)
				fail(line, "field 3 (args): unknown key " k " for collector " collector)
		for (k in list) delete list[k]; list["host"]; list["user"]; list["remote_path"]
		for (k in list) if (!(k in argseen)) fail(line, "field 3 (args): missing key " k " for collector " collector)
		if (("port" in argseen) && argseen["port"] !~ /^[0-9]+$/) fail(line, "field 3 (args): port must be numeric")
		if (("timeout" in argseen) && argseen["timeout"] !~ /^[0-9]+$/) fail(line, "field 3 (args): timeout must be numeric")
		if (("hostkey" in argseen) && argseen["hostkey"] !~ /^(yes|accept-new)$/) fail(line, "field 3 (args): hostkey must be yes or accept-new")
	} else {
		for (k in argseen)
			if (k != "source_path")
				fail(line, "field 3 (args): unknown key " k " for collector local")
		if (!("source_path" in argseen)) fail(line, "field 3 (args): missing key source_path for collector local")
		if (argseen["source_path"] !~ /^\//) fail(line, "field 3 (args): source_path must be an absolute directory")
	}
}'

# ---------------------------------------------------------------------
# db_email.txt : audit dst_emails cc_emails
# ---------------------------------------------------------------------

DB_EMAIL='
function fail(line, msg) { printf "cawk error: %s: line %d: %s ----\n", db, line, msg }
function req(kind, line, field, value) {
	if (!((kind, value) in asked)) {
		asked[kind, value]
		printf "%s\t%s\t%s\t%s\t%s\n", kind, db, line, field, value >> reqpath
	}
}
function check_emails(line, field, list) {
	if (list == "none") return
	n = split(list, e, ",")
	for (i = 1; i <= n; i++)
		if (e[i] !~ ("^" ENVIRON["CAWK_MAIL_RE"] "$"))
			fail(line, "field " field ": " e[i] " is not a valid rfc 5322 address")
}
{
	line = FNR
	if ($0 ~ /\r$/) { fail(line, "carriage return at end of line (the databases are LF only)"); next }
	if (NF == 0) { fail(line, "empty line"); next }
	if (NF != 3) { fail(line, "expected 3 space-separated fields (audit dst_emails cc_emails), got " NF); next }
	if (++seen[$1] > 1) fail(line, "duplicate audit " $1)
	req("audit", line, 1, $1)
	check_emails(line, 2, $2)
	check_emails(line, 3, $3)
}'

# ---------------------------------------------------------------------
# db_postaudit.txt : audit
# ---------------------------------------------------------------------

DB_POSTAUDIT='
function fail(line, msg) { printf "cawk error: %s: line %d: %s ----\n", db, line, msg }
function req(kind, line, field, value) {
	if (!((kind, value) in asked)) {
		asked[kind, value]
		printf "%s\t%s\t%s\t%s\t%s\n", kind, db, line, field, value >> reqpath
	}
}
{
	line = FNR
	if ($0 ~ /\r$/) { fail(line, "carriage return at end of line (the databases are LF only)"); next }
	if (NF == 0) { fail(line, "empty line"); next }
	if (NF != 1) { fail(line, "expected 1 field (audit), got " NF); next }
	if (++seen[$1] > 1) fail(line, "duplicate audit " $1)
	req("audit", line, 1, $1)
}'

# ---------------------------------------------------------------------
# db_exception.txt : audit;supplier;exception_id;approver;date;reason
# ---------------------------------------------------------------------

DB_EXCEPTION='
function fail(line, msg) { printf "cawk error: %s: line %d: %s ----\n", db, line, msg }
function req(kind, line, field, value) {
	if (!((kind, value) in asked)) {
		asked[kind, value]
		printf "%s\t%s\t%s\t%s\t%s\n", kind, db, line, field, value >> reqpath
	}
}
BEGIN { FS = ";" }
FNR == 1 {
	if ($0 != "audit;supplier;exception_id;approver;date;reason") fail(1, "expected header audit;supplier;exception_id;approver;date;reason")
}
FNR > 1 {
	line = FNR
	if ($0 ~ /\r$/) { fail(line, "carriage return at end of line (the databases are LF only)"); next }
	if (NF != 6) { fail(line, "expected 6 semicolon-separated fields (audit;supplier;exception_id;approver;date;reason), got " NF); next }
	if ($1 == "" || $2 == "" || $3 == "" || $4 == "" || $5 == "" || $6 == "") { fail(line, "empty field"); next }
	if (!(($2) in sup)) { fail(line, "field 2 (supplier): " $2 " is not a supported supplier"); next }
	if (++seen[$1 ";" $2 ";" $3] > 1) fail(line, "duplicate exception " $3 " for audit " $1 " and supplier " $2)
	if ($5 !~ /^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$/ && $5 != "yyyy-mm-dd") fail(line, "field 5 (date): " $5 " is not a yyyy-mm-dd date")
	req("context", line, 1, $1)
}
BEGIN {
	n = split(ENVIRON["CAWK_SUPPLIERS"], s, " ")
	for (i = 1; i <= n; i++) sup[s[i]] = 1
}'

# ---------------------------------------------------------------------
# db_info.txt : audit;supplier;test_name;purpose;description;actions;nist800-53_ref;risk_level;authors
# ---------------------------------------------------------------------

DB_INFO='
function fail(line, msg) { printf "cawk error: %s: line %d: %s ----\n", db, line, msg }
function req(kind, line, field, value) {
	if (!((kind, value) in asked)) {
		asked[kind, value]
		printf "%s\t%s\t%s\t%s\t%s\n", kind, db, line, field, value >> reqpath
	}
}
BEGIN {
	FS = ";"
	n = split(ENVIRON["CAWK_SUPPLIERS"], s, " ")
	for (i = 1; i <= n; i++) sup[s[i]] = 1
}
FNR == 1 {
	if ($0 != "audit;supplier;test_name;purpose;description;actions;nist800-53_ref;risk_level;authors") fail(1, "expected header audit;supplier;test_name;purpose;description;actions;nist800-53_ref;risk_level;authors")
}
FNR > 1 {
	line = FNR
	if ($0 ~ /\r$/) { fail(line, "carriage return at end of line (the databases are LF only)"); next }
	if (NF != 9) { fail(line, "expected 9 semicolon-separated fields, got " NF); next }
	for (i = 1; i <= 9; i++) if ($i == "") { fail(line, "empty field " i); next }
	if (!(($2) in sup)) { fail(line, "field 2 (supplier): " $2 " is not a supported supplier"); next }
	if ($3 !~ /\.gawk$/) fail(line, "field 3 (test_name): " $3 " does not end in .gawk")
	if (++seen[$1 ";" $2 ";" $3] > 1) fail(line, "duplicate test " $3 " for audit " $1 " and supplier " $2)
	n = split($8, t, "|")
	for (i = 1; i <= n; i++) {
		gsub(/^ +| +$/, "", t[i])
		if (t[i] !~ /^(high|medium|low|info)$/) { fail(line, "field 8 (risk_level): " $8 " is not a high | medium | low | info list"); break }
	}
	req("context", line, 1, $1)
}'

# ---------------------------------------------------------------------
# db_nist800-53.txt : nist_id;category;description;applicable_suppliers
# ---------------------------------------------------------------------

DB_NIST='
function fail(line, msg) { printf "cawk error: %s: line %d: %s ----\n", db, line, msg }
BEGIN { FS = ";" }
FNR == 1 {
	if ($0 != "nist_id;category;description;applicable_suppliers") fail(1, "expected header nist_id;category;description;applicable_suppliers")
}
FNR > 1 {
	line = FNR
	if ($0 ~ /\r$/) { fail(line, "carriage return at end of line (the databases are LF only)"); next }
	if (NF != 4) { fail(line, "expected 4 semicolon-separated fields (nist_id;category;description;applicable_suppliers), got " NF); next }
	for (i = 1; i <= 4; i++) if ($i == "") { fail(line, "empty field " i); next }
	if ($1 !~ /^[A-Z]{2}-[0-9]+(\([0-9]+\))?$/) fail(line, "field 1 (nist_id): " $1 " is not an AC-x / AC-x(y) control id")
	if (++seen[$1] > 1) fail(line, "duplicate nist control " $1)
}'

# ---------------------------------------------------------------------
# psirt_os_inventory_scope.txt : device os_version chassis cpu (optional)
# ---------------------------------------------------------------------

DB_PSIRT='
function fail(line, msg) { printf "cawk error: %s: line %d: %s ----\n", db, line, msg }
{
	line = FNR
	if ($0 ~ /\r$/) { fail(line, "carriage return at end of line (the databases are LF only)"); next }
	if (NF == 0) { fail(line, "empty line"); next }
	if (NF != 4) { fail(line, "expected 4 space-separated fields (device os_version chassis cpu), got " NF); next }
	if (++seen[$1] > 1) fail(line, "duplicate device " $1)
}'

# ---------------------------------------------------------------------
# check section
# ---------------------------------------------------------------------

for f in "$DB/db_sync.txt" "$DB/db_collect.txt" "$DB/db_email.txt" "$DB/db_postaudit.txt"; do
	if [ -f "$f" ]; then
		case "$f" in
		*/db_sync.txt) prog="$DB_SYNC" ;;
		*/db_collect.txt) prog="$DB_COLLECT" ;;
		*/db_email.txt) prog="$DB_EMAIL" ;;
		*) prog="$DB_POSTAUDIT" ;;
		esac
		check_db "$f" "$prog"
	else
		missing_db "$f" "(see docs/CAWK_DATABASE_FORMAT.md)"
	fi
done

for f in "$DB/db_exception.txt" "$DB/db_info.txt" "$DB/db_nist800-53.txt"; do
	if [ -f "$f" ]; then
		case "$f" in
		*/db_exception.txt) prog="$DB_EXCEPTION" ;;
		*/db_info.txt) prog="$DB_INFO" ;;
		*) prog="$DB_NIST" ;;
		esac
		check_db "$f" "$prog"
	else
		case "$f" in
		*/db_exception.txt) missing_db "$f" "(run: gmake exceptions_build)" ;;
		*/db_info.txt) missing_db "$f" "(run: gmake catalog_build)" ;;
		*) missing_db "$f" "(see docs/CAWK_DATABASE_FORMAT.md)" ;;
		esac
	fi
done

if [ -f "$DB/psirt_scopes/psirt_os_inventory_scope.txt" ]; then
	check_db "$DB/psirt_scopes/psirt_os_inventory_scope.txt" "$DB_PSIRT"
fi

# ---------------------------------------------------------------------
# data_set/run_<audit>/data_set_<audit>_YYYY-MM-DD.txt : header, then one line date;key=value;... (counters of the summary, nist_*=covered/total)
# ---------------------------------------------------------------------

DB_DATA_SET='
function fail(line, msg) { printf "cawk error: %s: line %d: %s ----\n", db, line, msg }
BEGIN { FS = ";"; nreq = split("confs checks pass error warning psirt pass_high pass_medium pass_low pass_info error_high error_medium error_low error_info nist_ref_coverage", req, " ") }
FNR == 1 {
	if ($0 != "# date;key=value;... (keys: the number_of_* of the summary without the prefix, nist_ref_coverage=covered/total, nist_<family>=covered/total)") fail(1, "expected the data_set header line (run gmake check_run audit=AUDIT_NAME to rewrite it, and delete the lines of the old format)")
	next
}
{
	line = FNR
	if ($0 ~ /\r$/) { fail(line, "carriage return at end of line (the databases are LF only)"); next }
	if ($1 !~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/) { fail(line, "field 1 (date): " $1 " is not a YYYY-MM-DD date"); next }
	delete seen
	for (i = 2; i <= NF; i++) {
		if ($i !~ /^[a-z][a-z0-9_]*=([0-9]+|[0-9]+\/[0-9]+)$/) { fail(line, "field " i ": " $i " is not key=number or key=covered/total"); continue }
		k = $i; sub(/=.*/, "", k)
		if (k in seen) fail(line, "field " i ": key " k " is repeated")
		seen[k] = 1
	}
	for (i = 1; i <= nreq; i++) if (!(req[i] in seen)) fail(line, "key " req[i] " is missing (old format: delete the line)")
	if (++nlines > 1) fail(line, "one line per file expected (one file per date)")
	if ($1 != fdate) fail(line, "date " $1 " differs from the date of the file name " fdate)
}'

for f in "$DB"/data_set/*/data_set_*.txt; do
	[ -f "$f" ] || continue
	d=${f%/*}; d=${d##*/}
	b=${f##*/}
	case "$d" in run_?*) ;; *) echo "cawk error: $f: the directory must be run_<audit> ----"; TOTAL=$((TOTAL + 1)); continue ;; esac
	case "$b" in
	"data_set_${d#run_}_"[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9].txt) ;;
	*) echo "cawk error: $f: the file name must be data_set_${d#run_}_YYYY-MM-DD.txt ----"; TOTAL=$((TOTAL + 1)); continue ;;
	esac
	fdate=${b%.txt}; fdate=${fdate##*_}
	check_db "$f" "$DB_DATA_SET" "$fdate"
done

if [ "$TOTAL" -ne 0 ]; then
	echo "cawk error: check_database found badly formatted lines in $TOTAL database(s), see the errors above ----"
	exit 1
fi
echo "cawk check_database done ----"
