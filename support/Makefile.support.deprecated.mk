# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

# ===============================================================================
# DEPRECATED FUNCTIONS (regression detection)
# ===============================================================================

# Extended regex pattern of deprecated test functions that must not appear in sources
# Called from check_repo/check_run (not clean) since it is a source quality gate,
# not a cleanup step: check_repo/check_run compile *.gawk from templates, so this
# must run against the *.gawk.template/*.gawk.m4/*.gawk.include sources, before compilation.
# Detection only reports an error and never stops the assessment (no non-zero exit).
DEPRECATED_FUNCTIONS = (awk_init_fw_rules)

.PHONY: check_deprecated_repo check_deprecated_run

check_deprecated_repo:
	@mkdir -p $(LOGS_PATH)/repo
	@if find $(TESTS_PATH)/repo -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -lE "$(DEPRECATED_FUNCTIONS)" {} + 2>$(LOGS_PATH)/repo/deprecated.repo.err | grep -q .; then \
		$(ECHO) "cawk error: obsolete test function detected and must be removed"; \
	else \
		$(ECHO) "cawk deprecated check done: no obsolete test function under $(TESTS_PATH)/repo ----"; \
	fi

check_deprecated_run:
ifeq ($(strip $(audit)),)
	@mkdir -p $(LOGS_PATH)/run
	@if find $(TESTS_PATH)/run -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -lE "$(DEPRECATED_FUNCTIONS)" {} + 2>$(LOGS_PATH)/run/deprecated.run.err | grep -q .; then \
		$(ECHO) "cawk error: obsolete test function detected and must be removed"; \
	else \
		$(ECHO) "cawk deprecated check done: no obsolete test function under $(TESTS_PATH)/run ----"; \
	fi
else
	@mkdir -p $(LOGS_PATH)/run_$(audit)
	@if find $(TESTS_PATH)/run_$(audit) -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -lE "$(DEPRECATED_FUNCTIONS)" {} + 2>$(LOGS_PATH)/run_$(audit)/deprecated.$(audit).err | grep -q .; then \
		$(ECHO) "cawk error: obsolete test function detected and must be removed"; \
	else \
		$(ECHO) "cawk deprecated check done: no obsolete test function under $(TESTS_PATH)/run_$(audit) ----"; \
	fi
endif
