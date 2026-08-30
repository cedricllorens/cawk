# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

.PHONY: \
  database_target_sh tests_check tests_check_nok tests_common  \
  tests_repo tests_run tests_run_audit tests_run_audit_copy  \
  tests_run_copy tests_target_common tests_target_repo tests_target_run


tests_target_common: $(TESTS_COMMON_TEMPLATE:.gawk.template=.gawk) $(TESTS_COMMON_SH:.script.sh=.script)

database_target_sh: $(DATABASE_SH:.script.sh=.script)

tests_check: tests_target_common tests_target_repo tests_target_run
	find tests -name '*.gawk' -type f -exec common/check_test.gawk {} \; | awk '/cawk test pass/ {print "\033[32m" $$0 "\033[0m"} !/cawk test pass/ {print "\033[31m" $$0 "\033[0m"}'
	$(ECHO) "cawk tests_check done ----"

tests_check_nok: tests_target_common tests_target_repo tests_target_run
	find tests -name '*.gawk' -type f -exec common/check_test.gawk {} \; | awk '/cawk test pass/ {print "\033[32m" $$0 "\033[0m"} !/cawk test pass/ {print "\033[31m" $$0 "\033[0m"}' | $(EGREP) "cawk test error" || true
	$(ECHO) "cawk tests_check done ----"

tests_target_repo: tests_target_common \
		$(SUPPLIER_M4_REPO_FILES) \
		$(SUPPLIER_M4_REPO_PSIRT_FILES) \
		$(SUPPLIER_TEMPLATE_REPO_FILES) \
		$(SUPPLIER_TEMPLATE_REPO_PSIRT_FILES) \
		$(SUPPLIER_INCLUDE_REPO_PSIRT_FILES)

tests_target_run: tests_target_common \
		$(SUPPLIER_M4_RUN_FILES) \
		$(SUPPLIER_M4_RUN_PSIRT_FILES) \
		$(SUPPLIER_TEMPLATE_RUN_FILES) \
		$(SUPPLIER_TEMPLATE_RUN_PSIRT_FILES) \
		$(SUPPLIER_INCLUDE_RUN_PSIRT_FILES)

tests_common: tests_target_common
	$(ECHO) "cawk tests_common done ----"

tests_repo: tests_target_repo
	$(ECHO) "cawk tests_repo done ----"

# -----
# OVERWRITE : if tests exist at target, tests are copied
# -----
tests_run_copy:
	@RUN_TARGET="$(TESTS_PATH)/run"; \
	if [ -n "$(audit)" ]; then RUN_TARGET="$(TESTS_PATH)/run_$(audit)"; fi; \
	for supplier in $(SUPPLIER_SCOPE); do \
		if [ ! -d "$(TESTS_PATH)/repo/tests.$$supplier" ]; then \
			$(ECHO) "cawk error: $(TESTS_PATH)/repo/tests.$$supplier does not exist ----"; \
		elif [ -d "$(TESTS_PATH)/repo/tests.$$supplier" ]; then \
			$(ECHO) "cawk tests_repo_copy $$supplier to $$RUN_TARGET start ----"; \
			mkdir -p $$RUN_TARGET/tests.$$supplier || true; \
			find $(TESTS_PATH)/repo/tests.$$supplier -name "*.template" -exec cp -v {} $$RUN_TARGET/tests.$$supplier/ \; 2>/dev/null || true; \
			find $(TESTS_PATH)/repo/tests.$$supplier -name "*.m4" -exec cp -v {} $$RUN_TARGET/tests.$$supplier/ \; 2>/dev/null || true; \
			$(ECHO) "cawk tests_repo_copy $$supplier to $$RUN_TARGET done ----"; \
		fi; \
		if [ ! -d "$(TESTS_PATH)/repo/tests.$$supplier.psirt" ]; then \
			$(ECHO) "cawk error: $(TESTS_PATH)/repo/tests.$$supplier.psirt does not exist ----"; \
		elif [ -d "$(TESTS_PATH)/repo/tests.$$supplier.psirt" ]; then \
			$(ECHO) "cawk tests_repo_copy $$supplier.psirt to $$RUN_TARGET start ----"; \
			mkdir -p $$RUN_TARGET/tests.$$supplier.psirt || true; \
			find $(TESTS_PATH)/repo/tests.$$supplier.psirt -name "*.template" -exec cp -v {} $$RUN_TARGET/tests.$$supplier.psirt/ \; 2>/dev/null || true; \
			find $(TESTS_PATH)/repo/tests.$$supplier.psirt -name "*.m4" -exec cp -v {} $$RUN_TARGET/tests.$$supplier.psirt/ \; 2>/dev/null || true; \
			find $(TESTS_PATH)/repo/tests.$$supplier.psirt -name "*.include" -exec cp -v {} $$RUN_TARGET/tests.$$supplier.psirt/ \; 2>/dev/null || true; \
			$(ECHO) "cawk tests_repo_copy $$supplier.psirt to $$RUN_TARGET done ----"; \
		fi; \
	done; \
	$(ECHO) "cawk tests_run_copy done ----"

tests_run_audit_copy:
	for dir in $(RUN_DIRS); do \
		$(GMAKE) tests_run_copy audit=$$dir; \
	done
	$(ECHO) "cawk tests_run_audit_copy done ----"

tests_run: tests_target_run
	$(ECHO) "cawk tests_run audit=${audit} done ----"

tests_run_audit:
	@for dir in $(RUN_DIRS); do \
		$(GMAKE) tests_run audit=$$dir; \
	done
	$(ECHO) "cawk tests_run_audit done ----"


