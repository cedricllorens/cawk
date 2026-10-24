# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

# check_repo / check_run.
#
# One body, cawk_check_body, serves the 12 cases (repo|run|audit x all suppliers|supplier= x sequential|parallel) :
# the context is a parameter and the suppliers processed are CHECK_SCOPE.
#
# The phases run for every supplier before the next one starts (scans, execution, local reports) : the local
# reports read the assessment.all.<scan>.csv files filled by the scans of all the suppliers.

.PHONY: check_repo check_run

# suppliers processed by one check : supplier= restricts to one, the whole scope otherwise
CHECK_SCOPE = $(if $(strip $(supplier)),$(strip $(supplier)),$(SUPPLIER_SCOPE))

# -------------------------------------------------------------------------------------------
# MACROS: guard of a supplier of a named audit, same condition as cawk_deadbeef_scan_guarded
# -------------------------------------------------------------------------------------------
# $(1) = scope/supplier
# -------------------------------------------------------------------------------------------
define cawk_chk_if_present
if [ -d "$(CONFIGURATION_$(1)_RUN_PATH)" ] && ([ -d "$(TESTS_$(1)_RUN_PATH)" ] || [ -d "$(TESTS_$(1)_RUN_PSIRT_PATH)" ]); then
endef

# $(1) = scope/supplier, $(2) = report dir (run_<audit>), $(3) = audit name
define cawk_chk_if_absent
if [ ! -d "$(CONFIGURATION_$(1)_RUN_PATH)" ] || ([ ! -d "$(TESTS_$(1)_RUN_PATH)" ] && [ ! -d "$(TESTS_$(1)_RUN_PSIRT_PATH)" ]); then $(ECHO) "cawk $(CONFIGURATION_$(1)_RUN_PATH) or $(TESTS_$(1)_RUN_PATH) do not exist$(cawk_comma) skip the $(3) $(1) assessment ----"; touch $(REPORT_PATH)/$(2)/assessment.all.csv.swap $(REPORT_PATH)/$(2)/assessment.all.exception.csv; else
endef

# -------------------------------------------------------------------------------------------
# MACRO: cawk_chk_scan_phase — one scan (deadbeef|badformat|crlf) of every supplier, then its idx file
# -------------------------------------------------------------------------------------------
# $(1) = scan name, $(2) = path infix (REPO|RUN), $(3) = report dir (repo|run|run_<audit>), $(4) = audit name, empty out of an audit
# -------------------------------------------------------------------------------------------
define cawk_chk_scan_phase
	$(foreach scope,$(CHECK_SCOPE),$(if $(strip $(4)),$(call cawk_$(1)_scan_guarded,$(scope),$(4)),$(call cawk_$(1)_scan,$(scope),$(2),$(3))) )
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/$(3)/assessment.all.$(1).csv > $(REPORT_PATH)/$(3)/assessment.all.$(1).idx
endef

