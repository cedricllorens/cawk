# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------


include Makefile.support.mk


.PHONY: all

all: help


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# HELP TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


include Makefile.support.help.mk


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# ROLES FOR FUTURE USAGE / DRAFT SECTION
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


include Makefile.support.role.mk


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# CREATE/DELETE AUDIT MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


include Makefile.support.audit.mk


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# DATABASE MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


include Makefile.support.database.mk


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# SYNC MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


include Makefile.support.sync.mk


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# POSTAUDIT MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


include Makefile.support.postaudit.mk


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# EMAIL MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


include Makefile.support.email.mk


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# BACKUP/RESTORE MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


include Makefile.support.backup.mk


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# SUPPLIER MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


include Makefile.support.supplier.mk


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# TESTS MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


include Makefile.support.tests.mk


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# CHECK_REPO MANAGEMENT TARGETS
# ------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------

.PHONY: check_repo

check_repo: clean_report_repo clean_tmp $(if $(filter yes,$(CATALOG_BUILD)),catalog_build) exceptions_repo tests_repo check_supplier
ifneq ($(strip $(audit)),)
	$(ECHO) "cawk error the use of <audit=AUDIT_NAME> can only be used with check_run target ----"
	exit 0
else
ifeq ($(strip $(supplier)),)
ifeq ($(strip $(MAKE_PARALLEL)),no)

# --------------------------------------------------
# case: supplier = no  | parallel = no  | audit = no
# --------------------------------------------------

# DEADBEEF ----
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(call cawk_deadbeef_scan,$(scope),REPO,repo) \
	)
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/repo/assessment.all.deadbeef.csv > $(REPORT_PATH)/repo/assessment.all.deadbeef.idx
# RUN && PSIRT ----
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(ECHO) "cawk compute repo $(scope) devices ----" ;\
		\
		$(if $(filter no,$(PSIRT)),\
			$(foreach test,$(shell find $(TESTS_$(scope)_REPO_PATH) -name '*.gawk' -type f 2>/dev/null || true),\
				find $(CONFIGURATION_$(scope)_REPO_PATH) $(FIND_CONF_SELECT) $(TEST_EXE) >> $(REPORT_PATH)/repo/assessment.$(scope).csv.swap 2>/dev/null || true ;\
			),\
			touch $(REPORT_PATH)/repo/assessment.$(scope).csv.swap ;\
		) \
		$(foreach test,$(shell find $(TESTS_$(scope)_REPO_PSIRT_PATH) -name '*.gawk' -type f 2>/dev/null || true),\
			find $(CONFIGURATION_$(scope)_REPO_PATH) $(FIND_CONF_SELECT) $(TEST_EXE) >> $(REPORT_PATH)/repo/assessment.$(scope).csv.swap 2>/dev/null || true ;\
		) \
	)
# CONTEXT LOCAL REPORT ----
	$(call cawk_catalog_precompute,catalog_repo,catalog_exceptions_repo,repo)
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(EGREP) -v -f $(EXCEPTION_PATH)/repo/exceptions.$(scope) $(REPORT_PATH)/repo/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/repo/assessment.$(scope).csv || true ;\
		cat $(REPORT_PATH)/repo/assessment.$(scope).csv >> $(REPORT_PATH)/repo/assessment.all.csv.swap ;\
		$(EGREP) -f $(EXCEPTION_PATH)/repo/exceptions.$(scope) $(REPORT_PATH)/repo/assessment.$(scope).csv.swap | $(EGREP) ';error' | sort -u > $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv || true ;\
		cat $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv >> $(REPORT_PATH)/repo/assessment.all.exception.csv ;\
		$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/repo/assessment.all.deadbeef.csv $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv $(REPORT_PATH)/repo/assessment.$(scope).csv > $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
	)
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt;\
		$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt;\
		cat $(TESTS_TMP)/catalog_tests.repo.txt >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
		$(ECHO) "------------------------------" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt;\
		$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt;\
		$(ECHO) "------------------------------" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt;\
		cat $(TESTS_TMP)/catalog_exceptions.repo.txt >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
	)
# CONTEXT ALL REPORT ----
	$(call cawk_report_scope_all,$(REPORT_PATH)/repo,repo)
