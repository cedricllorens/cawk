#!/bin/sh
# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------
#
# non-regression of database/censor/censor_regex.m4 : every line of validate/censor/cases.tsv is censored by
# common/censor.gawk at CENSOR_LEVEL=internal and CENSOR_LEVEL=external and the result is checked
#   censor : the secret disappears and the line holds CENSORED (an internal rule at both levels, an external rule at external only,
#            at internal the line of an external rule must stay intact)
#   keep   : the line stays intact at both levels
# the output modes of common/censor.gawk are checked too : CENSOR_OUT_FILE (one file into one file, the same
# result as CENSOR_OUT_DIR, exactly one input file, the output file must differ from the input file), the
# standard output, and CENSOR_MODE=check (the raw conf fails, the censored one passes, at both levels)
#
# usage : validate/censor/run.sh          (needs the compiled common/censor.gawk : gmake tests_target_common)
# ------------------------------------------------------------

cd "$(dirname "$0")/../.." || exit 1

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

[ -x common/censor.gawk ] || gmake tests_target_common > /dev/null 2>&1
gmake database/censor/censor_regex > /dev/null 2>&1 || { echo "cawk error: m4 failed on censor_regex.m4 ----"; exit 1; }

grep -v '^#' validate/censor/cases.tsv | awk -F'\t' '{ print $4 }' > "$work/conf"

fail=0
for level in internal external; do
	mkdir -p "$work/out_$level"
	CENSOR_LEVEL="$level" CENSOR_OUT_DIR="$work/out_$level" common/censor.gawk "$work/conf" || { echo "cawk error: censor.gawk failed at $level ----"; exit 1; }
	grep -v '^#' validate/censor/cases.tsv | awk -F'\t' -v level="$level" '
		FNR == NR { rule[NR] = $1; expect[NR] = $2; secret[NR] = $3; line[NR] = $4; n = NR; next }
		{
			i = FNR
			if (expect[i] == "keep" || (rule[i] == "external" && level == "internal")) {
				if ($0 != line[i]) { printf "NOK %s: <%s> must stay intact, got <%s>\n", level, line[i], $0; bad++ }
			} else {
				if (index($0, secret[i]) > 0) { printf "NOK %s: <%s> still holds <%s> : <%s>\n", level, line[i], secret[i], $0; bad++ }
				else if (index($0, "CENSORED") == 0) { printf "NOK %s: <%s> holds no CENSORED : <%s>\n", level, line[i], $0; bad++ }
			}
		}
		END { printf "cawk censor %s : %d cases, %d NOK ----\n", level, n, bad + 0; exit (bad > 0) }
	' - "$work/out_$level/conf" || fail=1
done

# CENSOR_OUT_FILE mode : one file into one file, the result must be the one of the CENSOR_OUT_DIR mode
CENSOR_LEVEL=internal CENSOR_OUT_FILE="$work/out_file.conf" common/censor.gawk "$work/conf" || { echo "cawk error: censor.gawk CENSOR_OUT_FILE failed ----"; exit 1; }
cmp -s "$work/out_file.conf" "$work/out_internal/conf" || { echo "NOK CENSOR_OUT_FILE: differs from the CENSOR_OUT_DIR result ----"; fail=1; }

# standard output mode : same content on the standard output
CENSOR_LEVEL=internal CENSOR_OUT_FILE=/dev/stdout common/censor.gawk "$work/conf" > "$work/out_stdout.conf" || { echo "cawk error: censor.gawk standard output failed ----"; exit 1; }
cmp -s "$work/out_stdout.conf" "$work/out_internal/conf" || { echo "NOK standard output: differs from the CENSOR_OUT_DIR result ----"; fail=1; }

# CENSOR_OUT_DIR mode with several files : one output file per input file, none overwritten
mkdir -p "$work/out_multi"
printf 'hostname router1\nsnmp-server community public RO\n' > "$work/conf2"
CENSOR_LEVEL=external CENSOR_OUT_DIR="$work/out_multi" common/censor.gawk "$work/conf" "$work/conf2" || { echo "cawk error: censor.gawk CENSOR_OUT_DIR multi failed ----"; exit 1; }
cmp -s "$work/out_multi/conf" "$work/out_external/conf" || { echo "NOK CENSOR_OUT_DIR multi: conf differs from the one-file result ----"; fail=1; }
if grep -q '^hostname CENSORED$' "$work/out_multi/conf2" && grep -q '^snmp-server community CENSORED$' "$work/out_multi/conf2"; then :; else
	echo "NOK CENSOR_OUT_DIR multi: conf2 not censored as expected ----"; fail=1
fi

# CENSOR_MODE=check : the raw conf holds secrets (exit 1), the censored one is clean (exit 0), at both levels
for level in internal external; do
	if CENSOR_MODE=check CENSOR_LEVEL="$level" common/censor.gawk "$work/conf" 2>/dev/null; then
		echo "NOK check $level: the raw conf must fail the check ----"; fail=1
	fi
	if ! CENSOR_MODE=check CENSOR_LEVEL="$level" common/censor.gawk "$work/out_$level/conf" 2>/dev/null; then
		echo "NOK check $level: the censored conf must pass the check ----"; fail=1
	fi
done

# the guards : two input files with CENSOR_OUT_FILE, an output file equal to the input file, a wrong CENSOR_MODE
cp "$work/conf" "$work/conf.ref"
if CENSOR_OUT_FILE="$work/out_2files.conf" common/censor.gawk "$work/conf" "$work/conf" 2>/dev/null; then
	echo "NOK CENSOR_OUT_FILE: two input files must be rejected ----"; fail=1
fi
if CENSOR_OUT_FILE="$work/conf" common/censor.gawk "$work/conf" 2>/dev/null; then
	echo "NOK CENSOR_OUT_FILE: the output file equal to the input file must be rejected ----"; fail=1
fi
cmp -s "$work/conf" "$work/conf.ref" || { echo "NOK CENSOR_OUT_FILE: the input file must stay intact ----"; fail=1; }
if CENSOR_MODE=bogus common/censor.gawk "$work/conf" 2>/dev/null; then
	echo "NOK CENSOR_MODE: a wrong mode must be rejected ----"; fail=1
fi

[ "$fail" = "0" ] && echo "cawk censor validation OK ----" || echo "cawk censor validation NOK ----"
exit "$fail"
