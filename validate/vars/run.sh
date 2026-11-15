#!/bin/sh
# non-regression of the variables: every cawk variable lives in support/Makefile.support.vars.mk and nowhere else,
# is explained by `gmake help vars`, and every option (?=) is described in docs/CAWK_OPTIONS.md
[ -f Makefile ] && [ -d support ] || { echo "cawk error: run this script from the cawk root ----"; exit 1; }
VARS=support/Makefile.support.vars.mk
fail=0
nok() { echo "cawk error: validate/vars: $1 ----"; fail=1; }
[ -f $VARS ] || { nok "$VARS not found"; exit 1; }

# top-level assignments of a makefile (outside define ... endef): "NAME op" one per line
assigns() {
	gawk '
		/^define[ \t]/ { d++; next }
		/^endef/ { if (d > 0) d--; next }
		d > 0 { next }
		/^(export|override)[ \t]+/ { sub(/^(export|override)[ \t]+/, "") }
		/^[A-Za-z_][A-Za-z0-9_]*[ \t]*(::|:|\?|\+)?=/ { n = $0; sub(/[ \t]*(::|:|\?|\+)?=.*/, "", n); op = $0; sub(/^[A-Za-z_][A-Za-z0-9_]*[ \t]*/, "", op); sub(/=.*/, "=", op); print n, op }
	' "$1"
}

# 1 vars.mk is the first include of the Makefile
first=$(sed -n 's/^include //p' Makefile | head -n 1)
[ "$first" = "$VARS" ] || nok "the first include of Makefile is <$first>, expected $VARS"

# 2 no variable assigned elsewhere
for f in Makefile support/Makefile.support*.mk; do
	[ "$f" = "$VARS" ] && continue
	bad=$(assigns "$f" | tr '\n' ',')
	[ -z "$bad" ] || nok "$f assigns variable(s) outside $VARS: $bad"
done

# 3 every variable of vars.mk is explained by gmake help vars (the generated per-supplier ones are in a define, explained as families)
helpvars=$(gmake help vars HELP_NOLOGO=yes 2>&1) || nok "gmake help vars failed"
names=$(assigns $VARS | gawk '{ print $1 }' | sort -u)
[ -n "$names" ] || nok "no variable found in $VARS"
for v in $names; do
	echo "$helpvars" | grep -qE "(^# |[ ,(])$v([ ,)]|\$)" || nok "$v is not explained in gmake help vars (help_vars of support/Makefile.support.help.mk)"
done

# 4 every option (?=) is described in docs/CAWK_OPTIONS.md (RM and GMAKE are commands, not options)
for v in $(assigns $VARS | gawk '$2 == "?=" { print $1 }' | grep -vxE 'RM|GMAKE'); do
	grep -q "\`$v\`" docs/CAWK_OPTIONS.md || nok "option $v is not described in docs/CAWK_OPTIONS.md"
done

[ $fail -eq 0 ] && echo "cawk validate/vars done ----"
exit $fail