else

# --------------------------------------------------
# case: supplier = no  | parallel = yes | audit = no
# --------------------------------------------------

# DEADBEEF ----
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(call cawk_deadbeef_scan,$(scope),REPO,repo) \
	)
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/repo/assessment.all.deadbeef.csv > $(REPORT_PATH)/repo/assessment.all.deadbeef.idx
# RUN && PSIRT ----
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(ECHO) "cawk compute repo $(scope) devices (parallel mode) ----" ;\
		$(call cawk_test_gen_parallel,$(scope),REPO,repo,repo) \
	)
	$(foreach scope,$(SUPPLIER_SCOPE),\
		find $(TESTS_$(scope)_REPO_PSIRT_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.repo.psirt.$(scope) 2>/dev/null || true ;\
		$(TESTS_COMMON_PATH)/gen_cawk_makefile.psirt.gawk $(TESTS_TMP)/conf_list_files.repo.$(scope) $(MAKE_FILES_PER_TARGET_PSIRT) $(TESTS_TMP)/conf_list_tests.repo.psirt.$(scope) > $(TESTS_TMP)/Makefile.repo.psirt.$(scope) 2>/dev/null || true ;\
		$(GMAKE) -f $(TESTS_TMP)/Makefile.repo.psirt.$(scope) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all >> $(REPORT_PATH)/repo/assessment.$(scope).csv.swap 2>/dev/null || true ;\
	)
# CONTEXT LOCAL REPORT ----
	$(call cawk_catalog_precompute,catalog_repo,catalog_exceptions_repo,repo)
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(EGREP) -v -f $(EXCEPTION_PATH)/repo/exceptions.$(scope) $(REPORT_PATH)/repo/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/repo/assessment.$(scope).csv || true ;\
		cat $(REPORT_PATH)/repo/assessment.$(scope).csv >> $(REPORT_PATH)/repo/assessment.all.csv.swap ;\
		$(EGREP) -f $(EXCEPTION_PATH)/repo/exceptions.$(scope) $(REPORT_PATH)/repo/assessment.$(scope).csv.swap | $(EGREP) ';error' | sort -u > $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv || true ;\
		cat $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv >> $(REPORT_PATH)/repo/assessment.all.exception.csv ;\
		$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/repo/assessment.all.deadbeef.csv $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv $(REPORT_PATH)/repo/assessment.$(scope).csv > $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
		$(ECHO) "------------------------\n---- tests purposes ----\n------------------------" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt;\
		cat $(TESTS_TMP)/catalog_tests.repo.txt >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
		$(ECHO) "------------------------------\n---- exceptions purposes ----\n------------------------------" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt;\
		cat $(TESTS_TMP)/catalog_exceptions.repo.txt >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
	)
# CONTEXT ALL REPORT ----
	$(call cawk_report_scope_all,$(REPORT_PATH)/repo,repo)
endif
else
ifeq ($(strip $(MAKE_PARALLEL)),no)

# --------------------------------------------------
# case: supplier = yes | parallel = no  | audit = no
# --------------------------------------------------

	$(ECHO) "cawk compute repo $(supplier) devices ----"
# DEADBEEF ----
	$(call cawk_deadbeef_scan,$(supplier),REPO,repo)
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/repo/assessment.all.deadbeef.csv > $(REPORT_PATH)/repo/assessment.all.deadbeef.idx
# RUN && PSIRT ----
	$(call cawk_test_execution,$(TESTS_$(supplier)_REPO_PATH),$(CONFIGURATION_$(supplier)_REPO_PATH),$(REPORT_PATH)/repo/assessment.$(supplier).csv.swap,$(TESTS_$(supplier)_REPO_PSIRT_PATH))
# CONTEXT LOCAL REPORT ----
	$(call cawk_catalog_precompute,catalog_repo,catalog_exceptions_repo,repo)
	$(call cawk_report_scope_local,$(supplier),repo,repo,repo)
# CONTEXT ALL REPORT ----
	$(call cawk_report_scope_all,$(REPORT_PATH)/repo,repo)
else

