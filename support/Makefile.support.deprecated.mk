# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

# ===============================================================================
# DEPRECATED FUNCTIONS (regression detection)
# ===============================================================================

# DEPRECATED_FUNCTIONS (support/Makefile.support.vars.mk): extended regex of the deprecated test functions that must not appear in sources.
# Called from check_repo/check_run (not clean) since it is a source quality gate,
# not a cleanup step: check_repo/check_run compile *.gawk from templates, so this
# must run against the *.gawk.template/*.gawk.m4/*.gawk.include sources, before compilation.
# Detection only reports an error and never stops the assessment (no non-zero exit).

.PHONY: check_deprecated_repo check_deprecated_run check_deprecated_files check_censor_core check_integrity

# DEPRECATED_FILES (support/Makefile.support.vars.mk): old:new pairs of the files moved by a release; an old backup restore can put the old file back.
# Action on a detection: remove the pointed element (rm of the old file, the new one is the one in use). cawk removes nothing itself.
# An obsolete system file can silently skew an assessment: the error is always shown; exit 1 only when INTEGRITY_FATAL=yes.
check_deprecated_files:
	@mkdir -p $(PHASE_ERR_DIR) && rm -f $(PHASE_ERR_DIR)/*.err || { $(ECHO) "cawk error: cannot reset $(PHASE_ERR_DIR) ----"; exit 1; }; found=0; for p in $(DEPRECATED_FILES); do old=$${p%%:*}; new=$${p#*:}; if [ -e "$$old" ]; then m="obsolete file $$old detected (now $$new), remove it: rm $$old"; $(call cawk_phase_err,integrity); found=1; fi; done; if [ $$found -ne 0 ]; then if [ "$(INTEGRITY_FATAL)" = yes ]; then exit 1; fi; else $(ECHO_INFO) "cawk integrity check done: no obsolete file ----"; fi

# first prerequisite of check_repo and check_run (after check_audit): systematic integrity controls before any computation
# the censor rules of the installation (database/censor/censor_regex.m4) must include the core rules shipped by cawk (an old backup restore can bring back a file without the include):
# - no include: the file is saved once as .orig (never overwritten) and replaced by the template common/censor/censor_regex.m4
# - a .orig without include (the previous rules, possibly with rules of the user) is an error (reported without stopping, exit 1 only when INTEGRITY_FATAL=yes) until the user re-adds those rules to the new file and destroys the .orig,
#   so a censor rule of the user can never be dropped without notice
check_censor_core:
	@( err() { m="$$1"; $(call cawk_phase_err,integrity); }; \
	f=$(DATABASE_PATH)/censor/censor_regex.m4; tpl=$(TESTS_COMMON_PATH)/censor/censor_regex.m4; \
	if [ ! -f "$$tpl" ]; then err "$$tpl does not exist"; exit 1; fi; \
	if ! grep -q "^include(.censor_regex_core.m4.)" "$$f" 2>/dev/null; then \
		if [ -f "$$f.orig" ]; then err "$$f has no include of censor_regex_core.m4 and $$f.orig already exists, review the rules of $$f.orig, copy yours after the include of $$tpl into $$f, then destroy the file: rm $$f.orig"; exit 1; fi; \
		if [ -f "$$f" ]; then cp -p "$$f" "$$f.orig" || { err "cannot save $$f.orig"; exit 1; }; fi; \
		cp "$$tpl" "$$f" || { err "cannot copy $$tpl to $$f"; exit 1; }; \
		$(ECHO) "cawk $$f replaced by the template $$tpl (the previous file is kept in $$f.orig) ----"; \
	fi; \
	if [ -f "$$f.orig" ] && ! grep -q "^include(.censor_regex_core.m4.)" "$$f.orig"; then \
		err "$$f.orig holds the previous censor rules (no include of censor_regex_core.m4): copy your own rules after the include into $$f, then destroy the file: rm $$f.orig"; exit 1; \
	fi ); rc=$$?; if [ $$rc -ne 0 ] && [ "$(INTEGRITY_FATAL)" = yes ]; then exit 1; fi


check_integrity: check_deprecated_files check_censor_core $(NIST_REFERENCE)

check_deprecated_repo: check_deprecated_files
	@mkdir -p $(LOGS_PATH)/repo
	@if find $(TESTS_PATH)/repo -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -lE "$(DEPRECATED_FUNCTIONS)" {} + 2>$(LOGS_PATH)/repo/deprecated.repo.err | grep -q .; then \
		m="obsolete test function detected (DEPRECATED_FUNCTIONS=$(DEPRECATED_FUNCTIONS)), remove the calls from the test sources listed by: grep -rlE '$(DEPRECATED_FUNCTIONS)' $(TESTS_PATH)"; $(call cawk_phase_err,deprecated); \
	else \
		$(ECHO_INFO) "cawk deprecated check done: no obsolete test function under $(TESTS_PATH)/repo ----"; \
	fi

check_deprecated_run: check_deprecated_files
ifeq ($(strip $(audit)),)
	@mkdir -p $(LOGS_PATH)/run
	@if find $(TESTS_PATH)/run -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -lE "$(DEPRECATED_FUNCTIONS)" {} + 2>$(LOGS_PATH)/run/deprecated.run.err | grep -q .; then \
		m="obsolete test function detected (DEPRECATED_FUNCTIONS=$(DEPRECATED_FUNCTIONS)), remove the calls from the test sources listed by: grep -rlE '$(DEPRECATED_FUNCTIONS)' $(TESTS_PATH)"; $(call cawk_phase_err,deprecated); \
	else \
		$(ECHO_INFO) "cawk deprecated check done: no obsolete test function under $(TESTS_PATH)/run ----"; \
	fi
else
	@mkdir -p $(LOGS_PATH)/run_$(audit)
	@if find $(TESTS_PATH)/run_$(audit) -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -lE "$(DEPRECATED_FUNCTIONS)" {} + 2>$(LOGS_PATH)/run_$(audit)/deprecated.$(audit).err | grep -q .; then \
		m="obsolete test function detected (DEPRECATED_FUNCTIONS=$(DEPRECATED_FUNCTIONS)), remove the calls from the test sources listed by: grep -rlE '$(DEPRECATED_FUNCTIONS)' $(TESTS_PATH)"; $(call cawk_phase_err,deprecated); \
	else \
		$(ECHO_INFO) "cawk deprecated check done: no obsolete test function under $(TESTS_PATH)/run_$(audit) ----"; \
	fi
endif
