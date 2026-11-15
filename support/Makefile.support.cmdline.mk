# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

# Unknown NAME=value on the command line (PSIRT_ONY=yes): cawk error and stop before any target runs, whatever the target.
# Included right after support/Makefile.support.vars.mk, the check runs at parse time: nothing else is executed.
# Accepted: the variables of vars.mk and CMDLINE_PARAMS. The names of vars.mk are only read (one sed) when a command line variable is not a parameter.

define cawk_cmdline_names
$(foreach v,$(.VARIABLES),$(if $(filter command line,$(origin $(v))),$(v)))
endef

define cawk_cmdline_valid
$(CMDLINE_PARAMS) $(shell sed -n 's/^\(export \|override \)\{0,1\}\([A-Za-z_][A-Za-z0-9_]*\)[ \t]*[:?+]*=.*/\2/p' support/Makefile.support.vars.mk)
endef

define cawk_cmdline_unknown
$(if $(filter-out $(CMDLINE_PARAMS),$(cawk_cmdline_names)),$(filter-out $(cawk_cmdline_valid),$(cawk_cmdline_names)))
endef

# one message per unknown name: the closest known names (substring, then up to 2 typos, also as upper and lower case); the generated per-supplier variables are not suggested
define cawk_cmdline_one
n='$(subst ','\'',$(1))'; sim=$$(printf '%s:\n' $$valid | gawk -v t="$$n" -f support/similar_target.awk); [ -n "$$sim" ] || sim=$$(printf '%s:\n' $$valid | gawk -v t="$$(printf '%s' "$$n" | tr a-z A-Z)" -f support/similar_target.awk); [ -n "$$sim" ] || sim=$$(printf '%s:\n' $$valid | gawk -v t="$$(printf '%s' "$$n" | tr A-Z a-z)" -f support/similar_target.awk); $(ECHO) "cawk error: unknown option <$$n>$${sim:+, did you mean: $$sim} (the options are explained by: $(GMAKE) help vars, search a word with: $(GMAKE) help topic=WORD) ----";
endef

# the prerequisites of the rule with a recipe come before any other one: a rule could not stop the targets in time
ifneq ($(strip $(cawk_cmdline_unknown)),)
$(shell { valid='$(filter-out SUPPLIER_% CONFIGURATION_% TESTS_%,$(strip $(cawk_cmdline_valid)))'; $(foreach u,$(cawk_cmdline_unknown),$(call cawk_cmdline_one,$(u))) true; } >&2)
$(error stopped by the unknown option(s) above)
endif