# --------------------------------------------------
# case: supplier = yes | parallel = yes | audit = no
# --------------------------------------------------

	$(ECHO) "cawk repo compute $(supplier) devices (parallel mode) ----"
# DEADBEEF ----
	$(call cawk_deadbeef_scan,$(supplier),REPO,repo)
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/repo/assessment.all.deadbeef.csv > $(REPORT_PATH)/repo/assessment.all.deadbeef.idx
# RUN && PSIRT ----
	$(call cawk_test_gen_parallel,$(supplier),REPO,repo,repo)
	find $(TESTS_$(supplier)_REPO_PSIRT_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.repo.psirt.$(supplier) 2>/dev/null || true ;\
	$(TESTS_COMMON_PATH)/gen_cawk_makefile.psirt.gawk $(TESTS_TMP)/conf_list_files.repo.$(supplier) $(MAKE_FILES_PER_TARGET_PSIRT) $(TESTS_TMP)/conf_list_tests.repo.psirt.$(supplier) > $(TESTS_TMP)/Makefile.repo.psirt.$(supplier) 2>/dev/null || true ;\
	$(GMAKE) -f $(TESTS_TMP)/Makefile.repo.psirt.$(supplier) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all >> $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap 2>/dev/null || true
# CONTEXT LOCAL REPORT ----
	$(call cawk_catalog_precompute,catalog_repo,catalog_exceptions_repo,repo)
	$(call cawk_report_scope_local,$(supplier),repo,repo,repo)
# CONTEXT ALL REPORT ----
	$(call cawk_report_scope_all,$(REPORT_PATH)/repo,repo)
endif
endif
endif
	$(GMAKE) archive_repo
	$(ECHO) "cawk check_repo done ----"


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# CHECK_RUN MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------

.PHONY: check_run

check_run: clean_tmp $(if $(filter yes,$(CATALOG_BUILD)),catalog_build) exceptions_run tests_run check_supplier
ifeq ($(strip $(audit)),)
	$(GMAKE) clean_report_run
else
	$(GMAKE) clean_report_run audit=$(audit)
endif
ifeq ($(strip $(supplier)),)
ifeq ($(strip $(MAKE_PARALLEL)),no)
ifeq ($(strip $(audit)),)

# ---------------------------------------------------
# case: supplier = no  | parallel = no  | audit = no
# ---------------------------------------------------

# DEADBEEF ----
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(call cawk_deadbeef_scan,$(scope),RUN,run) \
	)
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/run/assessment.all.deadbeef.csv > $(REPORT_PATH)/run/assessment.all.deadbeef.idx
# RUN && PSIRT ----
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(ECHO) "cawk compute run $(scope) devices ----" ;\
		$(if $(filter no,$(PSIRT)),\
			$(foreach test,$(shell find $(TESTS_$(scope)_RUN_PATH) -name '*.gawk' -type f  2>/dev/null || true),\
				find $(CONFIGURATION_$(scope)_RUN_PATH) $(FIND_CONF_SELECT) $(TEST_EXE) >> $(REPORT_PATH)/run/assessment.$(scope).csv.swap 2>/dev/null || true ;\
			),\
			touch $(REPORT_PATH)/run/assessment.$(scope).csv.swap ;\
		) \
	)
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(foreach test,$(shell find $(TESTS_$(scope)_RUN_PSIRT_PATH) -name '*.gawk' -type f 2>/dev/null || true),\
			find $(CONFIGURATION_$(scope)_RUN_PATH) $(FIND_CONF_SELECT) $(TEST_EXE) >> $(REPORT_PATH)/run/assessment.$(scope).csv.swap 2>/dev/null || true ;\
		) \
	)
# CONTEXT LOCAL REPORT ----
# exception ---
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(EGREP) -v -f $(EXCEPTION_PATH)/run/exceptions.$(scope) $(REPORT_PATH)/run/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/run/assessment.$(scope).csv || true ;\
		cat $(REPORT_PATH)/run/assessment.$(scope).csv >> $(REPORT_PATH)/run/assessment.all.csv.swap ;\
		$(EGREP) -f $(EXCEPTION_PATH)/run/exceptions.$(scope) $(REPORT_PATH)/run/assessment.$(scope).csv.swap | $(EGREP) ';error' | sort -u > $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv || true ;\
		cat $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv >> $(REPORT_PATH)/run/assessment.all.exception.csv ;\
	)