# -------------------------------------------------------------------------------------------
# MACRO: cawk_chk_psirt_parallel — parallel-mode PSIRT generation+run for one supplier (skipped by STANDARD_ONLY=yes)
# -------------------------------------------------------------------------------------------
# Single-line form (foreach-safe: expansion ends with ';').
# $(1) = scope/supplier, $(2) = path infix (REPO|RUN), $(3) = report dir, $(4) = tmp suffix (repo|run|<audit>)
# -------------------------------------------------------------------------------------------
define cawk_chk_psirt_parallel
$(if $(filter yes,$(STANDARD_ONLY)),:,find $(TESTS_$(1)_$(2)_PSIRT_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.$(4).psirt.$(1) 2>/dev/null || true) ;\
	$(if $(filter yes,$(STANDARD_ONLY)),:,$(TESTS_COMMON_PATH)/gen_cawk_makefile.psirt.gawk $(TESTS_TMP)/conf_list_files.$(4).$(1) $(MAKE_FILES_PER_TARGET_PSIRT) $(TESTS_TMP)/conf_list_tests.$(4).psirt.$(1) > $(TESTS_TMP)/Makefile.$(4).psirt.$(1) 2>$(LOGS_PATH)/$(3)/gen_makefile_psirt.$(1).err || $(ECHO) "cawk error: parallel PSIRT makefile generation failed for $(1) (see $(LOGS_PATH)/$(3)/gen_makefile_psirt.$(1).err) ----") ;\
	$(if $(filter yes,$(STANDARD_ONLY)),:,$(GMAKE) --no-print-directory -f $(TESTS_TMP)/Makefile.$(4).psirt.$(1) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all >> $(REPORT_PATH)/$(3)/assessment.$(1).csv.swap 2>$(LOGS_PATH)/$(3)/parallel_gmake_psirt.$(1).err || $(ECHO) "cawk error: parallel PSIRT test execution failed for $(1) (see $(LOGS_PATH)/$(3)/parallel_gmake_psirt.$(1).err) ----") ;
endef

# -------------------------------------------------------------------------------------------
# MACRO: cawk_chk_exec_run — standard + PSIRT test execution of one supplier, sequential or parallel (MAKE_PARALLEL)
# -------------------------------------------------------------------------------------------
# Single-line form (foreach-safe: expansion ends with ';'). Parallel unless MAKE_PARALLEL is no.
# $(1) = scope/supplier, $(2) = path infix (REPO|RUN), $(3) = report dir, $(4) = tmp suffix (repo|run|<audit>)
# -------------------------------------------------------------------------------------------
define cawk_chk_exec_run
$(ECHO) "cawk compute $(3) $(1) devices (MAKE_PARALLEL=$(strip $(MAKE_PARALLEL)) PSIRT_ONLY=$(strip $(PSIRT_ONLY)) STANDARD_ONLY=$(strip $(STANDARD_ONLY))) ----" ;\
	$(if $(filter no,$(strip $(MAKE_PARALLEL))),( $(call cawk_test_execution,$(TESTS_$(1)_$(2)_PATH),$(CONFIGURATION_$(1)_$(2)_PATH),$(REPORT_PATH)/$(3)/assessment.$(1).csv.swap,$(TESTS_$(1)_$(2)_PSIRT_PATH),$(1),$(3)) ) &,( $(call cawk_test_gen_parallel,$(1),$(2),$(3),$(4)) $(call cawk_chk_psirt_parallel,$(1),$(2),$(3),$(4)) ) &)
endef

# $(1) = scope/supplier, $(2) = path infix (REPO|RUN), $(3) = report dir, $(4) = audit name, empty out of an audit, $(5) = tmp suffix
define cawk_chk_exec
	$(if $(strip $(4)),$(call cawk_chk_if_absent,$(1),$(3),$(4)) )$(call cawk_chk_exec_run,$(1),$(2),$(3),$(5))$(if $(strip $(4)), fi;)
endef

# -------------------------------------------------------------------------------------------
# MACRO: cawk_chk_local — exceptions filter, local summary report and catalog tails of one supplier
# -------------------------------------------------------------------------------------------
# Single-line form (foreach-safe: expansion ends with ';'). Run once cawk_catalog_precompute has run.
# $(1) = scope/supplier, $(2) = report dir = exceptions dir (repo|run|run_<audit>), $(3) = catalog tmp tag (repo|run|<audit>)
# -------------------------------------------------------------------------------------------
define cawk_chk_local_body
$(EGREP) -v -f $(EXCEPTION_PATH)/$(2)/exceptions.$(1) $(REPORT_PATH)/$(2)/assessment.$(1).csv.swap | sort -u > $(REPORT_PATH)/$(2)/assessment.$(1).csv || true ;\
	cat $(REPORT_PATH)/$(2)/assessment.$(1).csv >> $(REPORT_PATH)/$(2)/assessment.all.csv.swap ;\
	$(EGREP) -f $(EXCEPTION_PATH)/$(2)/exceptions.$(1) $(REPORT_PATH)/$(2)/assessment.$(1).csv.swap | $(EGREP) ';error' | sort -u > $(REPORT_PATH)/$(2)/assessment.$(1).exceptions.csv || true ;\
	cat $(REPORT_PATH)/$(2)/assessment.$(1).exceptions.csv >> $(REPORT_PATH)/$(2)/assessment.all.exception.csv ;\
	$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/$(2)/assessment.all.deadbeef.csv $(REPORT_PATH)/$(2)/assessment.all.badformat.csv $(REPORT_PATH)/$(2)/assessment.all.crlf.csv $(REPORT_PATH)/$(2)/assessment.$(1).exceptions.csv $(REPORT_PATH)/$(2)/assessment.$(1).csv > $(REPORT_PATH)/$(2)/assessment.$(1).summary.txt 2>$(LOGS_PATH)/$(2)/report_local.$(1).err ;\
	if [ -s $(LOGS_PATH)/$(2)/report_local.$(1).err ]; then $(ECHO) "cawk error: report.gawk failed for $(1) (see $(LOGS_PATH)/$(2)/report_local.$(1).err) ----"; fi ;\
	$(ECHO) "------------------------" >> $(REPORT_PATH)/$(2)/assessment.$(1).summary.txt ;\
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/$(2)/assessment.$(1).summary.txt ;\
	$(ECHO) "------------------------" >> $(REPORT_PATH)/$(2)/assessment.$(1).summary.txt ;\
	cat $(TESTS_TMP)/catalog_tests.$(3).txt >> $(REPORT_PATH)/$(2)/assessment.$(1).summary.txt ;\
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/$(2)/assessment.$(1).summary.txt ;\
	$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/$(2)/assessment.$(1).summary.txt ;\
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/$(2)/assessment.$(1).summary.txt ;\
	cat $(TESTS_TMP)/catalog_exceptions.$(3).txt >> $(REPORT_PATH)/$(2)/assessment.$(1).summary.txt ;
endef

# $(4) = audit name, empty out of an audit : a supplier absent from the audit is skipped
define cawk_chk_local
	$(if $(strip $(4)),$(call cawk_chk_if_present,$(1)) )$(call cawk_chk_local_body,$(1),$(2),$(3))$(if $(strip $(4)), fi;)
endef

# -------------------------------------------------------------------------------------------
# MACRO: cawk_check_body — the assessment of the suppliers of CHECK_SCOPE in one context
# -------------------------------------------------------------------------------------------
# $(1) = path infix (REPO|RUN), $(2) = report/logs/exceptions dir (repo|run|run_<audit>), $(3) = audit name, empty out of an audit
# $(4) = tmp tag (repo|run|<audit>), $(5) = catalog target, $(6) = exceptions catalog target
# -------------------------------------------------------------------------------------------
define cawk_check_body
	# DEADBEEF ----
	$(call cawk_chk_scan_phase,deadbeef,$(1),$(2),$(3))
	# BADFORMAT ----
	$(call cawk_chk_scan_phase,badformat,$(1),$(2),$(3))
	# CRLF ----
	$(call cawk_chk_scan_phase,crlf,$(1),$(2),$(3))
	# RUN && PSIRT ----
	$(foreach scope,$(CHECK_SCOPE),$(call cawk_chk_exec,$(scope),$(1),$(2),$(3),$(4))) wait
	# CONTEXT LOCAL REPORT ----
	$(call cawk_catalog_precompute,$(5),$(6),$(4),$(2))
	$(foreach scope,$(CHECK_SCOPE),$(call cawk_chk_local,$(scope),$(2),$(4),$(3)))
	# CONTEXT ALL REPORT ----
	$(call cawk_report_scope_all,$(REPORT_PATH)/$(2),$(4),$(LOGS_PATH)/$(2))
endef

check_repo: check_supplier clean_report_repo $(if $(filter yes,$(SECRETSCAN)),$(DATABASE_PATH)/censor/censor_regex) clean_tmp $(if $(filter yes,$(CATALOG_BUILD)),catalog_build) exceptions_repo check_deprecated_repo tests_repo
	$(GMAKE) clean_logs_repo FORCE=yes
	mkdir -p $(LOGS_PATH)/repo
ifneq ($(strip $(audit)),)
	$(ECHO) "cawk error the use of <audit=AUDIT_NAME> can only be used with check_run target ----"
	exit 1
else
	$(call cawk_check_body,REPO,repo,,repo,catalog_repo,catalog_exceptions_repo)
endif
	$(GMAKE) archive_repo
	$(call cawk_check_errors_scan,$(LOGS_PATH)/repo)
	$(ECHO) "cawk check_repo done ----"

check_run: check_supplier clean_tmp $(if $(filter yes,$(SECRETSCAN)),$(DATABASE_PATH)/censor/censor_regex) $(if $(filter yes,$(CATALOG_BUILD)),catalog_build) exceptions_run check_deprecated_run tests_run
ifeq ($(strip $(audit)),)
	$(GMAKE) clean_report_run
	$(GMAKE) clean_logs_run FORCE=yes
	mkdir -p $(LOGS_PATH)/run
	$(call cawk_check_body,RUN,run,,run,catalog_run,catalog_exceptions_run)
	$(GMAKE) archive_run
	$(call cawk_check_errors_scan,$(LOGS_PATH)/run)
else
	@if [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error audit=$(audit) do not exist ----"; \
		exit 1; \
	fi
	$(GMAKE) clean_report_run audit=$(audit)
	$(GMAKE) clean_logs_run FORCE=yes audit=$(audit)
	mkdir -p $(LOGS_PATH)/run_$(audit)
	$(call cawk_check_body,RUN,run_$(audit),$(audit),$(audit),catalog_run audit=$(audit),catalog_exceptions_run audit=$(audit))
	$(GMAKE) archive_run audit=$(audit)
	$(call cawk_check_errors_scan,$(LOGS_PATH)/run_$(audit))
endif
	$(ECHO) "cawk check_run done ----"
