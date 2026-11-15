#!/bin/sh
# usage: support/audit_status.sh AUDIT_NAME  (run from the cawk root): where a named audit stands, and the next command
[ -f Makefile ] && [ -d support ] || { echo "cawk error: run this script from the cawk root ----"; exit 1; }
a=$1
[ -n "$a" ] || { echo "cawk error: audit= must be set (usage: gmake status audit=<name>, list the audits with: gmake list_audit) ----"; exit 1; }
confs=confs/run_$a; tests=tests/run_$a; rep=reports/run_$a; exc=exceptions/run_$a; col=confs/collect_$a
for d in "$confs" "$tests" "$rep"; do
	[ -d "$d" ] || { echo "cawk error: audit $a is incomplete, $d is missing (recreate it with: gmake create_audit audit=$a) ----"; exit 1; }
done
csv=$rep/assessment.all.csv
day() { ls -ld --time-style=+%Y-%m-%d "$1" | awk '{ print $6 }'; }

echo "cawk status of audit <$a> ----"

# confs: one folder confs.<supplier> per supplier, one file per device (symbolic links created by the sync)
total=0; list=
for d in "$confs"/confs.*; do
	[ -d "$d" ] || continue
	case $d in *.censored) continue ;; esac
	n=$(find -H "$d" -type f | wc -l) || { echo "cawk error: cannot count the configurations of $d ----"; exit 1; }
	[ "$n" -gt 0 ] || continue
	total=$((total + n)); list="$list${list:+, }${d##*/confs.} $n"
done
echo "  confs      : ${list:-none} (total $total)"

ds=database/data_set/run_$a
nds=$(find "$ds" -name "data_set_${a}_*.txt" -type f 2>/dev/null | wc -l)
if [ "$nds" -gt 0 ]; then
	last=$(find "$ds" -name "data_set_${a}_*.txt" -type f | sort | tail -n 1)
	echo "  data_set   : $nds date(s), last $(basename "$last" .txt | sed "s/^data_set_${a}_//") ($ds)"
else
	echo "  data_set   : none (created by gmake create_audit, filled by gmake check_run audit=$a)"
fi

if [ -d "$col" ]; then
	echo "  collect    : $(find -H "$col" -type f | wc -l) raw files in $col"
else
	echo "  collect    : no collector files (optional)"
fi

compiled=$(find -H "$tests" -name '*.gawk' -type f | wc -l)
if [ "$compiled" -eq 0 ]; then echo "  tests      : not compiled"
elif [ -n "$(find -H "$tests" -name '*.gawk.*' -type f -newer "$(find -H "$tests" -name '*.gawk' -type f | head -1)" | head -1)" ]; then
	echo "  tests      : $compiled compiled, a source is newer than the build"
else echo "  tests      : $compiled compiled"; fi

stale=
if [ -f "$csv" ]; then
	sum=$(awk -F';' '$6 == "error" || $6 == "warning" || $6 == "psirt" || $6 == "pass" { c[$6]++ } END { printf "error %d | warning %d | psirt %d | pass %d", c["error"], c["warning"], c["psirt"], c["pass"] }' "$csv") \
		|| { echo "cawk error: cannot read $csv ----"; exit 1; }
	echo "  assessment : $(day "$csv"), $sum"
	[ -z "$(find -H "$confs" -type f -newer "$csv" 2>/dev/null | head -1)" ] || stale=yes
	[ -z "$stale" ] || echo "  assessment : the configurations are newer than the report"
else
	echo "  assessment : none yet"
fi

nexc=0
for f in "$exc"/exceptions.*; do
	[ -f "$f" ] || continue
	case $f in *.m4) continue ;; esac
	nexc=$((nexc + $(grep -vc '^[[:space:]]*\(#\|$\)' "$f")))
done
echo "  exceptions : $nexc rules"

cen=
[ -z "$(ls -d "$confs"/confs.*.censored 2>/dev/null | head -1)" ] || cen="confs"
[ ! -d "logs/run_$a.censored" ] || cen="$cen${cen:+, }logs"
[ ! -d "$rep.censored" ] || cen="$cen${cen:+, }reports"
echo "  censored   : ${cen:-nothing}"

if [ "$total" -eq 0 ]; then next="gmake sync_run audit=$a (or gmake collect_run audit=$a first when a collector is declared)"
elif [ ! -f "$csv" ] || [ -n "$stale" ]; then next="gmake clean check_run view_run audit=$a"
elif [ ! -d "$rep.censored" ]; then next="gmake view_run audit=$a (then gmake censor_report_run audit=$a before sharing)"
else next="gmake view_run audit=$a"; fi
echo "  next step  : $next"
echo "cawk status done ----"