# local ----
	$(call cawk_catalog_precompute,catalog_run,catalog_exceptions_run,run)
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/run/assessment.all.deadbeef.csv $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv $(REPORT_PATH)/run/assessment.$(scope).csv > $(REPORT_PATH)/run/assessment.$(scope).summary.txt ;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		cat $(TESTS_TMP)/catalog_tests.run.txt >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "------------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "------------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		cat $(TESTS_TMP)/catalog_exceptions.run.txt >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
	)
# CONTEXT ALL REPORT ----
	$(call cawk_report_scope_all,$(REPORT_PATH)/run,run)
else
ifeq ($(wildcard $(REPORT_PATH)/run_$(audit)/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
	exit 0
else

# ---------------------------------------------------
# case: supplier = no  | parallel = no  | audit = yes
# ---------------------------------------------------

# DEADBEEF ----
	$(foreach scope,$(SUPPLIER_SCOPE),\
		if [ ! -d "$(CONFIGURATION_$(scope)_RUN_PATH)" ] || [ ! -d "$(TESTS_$(scope)_RUN_PATH)" ]; then \
			touch $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap; \
		else \
			$(call cawk_deadbeef_scan,$(scope),RUN,run_${audit}) \
		fi; \
	)
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv > $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.idx
# RUN && PSIRT ----
	$(foreach scope,$(SUPPLIER_SCOPE),\
		if [ ! -d "$(CONFIGURATION_$(scope)_RUN_PATH)" ] || ([ ! -d "$(TESTS_$(scope)_RUN_PATH)" ] && [ ! -d "$(TESTS_$(scope)_RUN_PSIRT_PATH)" ]); then \
			$(ECHO) "cawk $(CONFIGURATION_$(scope)_RUN_PATH) or $(TESTS_$(scope)_RUN_PATH) do not exist, skip the ${audit} $(scope) assessment ----"; \
			touch $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv; \
		fi; \
	)
	$(foreach scope,$(SUPPLIER_SCOPE),\
		if [ -d "$(CONFIGURATION_$(scope)_RUN_PATH)" ] && ([ -d "$(TESTS_$(scope)_RUN_PATH)" ] || [ -d "$(TESTS_$(scope)_RUN_PSIRT_PATH)" ]); then \
			$(ECHO) "cawk compute run_${audit} $(scope) devices ----" ;\
			$(if $(filter no,$(PSIRT)),\
				$(foreach test,$(shell find $(TESTS_$(scope)_RUN_PATH) -name '*.gawk' -type f  2>/dev/null || true),\
					find $(CONFIGURATION_$(scope)_RUN_PATH) $(FIND_CONF_SELECT) $(TEST_EXE) >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap 2>/dev/null || true ;\
				),\
				touch $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap;\
			) \
			$(foreach test,$(shell find $(TESTS_$(scope)_RUN_PSIRT_PATH) -name '*.gawk' -type f 2>/dev/null || true),\
				find $(CONFIGURATION_$(scope)_RUN_PATH) $(FIND_CONF_SELECT) $(TEST_EXE) >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap 2>/dev/null || true ;\
			) \
		fi; \
	)
# CONTEXT LOCAL REPORT ----
# exception ---
	$(foreach scope,$(SUPPLIER_SCOPE),\
		if [ -d "$(CONFIGURATION_$(scope)_RUN_PATH)" ] && ([ -d "$(TESTS_$(scope)_RUN_PATH)" ] || [ -d "$(TESTS_$(scope)_RUN_PSIRT_PATH)" ]); then \
			$(EGREP) -v -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(scope) $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv || true ;\
			cat $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv >> $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap ;\
			$(EGREP) -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(scope) $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap | $(EGREP) ';error' | sort -u > $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv || true ;\
			cat $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv >> $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv ;\
		fi; \
	)
# local ---
	$(call cawk_catalog_precompute,catalog_run audit=$(audit),catalog_exceptions_run audit=$(audit),$(audit))
	$(foreach scope,$(SUPPLIER_SCOPE),\
		if [ -d "$(CONFIGURATION_$(scope)_RUN_PATH)" ] && ([ -d "$(TESTS_$(scope)_RUN_PATH)" ] || [ -d "$(TESTS_$(scope)_RUN_PSIRT_PATH)" ]); then \
			$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv > $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt ;\
			$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			cat $(TESTS_TMP)/catalog_tests.$(audit).txt >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			cat $(TESTS_TMP)/catalog_exceptions.$(audit).txt >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
		fi; \
	)
# ALL LOCAL ----
	$(call cawk_report_scope_all,$(REPORT_PATH)/run_$(audit),$(audit))	
endif
endif
else
ifeq ($(strip $(audit)),)

# ---------------------------------------------------
# case: supplier = no  | parallel = yes | audit = no
# ---------------------------------------------------

# DEADBEEF ----
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(call cawk_deadbeef_scan,$(scope),RUN,run) \
	)
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/run/assessment.all.deadbeef.csv > $(REPORT_PATH)/run/assessment.all.deadbeef.idx
# RUN && PSIRT ----
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(ECHO) "cawk compute run $(scope) devices (parallel mode) ----" ;\
		$(call cawk_test_gen_parallel,$(scope),RUN,run,run) \
	)
	$(foreach scope,$(SUPPLIER_SCOPE),\
		find $(TESTS_$(scope)_RUN_PSIRT_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.run.psirt.$(scope) 2>/dev/null || true ;\
		$(TESTS_COMMON_PATH)/gen_cawk_makefile.psirt.gawk $(TESTS_TMP)/conf_list_files.run.$(scope) $(MAKE_FILES_PER_TARGET_PSIRT) $(TESTS_TMP)/conf_list_tests.run.psirt.$(scope) > $(TESTS_TMP)/Makefile.run.psirt.$(scope) 2>/dev/null || true ;\
		$(GMAKE) -f $(TESTS_TMP)/Makefile.run.psirt.$(scope) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all >> $(REPORT_PATH)/run/assessment.$(scope).csv.swap 2>/dev/null || true ;\
	)
# CONTEXT LOCAL REPORT ----
# exception ---
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(EGREP) -v -f $(EXCEPTION_PATH)/run/exceptions.$(scope) $(REPORT_PATH)/run/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/run/assessment.$(scope).csv || true ;\
		cat $(REPORT_PATH)/run/assessment.$(scope).csv >> $(REPORT_PATH)/run/assessment.all.csv.swap ;\
		$(EGREP) -f $(EXCEPTION_PATH)/run/exceptions.$(scope) $(REPORT_PATH)/run/assessment.$(scope).csv.swap | $(EGREP) ';error' | sort -u > $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv || true ;\
		cat $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv >> $(REPORT_PATH)/run/assessment.all.exception.csv ;\
	)
# local ----
	$(call cawk_catalog_precompute,catalog_run,catalog_exceptions_run,run)
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/run/assessment.all.deadbeef.csv $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv $(REPORT_PATH)/run/assessment.$(scope).csv > $(REPORT_PATH)/run/assessment.$(scope).summary.txt ;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		cat $(TESTS_TMP)/catalog_tests.run.txt >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "------------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "------------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		cat $(TESTS_TMP)/catalog_exceptions.run.txt >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
	)
# ALL LOCAL ----
	$(call cawk_report_scope_all,$(REPORT_PATH)/run,run)
else
ifeq ($(wildcard $(REPORT_PATH)/run_$(audit)/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
	exit 0
endif

# ---------------------------------------------------
# case: supplier = no  | parallel = yes | audit = yes
# ---------------------------------------------------

# DEADBEEF ----
	$(foreach scope,$(SUPPLIER_SCOPE),\
		if [ ! -d "$(CONFIGURATION_$(scope)_RUN_PATH)" ] || [ ! -d "$(TESTS_$(scope)_RUN_PATH)" ]; then \
			touch $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap; \
		else \
			$(call cawk_deadbeef_scan,$(scope),RUN,run_${audit}) \
		fi; \
	)
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv > $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.idx
# RUN && PSIRT ----
	$(foreach scope,$(SUPPLIER_SCOPE),\
		if [ ! -d "$(CONFIGURATION_$(scope)_RUN_PATH)" ] || ([ ! -d "$(TESTS_$(scope)_RUN_PATH)" ] && [ ! -d "$(TESTS_$(scope)_RUN_PSIRT_PATH)" ]); then \
			$(ECHO) "cawk $(CONFIGURATION_$(scope)_RUN_PATH) or $(TESTS_$(scope)_RUN_PATH) do not exist, skip the ${audit} $(scope) assessment ----"; \
			touch $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv; \
		else \
			$(ECHO) "cawk compute run_${audit} $(scope) devices (parallel mode) ----" ;\
			$(call cawk_test_gen_parallel,$(scope),RUN,run_${audit},${audit}) \
		fi; \
	)
	$(foreach scope,$(SUPPLIER_SCOPE),\
		if [ -d "$(CONFIGURATION_$(scope)_RUN_PATH)" ] && ([ -d "$(TESTS_$(scope)_RUN_PATH)" ] || [ -d "$(TESTS_$(scope)_RUN_PSIRT_PATH)" ]); then \
			find $(TESTS_$(scope)_RUN_PSIRT_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.${audit}.psirt.$(scope) 2>/dev/null || true ;\
			$(TESTS_COMMON_PATH)/gen_cawk_makefile.psirt.gawk $(TESTS_TMP)/conf_list_files.${audit}.$(scope) $(MAKE_FILES_PER_TARGET_PSIRT) $(TESTS_TMP)/conf_list_tests.${audit}.psirt.$(scope) > $(TESTS_TMP)/Makefile.${audit}.psirt.$(scope) 2>/dev/null || true ;\
			$(GMAKE) -f $(TESTS_TMP)/Makefile.${audit}.psirt.$(scope) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap 2>/dev/null || true;\
		fi; \
	)
# CONTEXT LOCAL REPORT ----
# exception ---
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(EGREP) -v -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(scope) $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv || true ;\
		cat $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv >> $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap ;\
		$(EGREP) -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(scope) $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap | $(EGREP) ';error' | sort -u > $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv || true ;\
		cat $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv >> $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv ;\
	)
# local ----
	$(call cawk_catalog_precompute,catalog_run audit=$(audit),catalog_exceptions_run audit=$(audit),$(audit))
	$(foreach scope,$(SUPPLIER_SCOPE),\
		if [ -d "$(CONFIGURATION_$(scope)_RUN_PATH)" ] && ([ -d "$(TESTS_$(scope)_RUN_PATH)" ] || [ -d "$(TESTS_$(scope)_RUN_PSIRT_PATH)" ]); then \
			$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv > $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt ;\
			$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			cat $(TESTS_TMP)/catalog_tests.$(audit).txt >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			cat $(TESTS_TMP)/catalog_exceptions.$(audit).txt >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
		fi; \
	)
# CONTEXT ALL ----
	$(call cawk_report_scope_all,$(REPORT_PATH)/run_$(audit),$(audit))
endif
endif
else
ifeq ($(strip $(MAKE_PARALLEL)),no)
ifeq ($(strip $(audit)),)

# --------------------------------------------------
# case: supplier = yes | parallel = no  | audit = no
# ---------------------------------------------------

	$(ECHO) "cawk compute run $(supplier) devices ----"
# DEADBEEF ----
	$(call cawk_deadbeef_scan,$(supplier),RUN,run)
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/run/assessment.all.deadbeef.csv > $(REPORT_PATH)/run/assessment.all.deadbeef.idx
# RUN && PSIRT ----
	$(call cawk_test_execution,$(TESTS_$(supplier)_RUN_PATH),$(CONFIGURATION_$(supplier)_RUN_PATH),$(REPORT_PATH)/run/assessment.$(supplier).csv.swap,$(TESTS_$(supplier)_RUN_PSIRT_PATH))
# CONTEXT LOCAL REPORT ----
	$(call cawk_catalog_precompute,catalog_run,catalog_exceptions_run,run)
	$(call cawk_report_scope_local,$(supplier),run,run,run)
# CONTEXT ALL REPORT ----
	$(call cawk_report_scope_all,$(REPORT_PATH)/run,run)
else
ifeq ($(wildcard $(REPORT_PATH)/run_$(audit)/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
	exit 0
endif

# ---------------------------------------------------
# case: supplier = yes | parallel = no  | audit = yes
# ---------------------------------------------------

# DEADBEEF ----
	$(ECHO) "cawk compute run_${audit} $(supplier) devices ----"
	$(call cawk_deadbeef_scan,$(supplier),RUN,run_$(audit))
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/run_$(audit)/assessment.all.deadbeef.csv > $(REPORT_PATH)/run_$(audit)/assessment.all.deadbeef.idx
# RUN && PSIRT ---
# CONTEXT LOCAL REPORT ----
	$(call cawk_catalog_precompute,catalog_run audit=$(audit),catalog_exceptions_run audit=$(audit),$(audit))
	if [ ! -d "$(CONFIGURATION_$(supplier)_RUN_PATH)" ] || ([ ! -d "$(TESTS_$(supplier)_RUN_PATH)" ] && [ ! -d "$(TESTS_$(supplier)_RUN_PSIRT_PATH)" ]); then \
		$(ECHO) "cawk $(CONFIGURATION_$(supplier)_RUN_PATH) or $(TESTS_$(supplier)_RUN_PATH) do not exist, skip the ${audit} $(supplier) assessment ----"; \
		touch $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv;\
	else \
		$(if $(filter no,$(PSIRT)),\
			$(foreach test,$(shell find  $(TESTS_$(supplier)_RUN_PATH) -name '*.gawk' -type f  2>/dev/null || true),\
				find $(CONFIGURATION_$(supplier)_RUN_PATH) $(FIND_CONF_SELECT) $(TEST_EXE) >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap 2>/dev/null || true ;\
			),\
			touch $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap ;\
		) \
		$(foreach test,$(shell find $(TESTS_$(supplier)_RUN_PSIRT_PATH) -name '*.gawk' -type f 2>/dev/null || true),\
			find $(CONFIGURATION_$(supplier)_RUN_PATH) $(FIND_CONF_SELECT) $(TEST_EXE) >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap 2>/dev/null || true ;\
		) \
		$(EGREP) -v -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(supplier) $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap | sort -u > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv || true;\
		cat $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv >> $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap;\
		$(EGREP) -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(supplier) $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap | $(EGREP) ';error' | sort -u > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).exceptions.csv || true;\
		cat $(REPORT_PATH)/run_${audit}/assessment.$(supplier).exceptions.csv >> $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv;\
		$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.$(supplier).exceptions.csv $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		cat $(TESTS_TMP)/catalog_tests.$(audit).txt >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		cat $(TESTS_TMP)/catalog_exceptions.$(audit).txt >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
	fi
# CONTEXT ALL REPORT ----
	$(call cawk_report_scope_all,$(REPORT_PATH)/run_$(audit),$(audit))
endif
else
ifeq ($(strip $(audit)),)

# ---------------------------------------------------
# case: supplier = yes | parallel = yes | audit = no
# ---------------------------------------------------

	$(ECHO) "cawk compute run $(supplier) devices (parallel mode) ----"
# DEADBEEF ----
	$(call cawk_deadbeef_scan,$(supplier),RUN,run)
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/run/assessment.all.deadbeef.csv > $(REPORT_PATH)/run/assessment.all.deadbeef.idx
# RUN && PSIRT ----
	$(call cawk_test_gen_parallel,$(supplier),RUN,run,run)
	find $(TESTS_$(supplier)_RUN_PSIRT_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.run.psirt.$(supplier) 2>/dev/null || true
	$(TESTS_COMMON_PATH)/gen_cawk_makefile.psirt.gawk $(TESTS_TMP)/conf_list_files.run.$(supplier) $(MAKE_FILES_PER_TARGET_PSIRT) $(TESTS_TMP)/conf_list_tests.run.psirt.$(supplier) > $(TESTS_TMP)/Makefile.run.psirt.$(supplier) 2>/dev/null || true
	$(GMAKE) -f $(TESTS_TMP)/Makefile.run.psirt.$(supplier) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all >> $(REPORT_PATH)/run/assessment.$(supplier).csv.swap 2>/dev/null || true
# CONTEXT LOCAL REPORT ----
	$(call cawk_catalog_precompute,catalog_run,catalog_exceptions_run,run)
	$(call cawk_report_scope_local,$(supplier),run,run,run)
# CONTEXT ALL REPORT ----
	$(call cawk_report_scope_all,$(REPORT_PATH)/run,run)
else
ifeq ($(wildcard $(REPORT_PATH)/run_$(audit)/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
	exit 0
endif

# ---------------------------------------------------
# case: supplier = yes | parallel = yes | audit = yes
# ---------------------------------------------------

	$(ECHO) "cawk compute run_${audit} $(supplier) devices (parallel mode) ----"
# DEADBEEF ----
	$(call cawk_deadbeef_scan,$(supplier),RUN,run_$(audit))
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/run_$(audit)/assessment.all.deadbeef.csv > $(REPORT_PATH)/run_$(audit)/assessment.all.deadbeef.idx
# RUN && PSIRT ----
# CONTEXT LOCAL REPORT ----
	$(call cawk_catalog_precompute,catalog_run audit=$(audit),catalog_exceptions_run audit=$(audit),$(audit))
	if [ ! -d "$(CONFIGURATION_$(supplier)_RUN_PATH)" ] || ([ ! -d "$(TESTS_$(supplier)_RUN_PATH)" ] && [ ! -d "$(TESTS_$(supplier)_RUN_PSIRT_PATH)" ]); then \
		$(ECHO) "cawk $(CONFIGURATION_$(supplier)_RUN_PATH) or $(TESTS_$(supplier)_RUN_PATH) do not exist, skip the ${audit} $(supplier) assessment ----"; \
		touch $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv;\
	else \
		$(call cawk_test_gen_parallel,$(supplier),RUN,run_${audit},${audit}) \
		find $(TESTS_$(supplier)_RUN_PSIRT_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.${audit}.psirt.$(supplier) 2>/dev/null || true ;\
		$(TESTS_COMMON_PATH)/gen_cawk_makefile.psirt.gawk $(TESTS_TMP)/conf_list_files.${audit}.$(supplier) $(MAKE_FILES_PER_TARGET_PSIRT) $(TESTS_TMP)/conf_list_tests.${audit}.psirt.$(supplier) > $(TESTS_TMP)/Makefile.${audit}.psirt.$(supplier) 2>/dev/null || true ;\
		$(GMAKE) -f $(TESTS_TMP)/Makefile.${audit}.psirt.$(supplier) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap 2>/dev/null || true ;\
		$(EGREP) -v -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(supplier) $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap | sort -u > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv || true; \
		cat $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv >> $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap ; \
		$(EGREP) -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(supplier) $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap | $(EGREP) ';error' | sort -u > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).exceptions.csv || true; \
		cat $(REPORT_PATH)/run_${audit}/assessment.$(supplier).exceptions.csv >> $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv; \
		$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.$(supplier).exceptions.csv $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt; \
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		cat $(TESTS_TMP)/catalog_tests.$(audit).txt >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		cat $(TESTS_TMP)/catalog_exceptions.$(audit).txt >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
	fi
# CONTEXT ALL ----
	$(call cawk_report_scope_all,$(REPORT_PATH)/run_$(audit),$(audit))
endif
endif
endif
ifeq ($(strip $(audit)),)
	$(GMAKE) archive_run
else
	$(GMAKE) archive_run audit=$(audit)
endif
	$(ECHO) "cawk check_run done ----"

.PHONY: check_run_audit

check_run_audit:
	@for dir in $(RUN_DIRS); do \
		$(GMAKE) check_run audit=$$dir; \
	done
	$(ECHO) "cawk check_run_audit done ----"


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# VIEW MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


include Makefile.support.view.mk


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# ARCHIVE MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


include Makefile.support.archive.mk


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# CLEAN MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


include Makefile.support.clean.mk


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# CATALOG MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


include Makefile.support.catalog.mk

# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# EXCEPTIONS MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------

include Makefile.support.exceptions.mk


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# GIT MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


include Makefile.support.git.mk


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# CHECK MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


include Makefile.support.check.mk
