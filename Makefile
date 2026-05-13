# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

# ---------------

include Makefile.support.mk


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# HELP and TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


.PHONY: \
  all archive_repo archive_run backup_run backup_run_audit catalog_build \
  catalog_build_repo catalog_build_run catalog_exceptions_repo catalog_exceptions_run catalog_nist_mappings catalog_repo \
  catalog_run check check_analyze check_checkdiff check_debug check_debug_log \
  check_parallel check_parallel_debug check_repo check_run check_run_audit check_supplier \
  check_update clean clean_archive_older clean_archive_repo clean_archive_run clean_archive_run_audit \
  clean_backup clean_force clean_orig clean_report_repo clean_report_run clean_report_run_audit clean_tmp \
  common create_audit database_email_add database_email_del database_email_update database_postaudit_add \
  database_postaudit_del database_postaudit_update database_sync_add database_sync_del database_sync_update database_target_sh \
  database_view delete_audit email_send email_send_audit exceptions_build exceptions_build_repo \
  exceptions_build_run exceptions_repo exceptions_run exceptions_run_audit_copy exceptions_run_copy git \
  gitcheck gitpush list_audit migrate nist_coverage_official nist_coverage_repo \
  nist_coverage_run postaudit_run postaudit_run_audit restore_run restore_run_audit supplier \
  sync_psirt sync_run sync_run_audit sync_teststoconfs_run sync_teststoconfs_run_audit sync_exceptionstoconfs_run sync_exceptionstoconfs_run_audit system \
  tests_check tests_check_nok tests_common tests_repo tests_run tests_run_audit \
  tests_run_audit_copy tests_run_copy tests_target_common tests_target_repo tests_target_run version \
  view_repo view_repo_error view_run view_run_error


all:
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK INFO --------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# note : %SED_GAWK_PATH% point out the gawk path, we set <!/usr/bin/env -S gawk -f> (ref support/tests.sed)"
	$(ECHO) "# note : Makefile.support.mk contains variables that can change the cawk behavior"
	$(ECHO) "# note : you can have several targets for a same gmake call like -> gmake clean check_repo view_repo"
	$(ECHO) "# note : <repo> is the original cawk repository of coded tests, test's confs and exceptions"
	$(ECHO) "# note : <run> is an empty repository used for your own tests/checks"
	$(ECHO) "# note : <run_AUDIT_NAME> are repositories for all of your contexts or for your customers"
	$(ECHO) "# note : please refer to the README file for further information"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK VERSION------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# gmake version : provide information on cawk release"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK MAIN --------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# gmake : provide information on cawk running"
	$(ECHO) "# gmake check : allow to run a cawk compliance check (result must be OK only after the first installation)"
	$(ECHO) "# gmake system : allow to know if the system can run cawk"
	$(ECHO) "# gmake supplier : provide the suppliers supported by cawk"
	$(ECHO) "# gmake common : provide the list of functions available in the common dir"
	$(ECHO) "# gmake clean : clean tests && tmp repository"
	$(ECHO) "# gmake clean_report_repo / clean_report_run / clean_report_run audit=AUDIT_NAME : clean reports"
	$(ECHO) "# gmake clean_archive_repo / clean_archive_run / clean_archive_run audit=AUDIT_NAME : clean archives"
	$(ECHO) "# gmake clean_archive_older : clean older archives (ref ARCHIVE_OLDER_DAYS variable in Makefile.support.mk)"
	$(ECHO) "# gmake clean_backup : clean all backups"
	$(ECHO) "# gmake clean_orig : clean all backup files with .orig suffix"
	$(ECHO) "# gmake clean_force : (USE WITH CAUTION) clean all including reports, backups, archives for all assessments"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK ASSESSMENT --------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# gmake create_audit audit=AUDIT_NAME : create full AUDIT_NAME (all suppliers)"
	$(ECHO) "# gmake create_audit audit=AUDIT_NAME supplier=SUPPLIER : add SUPPLIER to existing AUDIT_NAME"
	$(ECHO) "# gmake delete_audit audit=AUDIT_NAME : delete full AUDIT_NAME (all suppliers)"
	$(ECHO) "# gmake delete_audit audit=AUDIT_NAME supplier=SUPPLIER : remove SUPPLIER from AUDIT_NAME"
	$(ECHO) "# gmake list_audit : list all the AUDIT_NAMEs (audit=AUDIT_NAME)"
	$(ECHO) "# gmake run_audit : run assessments for all the AUDIT_NAMEs (audit=AUDIT_NAME)"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK TESTS -------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---- tests compile ----"
	$(ECHO) "# gmake tests_common : build tests associated to common dir"
	$(ECHO) "# gmake tests_repo : build tests associated to repo dir"
	$(ECHO) "# gmake tests_run : build tests associated to run dir"
	$(ECHO) "# gmake tests_run audit=AUDIT_NAME : build tests associated to run_audit dir"
	$(ECHO) "# gmake tests_run_audit : build tests associated to all audit=AUDIT_NAME run_audit dirs"
	$(ECHO) "# ---- tests copy----"
	$(ECHO) "# gmake tests_run_copy audit=AUDIT_NAME : copy tests from repo to audit=AUDIT_NAME - overwrite (ref run_audit)"
	$(ECHO) "# gmake tests_run_audit_copy : copy tests from repo to all audit=AUDIT_NAMEs (ref all run_audit)"
	$(ECHO) "# ---- tests check----"
	$(ECHO) "# gmake tests_check : check if the tests are cawk compliant, all cawk pass and cawk error are displayed"
	$(ECHO) "# gmake tests_check_nok : check if the tests are cawk compliant, only cawk error are displayed"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK EXCEPTIONS --------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---- exceptions compile ----"
	$(ECHO) "# gmake exceptions_repo : build exceptions from repo/.m4 files (automatically called by check_repo)"
	$(ECHO) "# gmake exceptions_run : build exceptions from run/.m4 files (automatically called by check_run)"
	$(ECHO) "# ---- exceptions copy ----"
	$(ECHO) "# gmake exceptions_run audit=AUDIT_NAME : build exceptions from run_audit/.m4 files (automatically called by check_run audit=AUDIT_NAME)"
	$(ECHO) "# gmake exceptions_run_copy audit=AUDIT_NAME : copy exceptions from repo to audit=AUDIT_NAME (no overwrite, preserves existing)"
	$(ECHO) "# gmake exceptions_run_audit_copy : copy exceptions from repo to all audit=AUDIT_NAMEs (no overwrite)"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK CHECK -------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# NOTE : PSIRT=yes, DEADBEEF=yes, etc. can be added to the gmake call to enable/disable specific test groups"
	$(ECHO) "# gmake check_repo : assess the confs with <repo> tests (build tests if not)"
	$(ECHO) "#  or gmake check_repo (run all suppliers)"
	$(ECHO) "#  or gmake check_repo supplier=cisco-ios (or view_juniper-junos, etc.)"
	$(ECHO) "# gmake check_run : assess the confs with <run> tests (build tests if not)"
	$(ECHO) "#  or gmake check_run (run all suppliers)"
	$(ECHO) "#  or gmake check_run supplier=cisco-ios (or view_juniper-junos, etc.)"
	$(ECHO) "#  or gmake check_run audit=AUDIT_NAME (run all suppliers)"
	$(ECHO) "#  or gmake check_run supplier=cisco-ios audit=AUDIT_NAME (or view_juniper-junos, etc.)"
	$(ECHO) "# gmake check_run_audit : run assessments for all the audit=AUDIT_NAMEs"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK VIEW --------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# gmake view_repo : view the repo reports (all in report/repo dir)"
	$(ECHO) "#  or gmake view_repo supplier=cisco-ios (or juniper-junos, etc.)"
	$(ECHO) "# gmake view_repo_error : view the repo assessment reports errors (all in report/repo dir)"
	$(ECHO) "#  or gmake view_repo_error supplier=cisco-ios (or juniper-junos, etc.)"
	$(ECHO) "# gmake view_run : view the run reports (all in report/run or run_audit dirs)"
	$(ECHO) "#  or gmake view_run supplier=cisco-ios (or juniper-junos, etc.)"
	$(ECHO) "#  or gmake view_run supplier=cisco-ios audit=AUDIT_NAME (or juniper-junos, etc.)"
	$(ECHO) "# gmake view_run_error : view the run assessment reports errors (all in report/run or run_audit dirs)"
	$(ECHO) "#  or gmake view_run_error audit=AUDIT_NAME (all in report/repo dir)"
	$(ECHO) "#  or gmake view_run_error supplier=cisco-ios audit=AUDIT_NAME (or juniper-junos, etc.)"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK DATABASE ----------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# NOTE : only available for audit=AUDIT_NAME assessments"
	$(ECHO) "# gmake database_view : view all the databases linked to audit=AUDIT_NAME assessments"
	$(ECHO) "# ---- sync ----"
	$(ECHO) "# gmake database_sync_(add,update) audit=AUDIT_NAME dir=SYNC_PATH regex=REGEX_PATTERN/.* scope=SCOPE_FILE/none"
	$(ECHO) "#  add/update an entry in the cawk sync database, where fields are separated by spaces :"
	$(ECHO) "#   - 1 field is the audit name"
	$(ECHO) "#   - 2 field is the various sync paths separated by comma (no space) like /conf/ or /conf/cawk/,/conf/cawk_2/"
	$(ECHO) "#   - 3 field is an extended regex to select devices pattern matching like .* or .*switch.*"
	$(ECHO) "#   - 4 field is a file containing a list of devices matching a device scope based on internal inventory"
	$(ECHO) "#   - 5 field is an extended regex to select os pattern matching like (cisco-ios|cisco-xe) or .*"
	$(ECHO) "#   - 6 field is an extended regex to exclude device path pattern matching like (_home|_earth) or none"
	$(ECHO) "# gmake database_sync_del audit=AUDIT_NAME : delete an entry in the cawk sync database"
	$(ECHO) "# ---- email ----"
	$(ECHO) "# gmake database_email_(add,update) audit=AUDIT_NAME dst=EMAIL_LIST cc=EMAIL_LIST/none"
	$(ECHO) "#  add/update an entry in the cawk email database, where fields are separated by spaces :"
	$(ECHO) "#   - 1 field is the audit name"
	$(ECHO) "#   - 2 field is the dst list of emails separated by comma (no space) like email1,email2,email3"
	$(ECHO) "#   - 3 field is the cc list of emails separated by comma (no space) like email1,email2,email3 or none"
	$(ECHO) "# gmake database_email_del audit=AUDIT_NAME : delete an entry in the cawk email database"
	$(ECHO) "# ---- post audit ----"
	$(ECHO) "# gmake database_postaudit_(add/del/update) audit=AUDIT_NAME"
	$(ECHO) "#  add/delete an entry in the cawk post audit database, where fields are separated by spaces :"
	$(ECHO) "#   - 1 field is the audit name"
	$(ECHO) "# ---- information ----"
	$(ECHO) "# gmake catalog_build : regenerate database/db_info.txt and database/db_nist_mappings.json (with CATALOG_BUILD=yes)"
	$(ECHO) "#  regenerate test metadata database from tests program metadata with fields separated by semicolons :"
	$(ECHO) "#   - 1 field is the assessment context (repo or audit name)"
	$(ECHO) "#   - 2 field is the supplier (vendor/platform)"
	$(ECHO) "#   - 3 field is the test name"
	$(ECHO) "#   - 4 field is the test purpose"
	$(ECHO) "#   - 5 field is the test description"
	$(ECHO) "#   - 6 field is the remediation actions"
	$(ECHO) "#   - 7 field is the NIST 800-53 reference"
	$(ECHO) "#   - 8 field is the risk level (high/medium/low/info)"
	$(ECHO) "#   - 9 field is the test authors"
	$(ECHO) "# ---- exceptions ----"
	$(ECHO) "# gmake exceptions_build : regenerate database/db_exception.txt from all .m4 exception files"
	$(ECHO) "#  regenerate exception database with fields separated by semicolons :"
	$(ECHO) "#   - 1 field is the assessment context (repo or audit name)"
	$(ECHO) "#   - 2 field is the supplier (vendor/platform)"
	$(ECHO) "#   - 3 field is the exception ID"
	$(ECHO) "#   - 4 field is the approver name"
	$(ECHO) "#   - 5 field is the date (yyyy-mm-dd format)"
	$(ECHO) "#   - 6 field is the business context/reason for the exception"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK SYNC --------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# NOTE    : only available for audit=AUDIT_NAME assessment"
	$(ECHO) "# NOTE    : it relies on the cawk sync database (i.e.README)"
	$(ECHO) "# CAUTION : local confs files are removed during sync (confs/run_audit dir) (i.e.README)"
	$(ECHO) "# gmake sync_run audit=AUDIT_NAME : build inventory and sync confs from a central repository to confs/run_audit dir"
	$(ECHO) "# gmake sync_run_audit : build inventory and sync confs from a central repository to all confs/run_audit dirs"
	$(ECHO) "# gmake sync_psirt : build psirt inventory to be used by psirt tests"
	$(ECHO) "# gmake sync_teststoconfs_run : sync tests to confs for audit=AUDIT_NAME assessment"
	$(ECHO) "# gmake sync_teststoconfs_run_audit : sync tests to confs for only all audit=AUDIT_NAME assessments"
	$(ECHO) "# gmake sync_exceptionstoconfs_run audit=AUDIT_NAME : sync exceptions to confs for audit=AUDIT_NAME assessment"
	$(ECHO) "# gmake sync_exceptionstoconfs_run_audit : sync exceptions to confs for all audit=AUDIT_NAME assessments"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK EMAIL -------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# NOTE : only available for audit=AUDIT_NAME assessment"
	$(ECHO) "# gmake email_send audit=AUDIT_NAME : send an email to the audit list of emails"
	$(ECHO) "# gmake email_send_audit : send an email to all audits list of emails"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK BACKUP AND RESTORE ------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# NOTE : only available for audit=AUDIT_NAME assessment"
	$(ECHO) "# gmake backup_run audit=AUDIT_NAME : backup all data linked to audit=AUDIT_NAME in backup dir"
	$(ECHO) "# gmake restore_run audit=AUDIT_NAME file=BACKUP_PATH_FILE : restore all data from file_path"
	$(ECHO) "# gmake backup_run_audit : backup cawk database and all data linked to all audit=AUDIT_NAMEs in backup dir"
	$(ECHO) "# gmake restore_run_audit file=BACKUP_PATH_FILE : restore database and all data from file_path"
	$(ECHO) "# gmake migrate file=BACKUP_PATH_FILE : run several targets to migrate to a new cakw version (i.e.README)"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK CATALOG -----------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---- tests ----"
	$(ECHO) "# gmake catalog_repo : build the tests description catalog for repo"
	$(ECHO) "# gmake catalog_run : build the tests description catalog for run"
	$(ECHO) "# gmake catalog_run audit=AUDIT_NAME: build the tests description catalog for audit=AUDIT_NAME"
	$(ECHO) "# ---- exceptions ----"
	$(ECHO) "# gmake catalog_exceptions_repo : build the exceptions description catalog for repo"
	$(ECHO) "# gmake catalog_exceptions_run : build the exceptions description catalog for run"
	$(ECHO) "# gmake catalog_exceptions_run audit=AUDIT_NAME: build the exceptions description catalog for audit=AUDIT_NAME"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"

version:
	@$(ECHO) "cawk version: " $(CAWK_RELEASE)
	@$(ECHO) "cawk version done ----"


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# CREATE/DELETE AUDIT MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


create_audit:
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(strip $(supplier)),)
	# Mode 1: Create full audit
	@if [ -d "$(REPORT_PATH)/run_${audit}" ]; then \
		$(ECHO) "cawk error audit=${audit} already exist ----"; \
	else \
		cp -r $(TESTS_PATH)/repo $(TESTS_PATH)/run_${audit}; \
		cp -r $(EXCEPTION_PATH)/repo exceptions/run_${audit}; \
		cp -r $(CONFS_PATH)/repo $(CONFS_PATH)/run_${audit}; \
		mkdir $(REPORT_PATH)/run_${audit}; \
		mkdir $(REPORT_PATH)/run_${audit}/archives; \
		mkdir $(LOGS_PATH)/run_${audit}; \
		gmake database_postaudit_add audit=${audit}; \
		gmake database_email_add audit=${audit} dst=none cc=none; \
		gmake database_sync_add audit=${audit} dir=none regex=.* scope=none regexos=.* regexpathexclude=none; \
		gmake catalog_build; \
		gmake exceptions_build; \
	fi
else
	# Mode 2: Add supplier to existing audit
	@if [ ! -d "$(REPORT_PATH)/run_${audit}" ]; then \
		$(ECHO) "cawk error audit=${audit} do not exist  ----"; \
	else \
		[ -d "$(TESTS_PATH)/repo/tests.${supplier}" ] && [ ! -d "$(TESTS_PATH)/run_${audit}/tests.${supplier}" ] && cp -r "$(TESTS_PATH)/repo/tests.${supplier}" "$(TESTS_PATH)/run_${audit}/" || true; \
		[ -d "$(TESTS_PATH)/repo/tests.${supplier}.psirt" ] && [ ! -d "$(TESTS_PATH)/run_${audit}/tests.${supplier}.psirt" ] && cp -r "$(TESTS_PATH)/repo/tests.${supplier}.psirt" "$(TESTS_PATH)/run_${audit}/" || true; \
		[ -d "$(CONFS_PATH)/repo/confs.${supplier}" ] && [ ! -d "$(CONFS_PATH)/run_${audit}/confs.${supplier}" ] && cp -r "$(CONFS_PATH)/repo/confs.${supplier}" "$(CONFS_PATH)/run_${audit}/" || true; \
		[ -f "$(EXCEPTION_PATH)/repo/exceptions.${supplier}.m4" ] && [ ! -f "$(EXCEPTION_PATH)/run_${audit}/exceptions.${supplier}.m4" ] && cp "$(EXCEPTION_PATH)/repo/exceptions.${supplier}.m4" "$(EXCEPTION_PATH)/run_${audit}/" || true; \
		gmake catalog_build; \
		gmake exceptions_build; \
	fi
endif
endif
	$(ECHO) "cawk create_audit ${audit} done ----"

delete_audit:
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_$(audit)/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
else
ifeq ($(strip $(supplier)),)
	# Mode 1: Delete full audit (existing behavior)
	rm -f -r $(TESTS_PATH)/run_${audit}
	rm -f -r $(CONFS_PATH)/run_${audit}
	rm -f -r $(EXCEPTION_PATH)/run_${audit}
	rm -f -r $(REPORT_PATH)/run_${audit}
	rm -f -r $(LOGS_PATH)/run_${audit}
	$(EGREP) "^${audit}" $(DATABASE_PATH)/db_sync.txt > /dev/null && sed -i "/^${audit}/d" $(DATABASE_PATH)/db_sync.txt || true
	$(EGREP) "^${audit}" $(DATABASE_PATH)/db_postaudit.txt > /dev/null && sed -i "/^${audit}/d" $(DATABASE_PATH)/db_postaudit.txt || true
	$(EGREP) "^${audit}" $(DATABASE_PATH)/db_email.txt > /dev/null && sed -i "/^${audit}/d" $(DATABASE_PATH)/db_email.txt || true
	gmake catalog_build audit=
	gmake exceptions_build
else
	# Mode 2: Remove supplier from existing audit
	rm -f -r "$(TESTS_PATH)/run_${audit}/tests.${supplier}"
	rm -f -r "$(TESTS_PATH)/run_${audit}/tests.${supplier}.psirt"
	rm -f -r "$(CONFS_PATH)/run_${audit}/confs.${supplier}"
	rm -f "$(EXCEPTION_PATH)/run_${audit}/exceptions.${supplier}.m4"
	gmake catalog_build
	gmake exceptions_build
endif
endif
endif
	$(ECHO) "cawk delete_audit ${audit} done ----"

list_audit:
	find tests -name '*run_*' -type d | awk -F'run_' '{print $$NF}' | sort -u
	$(ECHO) "cawk list_audit done ----"


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# DATABASE MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


database_view:
	touch $(DATABASE_PATH)/db_sync.txt
	touch $(DATABASE_PATH)/db_email.txt
	touch $(DATABASE_PATH)/db_postaudit.txt
	$(ECHO) "\n-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_sync.txt"
	$(ECHO) "-------------------------------------------"
	cat $(DATABASE_PATH)/db_sync.txt | sort || true
	$(ECHO) "\n-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_email.txt"
	$(ECHO) "-------------------------------------------"
	cat $(DATABASE_PATH)/db_email.txt | sort || true
	$(ECHO) "\n-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_postaudit.txt"
	$(ECHO) "-------------------------------------------"
	cat $(DATABASE_PATH)/db_postaudit.txt | sort || true
	$(ECHO) "\n-------------------------------------------"
	$(ECHO) "cawk database_view done ----"

database_sync_add:
	touch $(DATABASE_PATH)/db_sync.txt
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_$(audit)/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
else
ifeq ($(strip $(dir)),)
	$(ECHO) "cawk error dir=SYNC_PATH must be set ----"
else
ifeq ($(strip $(regex)),)
	$(ECHO) "cawk error regex=REGEX_PATTERN/.* must be set ----"
else
ifeq ($(strip $(scope)),)
	$(ECHO) "cawk error scope=SCOPE_FILE/none must be set ----"
else
ifeq ($(strip $(regexos)),)
	$(ECHO) "cawk error regexos=REGEX_PATTERN_OS/.* must be set ----"
else
ifeq ($(strip $(regexpathexclude)),)
	$(ECHO) "cawk error regexpathexclude=REGEX_PATTERN_PATH_EXCLUDE/none must be set ----"
else
	$(ECHO) "${audit} ${dir} ${regex} ${scope} ${regexos} ${regexpathexclude}" >> $(DATABASE_PATH)/db_sync.txt
endif
endif
endif
endif
endif
endif
endif
	$(ECHO) "cawk database_sync_add done ----"

database_sync_update:
	touch $(DATABASE_PATH)/db_sync.txt
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_$(audit)/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
else
ifeq ($(strip $(dir)),)
	$(ECHO) "cawk error dir=SYNC_PATH_DIR must be set ----"
else
ifeq ($(strip $(regex)),)
	$(ECHO) "cawk error regex=REGEX_PATTERN/.* must be set ----"
else
ifeq ($(strip $(scope)),)
	$(ECHO) "cawk error scope=SCOPE_FILE/none must be set ----"
else
ifeq ($(strip $(regexos)),)
	$(ECHO) "cawk error regexos=REGEX_PATTERN_OS/.* must be set ----"
else
ifeq ($(strip $(regexpathexclude)),)
	$(ECHO) "cawk error regexpathexclude=REGEX_PATTERN_PATH_EXCLUDE/none must be set ----"
else
	$(ECHO) "cawk update $(DATABASE_PATH)/db_sync.txt"
	@sed -i "/^${audit}/d" $(DATABASE_PATH)/db_sync.txt
	$(ECHO) "${audit} ${dir} ${regex} ${scope} ${regexos} ${regexpathexclude}" >> $(DATABASE_PATH)/db_sync.txt
endif
endif
endif
endif
endif
endif
endif
	$(ECHO) "cawk database_sync_update done ----"

database_sync_del:
	touch $(DATABASE_PATH)/db_sync.txt
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_$(audit)/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
else
	$(ECHO) "cawk update $(DATABASE_PATH)/db_sync.txt"
	sed -i "/^${audit}/d" $(DATABASE_PATH)/db_sync.txt
endif
endif
	$(ECHO) "cawk database_sync_del done ----"

database_postaudit_add:
	touch $(DATABASE_PATH)/db_postaudit.txt
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_$(audit)/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
else
	$(ECHO) "cawk update $(DATABASE_PATH)/db_postaudit.txt"
	$(ECHO) "${audit}" >> $(DATABASE_PATH)/db_postaudit.txt
endif
endif
	$(ECHO) "cawk database_postaudit_add done ----"

database_postaudit_update:
	touch $(DATABASE_PATH)/db_postaudit.txt
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_$(audit)/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
else
	$(ECHO) "cawk update $(DATABASE_PATH)/db_postaudit.txt"
	sed -i "/^${audit}/d" $(DATABASE_PATH)/db_postaudit.txt
	$(ECHO) "${audit}" >> $(DATABASE_PATH)/db_postaudit.txt
endif
endif
	$(ECHO) "cawk database_postaudit_update done ----"

database_postaudit_del:
	touch $(DATABASE_PATH)/db_postaudit.txt
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_$(audit)/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
else
	$(ECHO) "cawk update $(DATABASE_PATH)/db_postaudit.txt"
	sed -i "/^${audit}/d" $(DATABASE_PATH)/db_postaudit.txt
endif
endif
	$(ECHO) "cawk database_postaudit_del done ----"

database_email_add:
	touch $(DATABASE_PATH)/db_email.txt
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(strip $(dst)),)
	$(ECHO) "cawk error dst=RECIPIENT_EMAIL must be set ----"
else
	cc=$(strip $(cc)); \
	if [ -z "$$cc" ]; then cc=none; fi; \
	$(ECHO) "cawk update $(DATABASE_PATH)/db_email.txt"; \
	$(ECHO) "${audit} ${dst} $$cc" >> $(DATABASE_PATH)/db_email.txt
endif
endif
	$(ECHO) "cawk email_database_add done ----"

database_email_update:
	touch $(DATABASE_PATH)/db_email.txt
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(strip $(dst)),)
	$(ECHO) "cawk error dst=RECIPIENT_EMAIL must be set ----"
else
	cc=$(strip $(cc)); \
	if [ -z "$$cc" ]; then cc=none; fi; \
	$(ECHO) "cawk update $(DATABASE_PATH)/db_email.txt"; \
	sed -i "/^${audit}/d" $(DATABASE_PATH)/db_email.txt; \
	$(ECHO) "${audit} ${dst} $$cc" >> $(DATABASE_PATH)/db_email.txt
endif
endif
	$(ECHO) "cawk email_database_update done ----"

database_email_del:
	touch $(DATABASE_PATH)/db_email.txt
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
	$(ECHO) "cawk update $(DATABASE_PATH)/db_email.txt"
	sed -i "/^${audit}/d" $(DATABASE_PATH)/db_email.txt
endif
	$(ECHO) "cawk email_database_del done ----"


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# SYNC MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


sync_run: clean_tmp tests_target_common database_target_sh
	if [ ! -f $(DATABASE_SH_PATH)/database_sync.script ]; then \
		$(ECHO) "cawk error: $(DATABASE_SH_PATH)/database_sync.script does not exist, execution skipped ----"; \
	else \
		$(ECHO) "cawk $(DATABASE_SH_PATH)/database_sync.script execution ----"; \
		$(DATABASE_SH_PATH)/database_sync.script ${audit}; \
	fi
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
	$(ECHO) "cawk sync_run done ----"
else
	$(ECHO) "cawk cleaning local configurations before sync : $(CONFS_PATH)/run_${audit} "
	rm -f -r $(CONFS_PATH)/run_${audit} || true
	mkdir -p $(CONFS_PATH)/run_${audit} || true
	$(ECHO) "cawk sync files from $(DATABASE_PATH)/db_sync.txt"
	$(EGREP) "^$(audit)" $(DATABASE_PATH)/db_sync.txt | while read line; do \
		paths=$$($(ECHO) "$$line" | gawk '{print $$2}'); \
		if [ "$$paths" != "none" ]; then \
			regex=$$($(ECHO) "$$line" | gawk '{print $$3}'); \
			scope=$$($(ECHO) "$$line" | gawk '{if ( $$4 == "") { print "none"; } else { print $$4; }}'); \
			regexos=$$($(ECHO) "$$line" | gawk '{if ( $$5 == "") { print "none"; } else { print $$5; }}'); \
			regexpathexclude=$$($(ECHO) "$$line" | gawk '{if ( $$6 == "") { print "none"; } else { print $$6; }}'); \
			cd $(CONFS_PATH)/run_$(audit) && ../../$(COMMON_PATH)/sync_cawk_conf.gawk "$$paths" "$$regex" "../../$$scope" "$$regexos" "$$regexpathexclude" && cd ../.. ; \
		else \
			$(ECHO) "cawk error: $(DATABASE_PATH)/db_sync.txt audit $$($(ECHO) "$$line" | gawk '{print $$1}') path does not exist, execution skipped ----"; \
		fi \
	done
	$(ECHO) "cawk sync_run_audit ${audit} done ----"
endif

sync_run_audit: 
	cat $(DATABASE_PATH)/db_sync.txt | while read line; do \
		audit=$$($(ECHO) "$$line" | gawk '{print $$1}'); \
		gmake sync_run audit=$$audit; \
	done
	gmake list_audit
	$(ECHO) "cawk you may launch <gmake sync_teststoconfs_run_audit> to sync tests supplier scope to tests supplier scope ----"
	$(ECHO) "cawk sync_run_audit all audit done ----"

sync_psirt:
	if [ ! -f $(DATABASE_SH_PATH)/database_sync_psirt.script ]; then \
		$(ECHO) "cawk error: $(DATABASE_SH_PATH)/database_sync_psirt.script does not exist, execution skipped ----"; \
	else \
		$(ECHO) "cawk $(DATABASE_SH_PATH)/database_sync_psirt.script execution ----"; \
		$(DATABASE_SH_PATH)/database_sync_psirt.script ${audit}; \
	fi
	$(ECHO) "cawk sync_psirt done ----"

sync_teststoconfs_run:
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
	$(ECHO) "cawk sync_teststoconfs_run done ----"
else
	$(ECHO) "\ncawk sync_teststoconfs_run: processing audit $(audit) ----"
	if [ ! -d "$(CONFS_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk sync_teststoconfs_run: confs/run_$(audit) not found, skip ----"; \
		exit 0; \
	fi; \
	keep=""; \
	for s in $(SUPPLIER_SCOPE); do \
		if [ -d "$(CONFS_PATH)/run_$(audit)/confs.$$s" ]; then \
			keep="$$keep $$s"; \
		fi; \
	done; \
	if [ -z "$$keep" ]; then \
		$(ECHO) "cawk sync_teststoconfs_run: no suppliers found in confs/run_$(audit), skip ----"; \
		exit 0; \
	fi; \
	for t in $(TESTS_PATH)/run_$(audit)/*; do \
		if [ ! -e "$$t" ]; then continue; fi; \
		name=$$(basename $$t); \
		sup=$$(echo $$name | sed -e 's/^tests\.//' -e 's/\.psirt$$//' ); \
		found=no; \
		for ks in $$keep; do \
			if [ "$$ks" = "$$sup" ]; then found=yes; break; fi; \
		done; \
		if [ "$$found" = "no" ]; then \
			$(ECHO) "cawk sync_teststoconfs_run: removing $$t (supplier=$$sup not present in confs/run_$(audit)) ----"; \
			rm -rf "$$t" || true; \
		else \
			$(ECHO) "cawk sync_teststoconfs_run: keep $$t (supplier=$$sup)"; \
		fi; \
	done; \
	$(ECHO) "cawk sync_teststoconfs_run $(audit) done ----"
endif
	$(ECHO) "cawk sync_teststoconfs_run done ----"

sync_teststoconfs_run_audit:
	@for audit in $(RUN_DIRS); do \
		gmake sync_teststoconfs_run audit=$$audit; \
	done; \
	$(ECHO) "cawk sync_teststoconfs_run_audit done ----"

sync_exceptionstoconfs_run:
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
	$(ECHO) "cawk sync_exceptionstoconfs_run done ----"
else
	$(ECHO) "\ncawk sync_exceptionstoconfs_run: processing audit $(audit) ----"
	if [ ! -d "$(CONFS_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk sync_exceptionstoconfs_run: confs/run_$(audit) not found, skip ----"; \
		exit 0; \
	fi; \
	keep=""; \
	for s in $(SUPPLIER_SCOPE); do \
		if [ -d "$(CONFS_PATH)/run_$(audit)/confs.$$s" ]; then \
			keep="$$keep $$s"; \
		fi; \
	done; \
	if [ -z "$$keep" ]; then \
		$(ECHO) "cawk sync_exceptionstoconfs_run: no suppliers found in confs/run_$(audit), skip ----"; \
		exit 0; \
	fi; \
	for e in $(EXCEPTION_PATH)/run_$(audit)/exceptions.*; do \
		if [ ! -e "$$e" ]; then continue; fi; \
		name=$$(basename $$e); \
		sup=$$(echo $$name | sed -e 's/^exceptions\.//' -e 's/\.m4$$//' ); \
		found=no; \
		for ks in $$keep; do \
			if [ "$$ks" = "$$sup" ]; then found=yes; break; fi; \
		done; \
		if [ "$$found" = "no" ]; then \
			$(ECHO) "cawk sync_exceptionstoconfs_run: removing $$e (supplier=$$sup not present in confs/run_$(audit)) ----"; \
			rm -f "$$e" || true; \
		else \
			$(ECHO) "cawk sync_exceptionstoconfs_run: keep $$e (supplier=$$sup)"; \
		fi; \
	done; \
	$(ECHO) "cawk sync_exceptionstoconfs_run $(audit) done ----"
endif
	$(ECHO) "cawk sync_exceptionstoconfs_run done ----"

sync_exceptionstoconfs_run_audit:
	@for audit in $(RUN_DIRS); do \
		gmake sync_exceptionstoconfs_run audit=$$audit; \
	done; \
	$(ECHO) "cawk sync_exceptionstoconfs_run_audit done ----"


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# POSTAUDIT MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


postaudit_run: clean tests_target_common database_target_sh
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
	$(ECHO) "cawk postaudit_run done ----"
else
	if [ ! -f $(DATABASE_SH_PATH)/database_postaudit.script ]; then \
		$(ECHO) "cawk error: $(DATABASE_SH_PATH)/database_postaudit.script does not exist, execution skipped ----"; \
	else \
		$(ECHO) "cawk $(DATABASE_SH_PATH)/database_postaudit.script execution ----"; \
		$(DATABASE_SH_PATH)/database_postaudit.script ${audit}; \
	fi
	$(ECHO) "cawk postaudit_run ${audit} done ----"
endif

postaudit_run_audit:
	cat $(DATABASE_PATH)/db_postaudit.txt | while read line; do \
		$(ECHO) $$line ; \
		audit=$$line; \
		gmake postaudit_run audit=$$audit; \
	done
	gmake list_audit
	$(ECHO) "cawk postaudit_run_audit all audit done ----"


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# EMAIL MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


email_send:
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_$(audit)/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
else
	if $(EGREP) -q "^${audit} " $(DATABASE_PATH)/db_email.txt; then \
		email_info=$$($(EGREP) "^${audit} " $(DATABASE_PATH)/db_email.txt); \
		dst=$$($(ECHO) $$email_info | awk '{print $$2}'); \
		cc=$$($(ECHO) $$email_info | awk '{print $$3}'); \
		if [ -z "$$dst" ]; then \
			$(ECHO) "cawk error dst not found for audit ${audit} ----"; \
			exit 0; \
		fi; \
		if [ -z "$$(find $(REPORT_PATH)/run_${audit} -name '*.csv' -type f)" ]; then \
			$(ECHO) "cawk error no csv files found in $(REPORT_PATH)/run_${audit} ----"; \
			exit 0; \
		fi; \
		zip -j -9 -q $(REPORT_PATH)/run_${audit}/assessment.run_${audit}.export.zip $$(find $(REPORT_PATH)/run_${audit} -type f \( -name '*all.summary.txt' -o -name '*all.idx' -o -name '*all.security.timeline.csv' -o -name '*all.audit.timeline.csv' -o -name '*all.psirt.timeline.csv' -o -name '*all.exception.timeline.csv' -o -name '*all.deadbeef.timeline.csv' \)) || true; \
		$(ECHO) "cawk sending audit ${audit} to $$dst ----"; \
		if [ "$$cc" != "none" ]; then \
			if [ -n "$$(find $(REPORT_PATH)/run_${audit} -name '*all.summary.txt' -type f)" ]; then \
				cat $(COMMON_PATH)/common_message.txt | mutt -s "cawk ${audit} assessment" -a $(REPORT_PATH)/run_${audit}/*all.summary.txt -a $(REPORT_PATH)/run_${audit}/assessment.run_${audit}.export.zip -c $$cc -- $$dst; \
			else \
				cat $(COMMON_PATH)/common_message.txt | mutt -s "cawk ${audit} assessment" -a $(REPORT_PATH)/run_${audit}/*all.summary.txt -a $(REPORT_PATH)/run_${audit}/assessment.run_${audit}.export.zip -c $$cc -- $$dst; \
			fi; \
		else \
			if [ -n "$$(find $(REPORT_PATH)/run_${audit} -name '*all.summary.txt' -type f)" ]; then \
				cat $(COMMON_PATH)/common_message.txt | mutt -s "cawk ${audit} assessment" -a $(REPORT_PATH)/run_${audit}/*all.summary.txt -a $(REPORT_PATH)/run_${audit}/assessment.run_${audit}.export.zip -- $$dst; \
			else \
				cat $(COMMON_PATH)/common_message.txt | mutt -s "cawk ${audit} assessment" -a $(REPORT_PATH)/run_${audit}/*all.summary.txt -a $(REPORT_PATH)/run_${audit}/assessment.run_${audit}.export.zip -- $$dst; \
			fi; \
		fi; \
		$(ECHO) "cawk email sent successfully ----"; \
	else \
		$(ECHO) "cawk error no email info found for audit ${audit} ----"; \
	fi
endif
endif
	$(ECHO) "cawk send_audit_email done ----"

email_send_audit:
	for audit in $(RUN_DIRS); do \
		gmake email_send audit=$$audit; \
	done
	$(ECHO) "cawk email_send_audit done ----"


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# BACKUP/RESTORE MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


backup_run: clean
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
	$(ECHO) "cawk backup_run done ----"
else
	rm -f backup/run_audit_${audit}_$(shell date +%Y-%m-%d).tar.gz backup/run_audit_${audit}_$(shell date +%Y-%m-%d).tar
	find confs/run_${audit}* -type l -exec rm {} \; 2>/dev/null || true
	find confs/run_${audit}* logs/run_${audit}* tests/run_${audit}* exceptions/run_${audit}* reports/run_${audit}* -type f -print0 | tar cvf backup/run_audit_${audit}_$(shell date +%Y-%m-%d).tar --null -T - >/dev/null 2>&1
	gzip backup/run_audit_${audit}_$(shell date +%Y-%m-%d).tar
	$(ECHO) "cawk backup_run_audit ${audit} done in backup/run_audit_${audit}_$(shell date +%Y-%m-%d).tar.gz ----"
endif

backup_run_audit: clean
	rm -f backup/run_audit_$(shell date +%Y-%m-%d).tar backup/run_audit_$(shell date +%Y-%m-%d).tar.gz
	find confs/run_* -type l -exec rm {} \; 2>/dev/null || true
	find $(DATABASE_PATH)/* logs/run_* confs/run_* tests/run_* exceptions/run_* reports/run_* -type f -print0 | tar cvf backup/run_audit_$(shell date +%Y-%m-%d).tar --null -T - >/dev/null 2>&1
	gzip backup/run_audit_$(shell date +%Y-%m-%d).tar
	gmake list_audit
	$(ECHO) "cawk backup_run_audit all audits done in backup/run_audit_$(shell date +%Y-%m-%d).tar.gz ----"

restore_run: clean
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME and file=BACKUP_PATH_FILE must be set ----"
	$(ECHO) "cawk restore_run done ----"
else
ifeq ($(strip $(file)),)
	$(ECHO) "cawk error audit=AUDIT_NAME and file=BACKUP_PATH_FILE must be set ----"
	$(ECHO) "cawk restore_run done ----"
else
	if [ -f ${file} ]; then \
		tar -xzvf ${file} >/dev/null 2>&1; \
		$(ECHO) "cawk restore_run ${audit} done ----"; \
	else \
		$(ECHO) "cawk error: file ${file} does not exist ----"; \
	fi
endif
endif
	mkdir -p confs/run_${audit} 2>/dev/null || true
	$(ECHO) "cawk creates audit confs directory (empty case): confs/run_${audit}"

restore_run_audit: clean
ifeq ($(strip $(file)),)
	$(ECHO) "cawk error file=BACKUP_PATH_FILE must be set ----"
	$(ECHO) "cawk restore_run_audit done ----"
else
	if [ -f ${file} ]; then \
		tar -xzvf ${file} >/dev/null 2>&1; \
		$(ECHO) "cawk restore_run_audit done ----"; \
	else \
		$(ECHO) "cawk error: file ${file} does not exist ----"; \
	fi
endif
	@for dir in $$(find tests -name '*run_*' -type d | grep -o 'run_[^/]*'); do \
		mkdir -p confs/$$dir 2>/dev/null || true; \
		$(ECHO) "cawk creates audit directory (empty case): confs/$$dir"; \
	done

migrate:
ifeq ($(strip $(file)),)
	$(ECHO) "cawk error file=BACKUP_PATH_FILE must be set ----"
	exit 0
endif
	cp ${file} backup/
	gmake restore_run_audit file=backup/$(notdir ${file})
	gmake tests_run_audit_copy
	gmake exceptions_run_audit_copy
	gmake catalog_build
	gmake exceptions_build

# --------------------------------

check_supplier:
ifneq ($(strip $(supplier)),)
ifneq ($(findstring $(supplier),$(SUPPLIER_SCOPE)),$(supplier))
	$(ECHO) "cawk error ($(supplier)) is not the list of suppliers covered by cawk ($(SUPPLIER_SCOPE)) ----"
	exit 0
endif
endif

supplier:
	$(ECHO) $(SUPPLIER_SCOPE)
	$(ECHO) "cawk supplier done ----"

# --------------------------------

system:
	$(TESTS_SYSTEM)/cawk_check_system

# --------------------------------

common:
	$(EGREP) purpose common/*.template

# --------------------------------

# Mark temporary files for automatic cleanup
.INTERMEDIATE: $(REPORT_PATH)/repo/*.swap $(REPORT_PATH)/run/*.swap $(REPORT_PATH)/run_*/*.swap


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# TESTS MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


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
		gmake tests_run_copy audit=$$dir; \
	done
	$(ECHO) "cawk tests_run_audit_copy done ----"

# -----
# NO OVERWRITE : if exceptions exist at target, exceptions are not copied
# -----
exceptions_run_copy:
	@RUN_TARGET="$(EXCEPTION_PATH)/run"; \
	if [ -n "$(audit)" ]; then RUN_TARGET="$(EXCEPTION_PATH)/run_$(audit)"; fi; \
	$(ECHO) "cawk exceptions_run_copy to $$RUN_TARGET start ----"; \
	mkdir -p $$RUN_TARGET || true; \
	for file in $(EXCEPTION_PATH)/repo/*.m4; do \
		if [ ! -f "$$RUN_TARGET/$$(basename $$file)" ]; then \
			cp -v $$file $$RUN_TARGET/ 2>/dev/null || true; \
		else \
			$(ECHO) "cawk skip $$(basename $$file) already exist in $$RUN_TARGET ----"; \
		fi; \
	done; \
	$(ECHO) "cawk exceptions_run_copy to $$RUN_TARGET done ----"

exceptions_run_audit_copy:
	for dir in $(RUN_DIRS); do \
		gmake exceptions_run_copy audit=$$dir; \
	done
	$(ECHO) "cawk exceptions_run_audit_copy done ----"

tests_run: tests_target_run
	$(ECHO) "cawk tests_run $$audit done ----"

tests_run_audit:
	@for dir in $(RUN_DIRS); do \
		gmake tests_run audit=$$dir; \
	done
	$(ECHO) "cawk tests_run_audit done ----"


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# CHECK_REPO MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


check_repo: clean_report_repo clean_tmp $(if $(filter yes,$(CATALOG_BUILD)),catalog_build) exceptions_repo tests_repo check_supplier
ifneq ($(strip $(audit)),)
	$(ECHO) "cawk error the use of <audit=AUDIT_NAME> can only be used with check_run target ----"
	exit 0
else
ifeq ($(strip $(supplier)),)
ifeq ($(strip $(MAKE_PARALLEL)),no)

	$(foreach scope,$(SUPPLIER_SCOPE),\
		find $(CONFIGURATION_$(scope)_REPO_PATH) $(FIND_CONF_SELECT) -exec ./$(TESTS_COMMON_PATH)/deadbeef_cawk_conf.script $(DEADBEEF_THRESHOLD_DAYS) {} \; > $(REPORT_PATH)/repo/assessment.$(scope).deadbeef.csv 2>/dev/null || true ;\
		cat $(REPORT_PATH)/repo/assessment.$(scope).deadbeef.csv >> $(REPORT_PATH)/repo/assessment.all.deadbeef.csv ;\
		find $(CONFIGURATION_$(scope)_REPO_PATH) $(FIND_CONF_SELECT) > $(REPORT_PATH)/repo/assessment.$(scope).idx 2>/dev/null || true ;\
        awk -v scope=$(scope) '{print $$0,scope}' $(REPORT_PATH)/repo/assessment.$(scope).idx >> $(REPORT_PATH)/repo/assessment.all.idx.swap ;\
	)
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/repo/assessment.all.deadbeef.csv > $(REPORT_PATH)/repo/assessment.all.deadbeef.idx
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
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(EGREP) -v -f $(EXCEPTION_PATH)/repo/exceptions.$(scope) $(REPORT_PATH)/repo/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/repo/assessment.$(scope).csv || true ;\
		cat $(REPORT_PATH)/repo/assessment.$(scope).csv | sort -u >> $(REPORT_PATH)/repo/assessment.all.csv.swap ;\
		$(EGREP) -f $(EXCEPTION_PATH)/repo/exceptions.$(scope) $(REPORT_PATH)/repo/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv || true ;\
		cat $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv | sort -u >> $(REPORT_PATH)/repo/assessment.all.exception.csv ;\
		$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/repo/assessment.all.deadbeef.csv $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv $(REPORT_PATH)/repo/assessment.$(scope).csv > $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
	)
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt;\
		$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt;\
		gmake catalog_repo >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
		$(ECHO) "------------------------------" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt;\
		$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt;\
		$(ECHO) "------------------------------" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt;\
		gmake catalog_exceptions_repo >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
	)

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/repo/assessment.all.deadbeef.idx $(REPORT_PATH)/repo/assessment.all.csv.swap > $(REPORT_PATH)/repo/assessment.all.csv
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/repo/assessment.all.csv.swap $(REPORT_PATH)/repo/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/repo/assessment.all.deadbeef.csv $(REPORT_PATH)/repo/assessment.all.exception.csv $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	gmake catalog_repo >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	gmake catalog_exceptions_repo >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.security.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.security.csv > $(REPORT_PATH)/repo/assessment.all.security.timeline.csv || true
	$(EGREP) ';psirt' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.psirt.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.psirt.csv > $(REPORT_PATH)/repo/assessment.all.psirt.timeline.csv || true
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.audit.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.audit.csv > $(REPORT_PATH)/repo/assessment.all.audit.timeline.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.timeline.csv
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.exception.csv > $(REPORT_PATH)/repo/assessment.all.exception.timeline.csv
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.deadbeef.csv > $(REPORT_PATH)/repo/assessment.all.deadbeef.timeline.csv
	sort -u $(REPORT_PATH)/repo/assessment.all.idx.swap > $(REPORT_PATH)/repo/assessment.all.idx

ifeq ($(strip $(TMP_ASSESSMENT_FILES)),yes)
	$(ECHO) "cawk removing temporary assessment files ----"
	$(foreach scope,$(SUPPLIER_SCOPE),\
		rm -f $(REPORT_PATH)/repo/assessment.$(scope).* || true ;\
	)
	rm -f $(REPORT_PATH)/repo/assessment.all.*.swap || true
else
	$(ECHO) "cawk keeping assessment files ----"
endif

ifeq ($(strip $(JSON)),yes)
	$(ECHO) "cawk json reporting performed ----"
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.security.csv > $(REPORT_PATH)/repo/assessment.all.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.audit.csv > $(REPORT_PATH)/repo/assessment.all.audit.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.psirt.csv > $(REPORT_PATH)/repo/assessment.all.psirt.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.exception.csv > $(REPORT_PATH)/repo/assessment.all.exception.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/repo/assessment.all.summary.txt > $(REPORT_PATH)/repo/assessment.all.summary.json
else
	$(ECHO) "cawk json reporting skipped ----"
endif
else

	$(foreach scope,$(SUPPLIER_SCOPE),\
		find $(CONFIGURATION_$(scope)_REPO_PATH) $(FIND_CONF_SELECT) -exec ./$(TESTS_COMMON_PATH)/deadbeef_cawk_conf.script $(DEADBEEF_THRESHOLD_DAYS) {} \; > $(REPORT_PATH)/repo/assessment.$(scope).deadbeef.csv 2>/dev/null || true ;\
		cat $(REPORT_PATH)/repo/assessment.$(scope).deadbeef.csv >> $(REPORT_PATH)/repo/assessment.all.deadbeef.csv ;\
		find $(CONFIGURATION_$(scope)_REPO_PATH) $(FIND_CONF_SELECT) > $(REPORT_PATH)/repo/assessment.$(scope).idx 2>/dev/null || true ;\
        awk -v scope=$(scope) '{print $$0,scope}' $(REPORT_PATH)/repo/assessment.$(scope).idx >> $(REPORT_PATH)/repo/assessment.all.idx.swap ;\
	)
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/repo/assessment.all.deadbeef.csv > $(REPORT_PATH)/repo/assessment.all.deadbeef.idx
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(ECHO) "cawk compute repo $(scope) devices (parallel mode) ----" ;\
		find $(CONFIGURATION_$(scope)_REPO_PATH) $(FIND_CONF_SELECT) > $(TESTS_TMP)/conf_list_files.repo.$(scope) 2>/dev/null || true ;\
		\
		$(if $(filter no,$(PSIRT)),\
			find $(TESTS_$(scope)_REPO_PATH) -type f -name '*.gawk'  > $(TESTS_TMP)/conf_list_tests.repo.$(scope) 2>/dev/null || true ;\
			$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk $(TESTS_TMP)/conf_list_files.repo.$(scope) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.repo.$(scope) > $(TESTS_TMP)/Makefile.repo.$(scope) 2>/dev/null || true ;\
			gmake -f $(TESTS_TMP)/Makefile.repo.$(scope) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all >> $(REPORT_PATH)/repo/assessment.$(scope).csv.swap 2>/dev/null || true ;\
			, \
			touch $(REPORT_PATH)/repo/assessment.$(scope).csv.swap ;\
		) \
	)
	$(foreach scope,$(SUPPLIER_SCOPE),\
		find $(TESTS_$(scope)_REPO_PSIRT_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.repo.psirt.$(scope) 2>/dev/null || true ;\
		$(TESTS_COMMON_PATH)/gen_cawk_makefile.psirt.gawk $(TESTS_TMP)/conf_list_files.repo.$(scope) $(MAKE_FILES_PER_TARGET_PSIRT) $(TESTS_TMP)/conf_list_tests.repo.psirt.$(scope) > $(TESTS_TMP)/Makefile.repo.psirt.$(scope) 2>/dev/null || true ;\
		gmake -f $(TESTS_TMP)/Makefile.repo.psirt.$(scope) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all >> $(REPORT_PATH)/repo/assessment.$(scope).csv.swap 2>/dev/null || true ;\
	)
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(EGREP) -v -f $(EXCEPTION_PATH)/repo/exceptions.$(scope) $(REPORT_PATH)/repo/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/repo/assessment.$(scope).csv || true ;\
		cat $(REPORT_PATH)/repo/assessment.$(scope).csv | sort -u >> $(REPORT_PATH)/repo/assessment.all.csv.swap ;\
		$(EGREP) -f $(EXCEPTION_PATH)/repo/exceptions.$(scope) $(REPORT_PATH)/repo/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv || true ;\
		cat $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv | sort -u >> $(REPORT_PATH)/repo/assessment.all.exception.csv ;\
		$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/repo/assessment.all.deadbeef.csv $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv $(REPORT_PATH)/repo/assessment.$(scope).csv > $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
		$(ECHO) "------------------------\n---- tests purposes ----\n------------------------" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt;\
		gmake catalog_repo >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
		$(ECHO) "------------------------------\n---- exceptions purposes ----\n------------------------------" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt;\
		gmake catalog_exceptions_repo >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
	)

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/repo/assessment.all.deadbeef.idx $(REPORT_PATH)/repo/assessment.all.csv.swap > $(REPORT_PATH)/repo/assessment.all.csv || true
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/repo/assessment.all.csv.swap $(REPORT_PATH)/repo/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/repo/assessment.all.deadbeef.csv $(REPORT_PATH)/repo/assessment.all.exception.csv $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	gmake catalog_repo >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	gmake catalog_exceptions_repo >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.security.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.security.csv > $(REPORT_PATH)/repo/assessment.all.security.timeline.csv || true
	$(EGREP) ';psirt' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.psirt.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.psirt.csv > $(REPORT_PATH)/repo/assessment.all.psirt.timeline.csv || true
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.audit.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.audit.csv > $(REPORT_PATH)/repo/assessment.all.audit.timeline.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.timeline.csv
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.exception.csv > $(REPORT_PATH)/repo/assessment.all.exception.timeline.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.deadbeef.csv > $(REPORT_PATH)/repo/assessment.all.deadbeef.timeline.csv || true
	sort -u $(REPORT_PATH)/repo/assessment.all.idx.swap > $(REPORT_PATH)/repo/assessment.all.idx; \

ifeq ($(strip $(TMP_ASSESSMENT_FILES)),yes)
	$(ECHO) "cawk removing temporary assessment files ----"
	$(foreach scope,$(SUPPLIER_SCOPE),\
		rm -f $(REPORT_PATH)/repo/assessment.$(scope).* || true ;\
	)
	rm -f $(REPORT_PATH)/repo/assessment.all.*.swap || true
else
	$(ECHO) "cawk keeping assessment files ----"
endif

ifeq ($(strip $(JSON)),yes)
	$(ECHO) "cawk json reporting performed ----"
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.security.csv > $(REPORT_PATH)/repo/assessment.all.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.audit.csv > $(REPORT_PATH)/repo/assessment.all.audit.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.psirt.csv > $(REPORT_PATH)/repo/assessment.all.psirt.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.exception.csv > $(REPORT_PATH)/repo/assessment.all.exception.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/repo/assessment.all.summary.txt > $(REPORT_PATH)/repo/assessment.all.summary.json
else
	$(ECHO) "cawk json reporting skipped ----"
endif
endif
else
ifeq ($(strip $(MAKE_PARALLEL)),no)

	$(ECHO) "cawk compute repo $(supplier) devices ----"
	find $(CONFIGURATION_$(supplier)_REPO_PATH) $(FIND_CONF_SELECT) -exec ./$(TESTS_COMMON_PATH)/deadbeef_cawk_conf.script $(DEADBEEF_THRESHOLD_DAYS) {} \; > $(REPORT_PATH)/repo/assessment.$(supplier).deadbeef.csv 2>/dev/null || true ;\
	cat $(REPORT_PATH)/repo/assessment.$(supplier).deadbeef.csv >> $(REPORT_PATH)/repo/assessment.all.deadbeef.csv ;\
	find $(CONFIGURATION_$(supplier)_REPO_PATH) $(FIND_CONF_SELECT) > $(REPORT_PATH)/repo/assessment.$(supplier).idx 2>/dev/null || true ;\
    awk -v scope=$(supplier) '{print $$0,scope}' $(REPORT_PATH)/repo/assessment.$(supplier).idx >> $(REPORT_PATH)/repo/assessment.all.idx.swap ;\
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/repo/assessment.all.deadbeef.csv > $(REPORT_PATH)/repo/assessment.all.deadbeef.idx
	
	$(if $(filter no,$(PSIRT)),\
		$(foreach test,$(shell find $(TESTS_$(supplier)_REPO_PATH) -name '*.gawk' -type f  2>/dev/null || true),\
			find $(CONFIGURATION_$(supplier)_REPO_PATH) $(FIND_CONF_SELECT) $(TEST_EXE) >> $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap 2>/dev/null || true ;\
		),\
		touch $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap ;\
	)
	$(foreach test,$(shell find $(TESTS_$(supplier)_REPO_PSIRT_PATH) -name '*.gawk' -type f 2>/dev/null || true),\
		find $(CONFIGURATION_$(supplier)_REPO_PATH) $(FIND_CONF_SELECT) $(TEST_EXE) >> $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap 2>/dev/null || true ;\
	)

	$(EGREP) -v -f $(EXCEPTION_PATH)/repo/exceptions.$(supplier) $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap | sort -u > $(REPORT_PATH)/repo/assessment.$(supplier).csv || true
	cat $(REPORT_PATH)/repo/assessment.$(supplier).csv >> $(REPORT_PATH)/repo/assessment.all.csv.swap
	$(EGREP) -f $(EXCEPTION_PATH)/repo/exceptions.$(supplier) $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap | sort -u > $(REPORT_PATH)/repo/assessment.$(supplier).exceptions.csv || true
	cat $(REPORT_PATH)/repo/assessment.$(supplier).exceptions.csv >> $(REPORT_PATH)/repo/assessment.all.exception.csv
	$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/repo/assessment.all.deadbeef.csv $(REPORT_PATH)/repo/assessment.$(supplier).exceptions.csv $(REPORT_PATH)/repo/assessment.$(supplier).csv > $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	gmake catalog_repo >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	gmake catalog_exceptions_repo >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/repo/assessment.all.deadbeef.idx $(REPORT_PATH)/repo/assessment.all.csv.swap > $(REPORT_PATH)/repo/assessment.all.csv || true
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/repo/assessment.all.csv.swap $(REPORT_PATH)/repo/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/repo/assessment.all.deadbeef.csv $(REPORT_PATH)/repo/assessment.all.exception.csv $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	gmake catalog_repo >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	gmake catalog_exceptions_repo >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.security.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.security.csv > $(REPORT_PATH)/repo/assessment.all.security.timeline.csv || true
	$(EGREP) ';psirt' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.psirt.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.psirt.csv > $(REPORT_PATH)/repo/assessment.all.psirt.timeline.csv || true
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.audit.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.audit.csv > $(REPORT_PATH)/repo/assessment.all.audit.timeline.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.timeline.csv
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.exception.csv > $(REPORT_PATH)/repo/assessment.all.exception.timeline.csv || true
	 $(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.deadbeef.csv > $(REPORT_PATH)/repo/assessment.all.deadbeef.timeline.csv || true
	sort -u $(REPORT_PATH)/repo/assessment.all.idx.swap > $(REPORT_PATH)/repo/assessment.all.idx; \

ifeq ($(strip $(TMP_ASSESSMENT_FILES)),yes)
	$(ECHO) "cawk removing temporary assessment files ----"
	$(foreach scope,$(SUPPLIER_SCOPE),\
		rm -f $(REPORT_PATH)/repo/assessment.$(scope).* || true ;\
	)
	rm -f $(REPORT_PATH)/repo/assessment.all.*.swap || true
else
	$(ECHO) "cawk keeping assessment files ----"
endif

ifeq ($(strip $(JSON)),yes)
	$(ECHO) "cawk json reporting performed ----"
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.security.csv > $(REPORT_PATH)/repo/assessment.all.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.audit.csv > $(REPORT_PATH)/repo/assessment.all.audit.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.psirt.csv > $(REPORT_PATH)/repo/assessment.all.psirt.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.exception.csv > $(REPORT_PATH)/repo/assessment.all.exception.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/repo/assessment.all.summary.txt > $(REPORT_PATH)/repo/assessment.all.summary.json
else
	$(ECHO) "cawk json reporting skipped ----"
endif
else

	$(ECHO) "cawk repo compute $(supplier) devices (parallel mode) ----"
	find $(CONFIGURATION_$(supplier)_REPO_PATH) $(FIND_CONF_SELECT) -exec ./$(TESTS_COMMON_PATH)/deadbeef_cawk_conf.script $(DEADBEEF_THRESHOLD_DAYS) {} \; > $(REPORT_PATH)/repo/assessment.$(supplier).deadbeef.csv 2>/dev/null || true ;\
	cat $(REPORT_PATH)/repo/assessment.$(supplier).deadbeef.csv >> $(REPORT_PATH)/repo/assessment.all.deadbeef.csv ;\
	find $(CONFIGURATION_$(supplier)_REPO_PATH) $(FIND_CONF_SELECT) > $(REPORT_PATH)/repo/assessment.$(supplier).idx 2>/dev/null || true ;\
    awk -v scope=$(supplier) '{print $$0,scope}' $(REPORT_PATH)/repo/assessment.$(supplier).idx >> $(REPORT_PATH)/repo/assessment.all.idx.swap ;\
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/repo/assessment.all.deadbeef.csv > $(REPORT_PATH)/repo/assessment.all.deadbeef.idx
	
	find $(CONFIGURATION_$(supplier)_REPO_PATH) $(FIND_CONF_SELECT) > $(TESTS_TMP)/conf_list_files.repo.$(supplier) 2>/dev/null || true
	
	$(if $(filter no,$(PSIRT)),\
		find $(TESTS_$(supplier)_REPO_PATH) -type f -name '*.gawk'  > $(TESTS_TMP)/conf_list_tests.repo.$(supplier) 2>/dev/null || true ;\
		$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk $(TESTS_TMP)/conf_list_files.repo.$(supplier) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.repo.$(supplier) > $(TESTS_TMP)/Makefile.repo.$(supplier) ;\
		gmake -f $(TESTS_TMP)/Makefile.repo.$(supplier) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all >> $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap 2>/dev/null || true ;\
		, \
		touch $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap ;\
	)
	find $(TESTS_$(supplier)_REPO_PSIRT_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.repo.psirt.$(supplier) 2>/dev/null || true ;\
	$(TESTS_COMMON_PATH)/gen_cawk_makefile.psirt.gawk $(TESTS_TMP)/conf_list_files.repo.$(supplier) $(MAKE_FILES_PER_TARGET_PSIRT) $(TESTS_TMP)/conf_list_tests.repo.psirt.$(supplier) > $(TESTS_TMP)/Makefile.repo.psirt.$(supplier) ;\
	gmake -f $(TESTS_TMP)/Makefile.repo.psirt.$(supplier) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all >> $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap 2>/dev/null || true

	$(EGREP) -v -f $(EXCEPTION_PATH)/repo/exceptions.$(supplier) $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap | sort -u > $(REPORT_PATH)/repo/assessment.$(supplier).csv || true
	cat $(REPORT_PATH)/repo/assessment.$(supplier).csv >> $(REPORT_PATH)/repo/assessment.all.csv.swap || true
	$(EGREP) -f $(EXCEPTION_PATH)/repo/exceptions.$(supplier) $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap | sort -u > $(REPORT_PATH)/repo/assessment.$(supplier).exceptions.csv || true
	cat $(REPORT_PATH)/repo/assessment.$(supplier).exceptions.csv >> $(REPORT_PATH)/repo/assessment.all.exception.csv
	$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/repo/assessment.all.deadbeef.csv $(REPORT_PATH)/repo/assessment.$(supplier).exceptions.csv $(REPORT_PATH)/repo/assessment.$(supplier).csv > $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	gmake catalog_repo >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	gmake catalog_exceptions_repo >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/repo/assessment.all.deadbeef.idx $(REPORT_PATH)/repo/assessment.all.csv.swap > $(REPORT_PATH)/repo/assessment.all.csv || true
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/repo/assessment.all.csv.swap $(REPORT_PATH)/repo/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/repo/assessment.all.deadbeef.csv $(REPORT_PATH)/repo/assessment.all.exception.csv $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------\n---- tests purposes ----\n------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	gmake catalog_repo >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	gmake catalog_exceptions_repo >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.security.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.security.csv > $(REPORT_PATH)/repo/assessment.all.security.timeline.csv || true
	$(EGREP) ';psirt' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.psirt.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.psirt.csv > $(REPORT_PATH)/repo/assessment.all.psirt.timeline.csv || true
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.audit.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.audit.csv > $(REPORT_PATH)/repo/assessment.all.audit.timeline.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.timeline.csv
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.exception.csv > $(REPORT_PATH)/repo/assessment.all.exception.timeline.csv || true
	 $(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.deadbeef.csv > $(REPORT_PATH)/repo/assessment.all.deadbeef.timeline.csv || true
	sort -u $(REPORT_PATH)/repo/assessment.all.idx.swap > $(REPORT_PATH)/repo/assessment.all.idx; \

ifeq ($(strip $(TMP_ASSESSMENT_FILES)),yes)
	$(ECHO) "cawk removing temporary assessment files ----"
	$(foreach scope,$(SUPPLIER_SCOPE),\
		rm -f $(REPORT_PATH)/repo/assessment.$(scope).* || true ;\
	)
	rm -f $(REPORT_PATH)/repo/assessment.all.*.swap || true
else
	$(ECHO) "cawk keeping assessment files ----"
endif

ifeq ($(strip $(JSON)),yes)
	$(ECHO) "cawk json reporting performed ----"
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.security.csv > $(REPORT_PATH)/repo/assessment.all.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.audit.csv > $(REPORT_PATH)/repo/assessment.all.audit.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.psirt.csv > $(REPORT_PATH)/repo/assessment.all.psirt.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.exception.csv > $(REPORT_PATH)/repo/assessment.all.exception.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/repo/assessment.all.summary.txt > $(REPORT_PATH)/repo/assessment.all.summary.json
else
	$(ECHO) "cawk json reporting skipped ----"
endif
endif
endif
endif
	gmake archive_repo
	$(ECHO) "cawk check_repo done ----"


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# CHECK_RUN MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


check_run: clean_tmp $(if $(filter yes,$(CATALOG_BUILD)),catalog_build) exceptions_run tests_run check_supplier
ifeq ($(strip $(audit)),)
	gmake clean_report_run
else
	gmake clean_report_run audit=$(audit)
endif
ifeq ($(strip $(supplier)),)
ifeq ($(strip $(MAKE_PARALLEL)),no)
ifeq ($(strip $(audit)),)

	$(foreach scope,$(SUPPLIER_SCOPE),\
		find $(CONFIGURATION_$(scope)_RUN_PATH) $(FIND_CONF_SELECT) -exec ./$(TESTS_COMMON_PATH)/deadbeef_cawk_conf.script $(DEADBEEF_THRESHOLD_DAYS) {} \; > $(REPORT_PATH)/run/assessment.$(scope).deadbeef.csv 2>/dev/null || true ;\
		cat $(REPORT_PATH)/run/assessment.$(scope).deadbeef.csv >> $(REPORT_PATH)/run/assessment.all.deadbeef.csv ;\
		find $(CONFIGURATION_$(scope)_RUN_PATH) $(FIND_CONF_SELECT) > $(REPORT_PATH)/run/assessment.$(scope).idx 2>/dev/null 2>/dev/null || true ;\
        awk -v scope=$(scope) '{print $$0,scope}' $(REPORT_PATH)/run/assessment.$(scope).idx >> $(REPORT_PATH)/run/assessment.all.idx.swap ;\
	)
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/run/assessment.all.deadbeef.csv > $(REPORT_PATH)/run/assessment.all.deadbeef.idx
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
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(EGREP) -v -f $(EXCEPTION_PATH)/run/exceptions.$(scope) $(REPORT_PATH)/run/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/run/assessment.$(scope).csv || true ;\
		cat $(REPORT_PATH)/run/assessment.$(scope).csv >> $(REPORT_PATH)/run/assessment.all.csv.swap ;\
		$(EGREP) -f $(EXCEPTION_PATH)/run/exceptions.$(scope) $(REPORT_PATH)/run/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv || true ;\
		cat $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv >> $(REPORT_PATH)/run/assessment.all.exception.csv ;\
		$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/run/assessment.all.deadbeef.csv $(REPORT_PATH)/run/assessment.$(scope).csv > $(REPORT_PATH)/run/assessment.$(scope).summary.txt ;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		gmake catalog_run >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "------------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "------------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		gmake catalog_exceptions_run >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
	)

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/run/assessment.all.deadbeef.idx $(REPORT_PATH)/run/assessment.all.csv.swap > $(REPORT_PATH)/run/assessment.all.csv || true
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/run/assessment.all.csv.swap $(REPORT_PATH)/run/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/run/assessment.all.deadbeef.csv $(REPORT_PATH)/run/assessment.all.exception.csv $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	gmake catalog_run >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	gmake catalog_exceptions_run >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.security.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.security.csv > $(REPORT_PATH)/run/assessment.all.security.timeline.csv || true
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.audit.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.audit.csv > $(REPORT_PATH)/run/assessment.all.audit.timeline.csv || true
	$(EGREP) ';psirt' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.psirt.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.psirt.csv > $(REPORT_PATH)/run/assessment.all.psirt.timeline.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.timeline.csv
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.exception.csv > $(REPORT_PATH)/run/assessment.all.exception.timeline.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.deadbeef.csv > $(REPORT_PATH)/run/assessment.all.deadbeef.timeline.csv || true
	sort -u $(REPORT_PATH)/run/assessment.all.idx.swap > $(REPORT_PATH)/run/assessment.all.idx; \

ifeq ($(strip $(TMP_ASSESSMENT_FILES)),yes)
	$(ECHO) "cawk removing temporary assessment files ----"
	$(foreach scope,$(SUPPLIER_SCOPE),\
		rm -f $(REPORT_PATH)/run/assessment.$(scope).* || true ;\
	)
	rm -f $(REPORT_PATH)/run/*.swap || true
else
	$(ECHO) "cawk keeping assessment files ----"
endif

ifeq ($(strip $(JSON)),yes)
	$(ECHO) "cawk json reporting performed ----"
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.security.csv > $(REPORT_PATH)/run/assessment.all.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.audit.csv > $(REPORT_PATH)/run/assessment.all.audit.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.psirt.csv > $(REPORT_PATH)/run/assessment.all.psirt.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.exception.csv > $(REPORT_PATH)/run/assessment.all.exception.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run/assessment.all.summary.txt > $(REPORT_PATH)/run/assessment.all.summary.json
else
	$(ECHO) "cawk json reporting skipped ----"
endif
else
ifeq ($(wildcard $(REPORT_PATH)/run_$(audit)/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
	exit 0
endif
ifeq ($(wildcard $(REPORT_PATH)/run_$(audit)/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
	exit 0
else

	$(foreach scope,$(SUPPLIER_SCOPE),\
		if [ ! -d "$(CONFIGURATION_$(scope)_RUN_PATH)" ] || [ ! -d "$(TESTS_$(scope)_RUN_PATH)" ]; then \
			touch $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap; \
		else \
			find $(CONFIGURATION_$(scope)_RUN_PATH) $(FIND_CONF_SELECT) -exec ./$(TESTS_COMMON_PATH)/deadbeef_cawk_conf.script $(DEADBEEF_THRESHOLD_DAYS) {} \; > $(REPORT_PATH)/run_${audit}/assessment.$(scope).deadbeef.csv 2>/dev/null || true ;\
			cat $(REPORT_PATH)/run_${audit}/assessment.$(scope).deadbeef.csv >> $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv ;\
			find $(CONFIGURATION_$(scope)_RUN_PATH) $(FIND_CONF_SELECT) > $(REPORT_PATH)/run_${audit}/assessment.$(scope).idx 2>/dev/null || true ;\
        	awk -v scope=$(scope) '{print $$0,scope}' $(REPORT_PATH)/run_${audit}/assessment.$(scope).idx >> $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap ;\
		fi; \
	)
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv > $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.idx
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
	$(foreach scope,$(SUPPLIER_SCOPE),\
		if [ -d "$(CONFIGURATION_$(scope)_RUN_PATH)" ] && ([ -d "$(TESTS_$(scope)_RUN_PATH)" ] || [ -d "$(TESTS_$(scope)_RUN_PSIRT_PATH)" ]); then \
			$(EGREP) -v -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(scope) $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv || true ;\
			cat $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv >> $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap ;\
			$(EGREP) -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(scope) $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv || true ;\
			cat $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv >> $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv ;\
		fi; \
	)
	$(foreach scope,$(SUPPLIER_SCOPE),\
		if [ -d "$(CONFIGURATION_$(scope)_RUN_PATH)" ] && ([ -d "$(TESTS_$(scope)_RUN_PATH)" ] || [ -d "$(TESTS_$(scope)_RUN_PSIRT_PATH)" ]); then \
			$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv > $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt ;\
			$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			gmake catalog_run audit=$(audit) >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			gmake catalog_exceptions_run audit=$(audit) >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
		fi; \
	)

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.idx $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap > $(REPORT_PATH)/run_${audit}/assessment.all.csv || true
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap $(REPORT_PATH)/run_${audit}/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	gmake catalog_run audit=$(audit) >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	gmake catalog_exceptions_run audit=$(audit) >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.security.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.security.csv > $(REPORT_PATH)/run_${audit}/assessment.all.security.timeline.csv || true
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.audit.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.audit.csv > $(REPORT_PATH)/run_${audit}/assessment.all.audit.timeline.csv || true
	$(EGREP) ';psirt' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.psirt.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.psirt.csv > $(REPORT_PATH)/run_${audit}/assessment.all.psirt.timeline.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.timeline.csv
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv > $(REPORT_PATH)/run_${audit}/assessment.all.exception.timeline.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv > $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.timeline.csv || true
	sort -u $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap > $(REPORT_PATH)/run_${audit}/assessment.all.idx

endif
ifeq ($(strip $(TMP_ASSESSMENT_FILES)),yes)
	$(ECHO) "cawk removing temporary assessment files ----"
	$(foreach scope,$(SUPPLIER_SCOPE),\
		rm -f $(REPORT_PATH)/run_${audit}/assessment.$(scope).* || true ;\
	)
	rm -f $(REPORT_PATH)/run_${audit}/*.swap || true
else
	$(ECHO) "cawk keeping assessment files ----"
endif
ifeq ($(strip $(JSON)),yes)
	$(ECHO) "cawk json reporting performed ----"
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.security.csv > $(REPORT_PATH)/run_${audit}/assessment.all.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.audit.csv > $(REPORT_PATH)/run_${audit}/assessment.all.audit.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.psirt.csv > $(REPORT_PATH)/run_${audit}/assessment.all.psirt.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv > $(REPORT_PATH)/run_${audit}/assessment.all.exception.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt > $(REPORT_PATH)/run_${audit}/assessment.all.summary.json
else
	$(ECHO) "cawk json reporting skipped ----"
endif
endif
else
ifeq ($(strip $(audit)),)

	$(foreach scope,$(SUPPLIER_SCOPE),\
		find $(CONFIGURATION_$(scope)_RUN_PATH) $(FIND_CONF_SELECT) -exec ./$(TESTS_COMMON_PATH)/deadbeef_cawk_conf.script $(DEADBEEF_THRESHOLD_DAYS) {} \; > $(REPORT_PATH)/run/assessment.$(scope).deadbeef.csv 2>/dev/null || true ;\
		cat $(REPORT_PATH)/run/assessment.$(scope).deadbeef.csv >> $(REPORT_PATH)/run/assessment.all.deadbeef.csv ;\
		find $(CONFIGURATION_$(scope)_RUN_PATH) $(FIND_CONF_SELECT) > $(REPORT_PATH)/run/assessment.$(scope).idx 2>/dev/null 2>/dev/null || true ;\
        awk -v scope=$(scope) '{print $$0,scope}' $(REPORT_PATH)/run/assessment.$(scope).idx >> $(REPORT_PATH)/run/assessment.all.idx.swap ;\
	)
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/run/assessment.all.deadbeef.csv > $(REPORT_PATH)/run/assessment.all.deadbeef.idx

	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(ECHO) "cawk compute run $(scope) devices (parallel mode) ----" ;\
		find $(CONFIGURATION_$(scope)_RUN_PATH) $(FIND_CONF_SELECT) > $(TESTS_TMP)/conf_list_files.run.$(scope) 2>/dev/null || true ;\
		$(if $(filter no,$(PSIRT)),\
			find $(TESTS_$(scope)_RUN_PATH) -type f -name '*.gawk'  > $(TESTS_TMP)/conf_list_tests.run.$(scope) 2>/dev/null || true ;\
			$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk $(TESTS_TMP)/conf_list_files.run.$(scope) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.run.$(scope) > $(TESTS_TMP)/Makefile.run.$(scope) 2>/dev/null || true ;\
			gmake -f $(TESTS_TMP)/Makefile.run.$(scope) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(REPORT_PATH)/run/assessment.$(scope).csv.swap 2>/dev/null || true ;\
			, \
			touch $(REPORT_PATH)/run/assessment.$(scope).csv.swap ;\
		) \
	)
	$(foreach scope,$(SUPPLIER_SCOPE),\
		find $(TESTS_$(scope)_RUN_PSIRT_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.run.psirt.$(scope) 2>/dev/null || true ;\
		$(TESTS_COMMON_PATH)/gen_cawk_makefile.psirt.gawk $(TESTS_TMP)/conf_list_files.run.$(scope) $(MAKE_FILES_PER_TARGET_PSIRT) $(TESTS_TMP)/conf_list_tests.run.psirt.$(scope) > $(TESTS_TMP)/Makefile.run.psirt.$(scope) 2>/dev/null || true ;\
		gmake -f $(TESTS_TMP)/Makefile.run.psirt.$(scope) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all >> $(REPORT_PATH)/run/assessment.$(scope).csv.swap 2>/dev/null || true ;\
	)
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(EGREP) -v -f $(EXCEPTION_PATH)/run/exceptions.$(scope) $(REPORT_PATH)/run/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/run/assessment.$(scope).csv || true ;\
		cat $(REPORT_PATH)/run/assessment.$(scope).csv >> $(REPORT_PATH)/run/assessment.all.csv.swap ;\
		$(EGREP) -f $(EXCEPTION_PATH)/run/exceptions.$(scope) $(REPORT_PATH)/run/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv || true ;\
		cat $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv >> $(REPORT_PATH)/run/assessment.all.exception.csv ;\
	)
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/run/assessment.all.deadbeef.csv $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv $(REPORT_PATH)/run/assessment.$(scope).csv > $(REPORT_PATH)/run/assessment.$(scope).summary.txt ;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		gmake catalog_run >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "------------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "------------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		gmake catalog_exceptions_run >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
	)

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/run/assessment.all.deadbeef.idx $(REPORT_PATH)/run/assessment.all.csv.swap > $(REPORT_PATH)/run/assessment.all.csv || true
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/run/assessment.all.csv.swap $(REPORT_PATH)/run/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/run/assessment.all.deadbeef.csv $(REPORT_PATH)/run/assessment.all.exception.csv $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.summary.txt
	${TESTS_COMMON_PATH}/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.timeline.csv || true
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	gmake catalog_run >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	gmake catalog_exceptions_run >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.security.csv || true
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.audit.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.audit.csv > $(REPORT_PATH)/run/assessment.all.audit.timeline.csv || true
	$(EGREP) ';psirt' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.psirt.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.psirt.csv > $(REPORT_PATH)/run/assessment.all.psirt.timeline.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.security.csv > $(REPORT_PATH)/run/assessment.all.security.timeline.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.exception.csv > $(REPORT_PATH)/run/assessment.all.exception.timeline.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.deadbeef.csv > $(REPORT_PATH)/run/assessment.all.deadbeef.timeline.csv || true
	sort -u $(REPORT_PATH)/run/assessment.all.idx.swap > $(REPORT_PATH)/run/assessment.all.idx

ifeq ($(strip $(TMP_ASSESSMENT_FILES)),yes)
	$(ECHO) "cawk removing temporary assessment files ----"
	$(foreach scope,$(SUPPLIER_SCOPE),\
		rm -f $(REPORT_PATH)/run/assessment.$(scope).* || true ;\
	)
	rm -f $(REPORT_PATH)/run/*.swap || true
else
	$(ECHO) "cawk keeping assessment files ----"
endif

ifeq ($(strip $(JSON)),yes)
	$(ECHO) "cawk json reporting performed ----"
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.security.csv > $(REPORT_PATH)/run/assessment.all.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.audit.csv > $(REPORT_PATH)/run/assessment.all.audit.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.psirt.csv > $(REPORT_PATH)/run/assessment.all.psirt.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.exception.csv > $(REPORT_PATH)/run/assessment.all.exception.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run/assessment.all.summary.txt > $(REPORT_PATH)/run/assessment.all.summary.json
else
	$(ECHO) "cawk json reporting skipped ----"
endif
else
ifeq ($(wildcard $(REPORT_PATH)/run_$(audit)/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
	exit 0
endif

	$(foreach scope,$(SUPPLIER_SCOPE),\
		if [ ! -d "$(CONFIGURATION_$(scope)_RUN_PATH)" ] || [ ! -d "$(TESTS_$(scope)_RUN_PATH)" ]; then \
			touch $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap; \
		else \
			find $(CONFIGURATION_$(scope)_RUN_PATH) $(FIND_CONF_SELECT) -exec ./$(TESTS_COMMON_PATH)/deadbeef_cawk_conf.script $(DEADBEEF_THRESHOLD_DAYS) {} \; > $(REPORT_PATH)/run_${audit}/assessment.$(scope).deadbeef.csv 2>/dev/null || true ;\
			cat $(REPORT_PATH)/run_${audit}/assessment.$(scope).deadbeef.csv >> $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv ;\
			find $(CONFIGURATION_$(scope)_RUN_PATH) $(FIND_CONF_SELECT) > $(REPORT_PATH)/run_${audit}/assessment.$(scope).idx 2>/dev/null 2>/dev/null || true ;\
        	awk -v scope=$(scope) '{print $$0,scope}' $(REPORT_PATH)/run_${audit}/assessment.$(scope).idx >> $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap ;\
		fi; \
	)
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv > $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.idx
	$(foreach scope,$(SUPPLIER_SCOPE),\
		if [ ! -d "$(CONFIGURATION_$(scope)_RUN_PATH)" ] || ([ ! -d "$(TESTS_$(scope)_RUN_PATH)" ] && [ ! -d "$(TESTS_$(scope)_RUN_PSIRT_PATH)" ]); then \
			$(ECHO) "cawk $(CONFIGURATION_$(scope)_RUN_PATH) or $(TESTS_$(scope)_RUN_PATH) do not exist, skip the ${audit} $(scope) assessment ----"; \
			touch $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv; \
		else \
			$(ECHO) "cawk compute run_${audit} $(scope) devices (parallel mode) ----" ;\
			find $(CONFIGURATION_$(scope)_RUN_PATH) $(FIND_CONF_SELECT) > $(TESTS_TMP)/conf_list_files.${audit}.$(scope) 2>/dev/null || true ;\
		fi; \
	)
	$(foreach scope,$(SUPPLIER_SCOPE),\
		if [ -d "$(CONFIGURATION_$(scope)_RUN_PATH)" ] && ([ -d "$(TESTS_$(scope)_RUN_PATH)" ] || [ -d "$(TESTS_$(scope)_RUN_PSIRT_PATH)" ]); then \
			$(if $(filter no,$(PSIRT)),\
				find $(TESTS_$(scope)_RUN_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.${audit}.$(scope) 2>/dev/null || true ;\
				$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk $(TESTS_TMP)/conf_list_files.${audit}.$(scope) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.${audit}.$(scope) > $(TESTS_TMP)/Makefile.${audit}.$(scope) 2>/dev/null || true ;\
				gmake -f $(TESTS_TMP)/Makefile.${audit}.$(scope) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap 2>/dev/null || true ;\
				, \
				touch $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap ;\
			) \
		fi; \
	)
	$(foreach scope,$(SUPPLIER_SCOPE),\
		if [ -d "$(CONFIGURATION_$(scope)_RUN_PATH)" ] && ([ -d "$(TESTS_$(scope)_RUN_PATH)" ] || [ -d "$(TESTS_$(scope)_RUN_PSIRT_PATH)" ]); then \
			find $(TESTS_$(scope)_RUN_PSIRT_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.${audit}.psirt.$(scope) 2>/dev/null || true ;\
			$(TESTS_COMMON_PATH)/gen_cawk_makefile.psirt.gawk $(TESTS_TMP)/conf_list_files.${audit}.$(scope) $(MAKE_FILES_PER_TARGET_PSIRT) $(TESTS_TMP)/conf_list_tests.${audit}.psirt.$(scope) > $(TESTS_TMP)/Makefile.${audit}.psirt.$(scope) 2>/dev/null || true ;\
			gmake -f $(TESTS_TMP)/Makefile.${audit}.psirt.$(scope) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap 2>/dev/null || true;\
			$(EGREP) -v -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(scope) $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv || true ;\
			cat $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv >> $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap ;\
		fi; \
	)
	$(foreach scope,$(SUPPLIER_SCOPE),\
		if [ -d "$(CONFIGURATION_$(scope)_RUN_PATH)" ] && ([ -d "$(TESTS_$(scope)_RUN_PATH)" ] || [ -d "$(TESTS_$(scope)_RUN_PSIRT_PATH)" ]); then \
			$(EGREP) -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(scope) $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv || true ;\
			cat $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv >> $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv ;\
			$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv > $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt ;\
			$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			gmake catalog_run audit=$(audit) >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			gmake catalog_exceptions_run audit=$(audit) >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
		fi; \
	)

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.idx $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap > $(REPORT_PATH)/run_${audit}/assessment.all.csv || true
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap $(REPORT_PATH)/run_${audit}/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	gmake catalog_run audit=$(audit) >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	gmake catalog_exceptions_run audit=$(audit) >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.security.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.security.csv > $(REPORT_PATH)/run_${audit}/assessment.all.security.timeline.csv || true
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.audit.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.audit.csv > $(REPORT_PATH)/run_${audit}/assessment.all.audit.timeline.csv || true
	$(EGREP) ';psirt' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.psirt.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.psirt.csv > $(REPORT_PATH)/run_${audit}/assessment.all.psirt.timeline.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.timeline.csv
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv > $(REPORT_PATH)/run_${audit}/assessment.all.exception.timeline.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv > $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.timeline.csv || true
	sort -u $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap > $(REPORT_PATH)/run_${audit}/assessment.all.idx

ifeq ($(strip $(TMP_ASSESSMENT_FILES)),yes)
	$(ECHO) "cawk removing temporary assessment files ----"
	$(foreach scope,$(SUPPLIER_SCOPE),\
		rm -f $(REPORT_PATH)/run_${audit}/assessment.$(scope).* || true ;\
	)
	rm -f $(REPORT_PATH)/run_${audit}/*.swap || true
else
	$(ECHO) "cawk keeping assessment files ----"
endif

ifeq ($(strip $(JSON)),yes)
ifneq ($(wildcard $(CONFIGURATION_$(supplier)_RUN_PATH)/.),)
ifneq ($(wildcard $(TESTS_$(supplier)_RUN_PATH)/.),)
	$(ECHO) "cawk json reporting performed ----"
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.security.csv > $(REPORT_PATH)/run_${audit}/assessment.all.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.audit.csv > $(REPORT_PATH)/run_${audit}/assessment.all.audit.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.psirt.csv > $(REPORT_PATH)/run_${audit}/assessment.all.psirt.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv > $(REPORT_PATH)/run_${audit}/assessment.all.exception.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt > $(REPORT_PATH)/run_${audit}/assessment.all.summary.json
endif
endif
else
	$(ECHO) "cawk json reporting skipped ----"
endif
endif
endif
else
ifeq ($(strip $(MAKE_PARALLEL)),no)
ifeq ($(strip $(audit)),)

	$(ECHO) "cawk compute run $(supplier) devices ----"
	find $(CONFIGURATION_$(supplier)_RUN_PATH) $(FIND_CONF_SELECT) -exec ./$(TESTS_COMMON_PATH)/deadbeef_cawk_conf.script $(DEADBEEF_THRESHOLD_DAYS) {} \; > $(REPORT_PATH)/run/assessment.$(supplier).deadbeef.csv 2>/dev/null || true ;\
	cat $(REPORT_PATH)/run/assessment.$(supplier).deadbeef.csv >> $(REPORT_PATH)/run/assessment.all.deadbeef.csv ;\
	find $(CONFIGURATION_$(supplier)_RUN_PATH) $(FIND_CONF_SELECT) > $(REPORT_PATH)/run/assessment.$(supplier).idx 2>/dev/null 2>/dev/null || true ;\
    awk -v supplier=$(supplier) '{print $$0,supplier}' $(REPORT_PATH)/run/assessment.$(supplier).idx >> $(REPORT_PATH)/run/assessment.all.idx.swap ;\
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/run/assessment.all.deadbeef.csv > $(REPORT_PATH)/run/assessment.all.deadbeef.idx

	$(if $(filter no,$(PSIRT)),\
		$(foreach test,$(shell find  $(TESTS_$(supplier)_RUN_PATH) -name '*.gawk' -type f  2>/dev/null || true),\
			find $(CONFIGURATION_$(supplier)_RUN_PATH) $(FIND_CONF_SELECT) $(TEST_EXE) >> $(REPORT_PATH)/run/assessment.$(supplier).csv.swap 2>/dev/null || true ;\
		),\
		touch $(REPORT_PATH)/run/assessment.$(supplier).csv.swap ;\
	)
	$(foreach test,$(shell find $(TESTS_$(supplier)_RUN_PSIRT_PATH) -name '*.gawk' -type f 2>/dev/null || true),\
		find $(CONFIGURATION_$(supplier)_RUN_PATH) $(FIND_CONF_SELECT) $(TEST_EXE) >> $(REPORT_PATH)/run/assessment.$(supplier).csv.swap 2>/dev/null || true ;\
	)

	$(EGREP) -v -f $(EXCEPTION_PATH)/run/exceptions.$(supplier) $(REPORT_PATH)/run/assessment.$(supplier).csv.swap | sort -u > $(REPORT_PATH)/run/assessment.$(supplier).csv || true
	cat $(REPORT_PATH)/run/assessment.$(supplier).csv >> $(REPORT_PATH)/run/assessment.all.csv.swap
	$(EGREP) -f $(EXCEPTION_PATH)/run/exceptions.$(supplier) $(REPORT_PATH)/run/assessment.$(supplier).csv.swap | sort -u > $(REPORT_PATH)/run/assessment.$(supplier).exceptions.csv || true
	cat $(REPORT_PATH)/run/assessment.$(supplier).exceptions.csv >> $(REPORT_PATH)/run/assessment.all.exception.csv
	$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/run/assessment.all.deadbeef.csv $(REPORT_PATH)/run/assessment.$(supplier).exceptions.csv $(REPORT_PATH)/run/assessment.$(supplier).csv > $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	gmake catalog_run | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	gmake catalog_exceptions_run | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/run/assessment.all.deadbeef.idx $(REPORT_PATH)/run/assessment.all.csv.swap > $(REPORT_PATH)/run/assessment.all.csv || true
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/run/assessment.all.csv.swap $(REPORT_PATH)/run/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/run/assessment.all.deadbeef.csv $(REPORT_PATH)/run/assessment.all.exception.csv $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	gmake catalog_run >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	gmake catalog_exceptions_run >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.security.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.security.csv > $(REPORT_PATH)/run/assessment.all.security.timeline.csv || true
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.audit.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.audit.csv > $(REPORT_PATH)/run/assessment.all.audit.timeline.csv || true
	$(EGREP) ';psirt' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.psirt.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.psirt.csv > $(REPORT_PATH)/run/assessment.all.psirt.timeline.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.timeline.csv
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.exception.csv > $(REPORT_PATH)/run/assessment.all.exception.timeline.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.deadbeef.csv > $(REPORT_PATH)/run/assessment.all.deadbeef.timeline.csv || true
	sort -u $(REPORT_PATH)/run/assessment.all.idx.swap > $(REPORT_PATH)/run/assessment.all.idx

ifeq ($(strip $(TMP_ASSESSMENT_FILES)),yes)
	$(ECHO) "cawk removing temporary assessment files ----"
	$(foreach scope,$(SUPPLIER_SCOPE),\
		rm -f $(REPORT_PATH)/run/assessment.$(scope).* || true ;\
	)
	rm -f $(REPORT_PATH)/run/*.swap || true
else
	$(ECHO) "cawk keeping assessment files ----"
endif

ifeq ($(strip $(JSON)),yes)
	$(ECHO) "cawk json reporting performed ----"
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.security.csv > $(REPORT_PATH)/run/assessment.all.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.audit.csv > $(REPORT_PATH)/run/assessment.all.audit.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.psirt.csv > $(REPORT_PATH)/run/assessment.all.psirt.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.exception.csv > $(REPORT_PATH)/run/assessment.all.exception.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run/assessment.all.summary.txt > $(REPORT_PATH)/run/assessment.all.summary.json
else
	$(ECHO) "cawk json reporting skipped ----"
endif
else
ifeq ($(wildcard $(REPORT_PATH)/run_$(audit)/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
	exit 0
endif
	$(ECHO) "cawk compute run_${audit} $(supplier) devices ----"
	find $(CONFIGURATION_$(supplier)_RUN_PATH) $(FIND_CONF_SELECT) -exec ./$(TESTS_COMMON_PATH)/deadbeef_cawk_conf.script $(DEADBEEF_THRESHOLD_DAYS) {} \; > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).deadbeef.csv 2>/dev/null || true;\
	cat $(REPORT_PATH)/run_${audit}/assessment.$(supplier).deadbeef.csv >> $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv ;\
	find $(CONFIGURATION_$(supplier)_RUN_PATH) $(FIND_CONF_SELECT) > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).idx 2>/dev/null || true ;\
    awk -v supplier=$(supplier) '{print $$0,supplier}' $(REPORT_PATH)/run_${audit}/assessment.$(supplier).idx >> $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap ;\
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv > $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.idx

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
		$(EGREP) -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(supplier) $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap | sort -u > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).exceptions.csv || true;\
		cat $(REPORT_PATH)/run_${audit}/assessment.$(supplier).exceptions.csv >> $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv;\
		$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.$(supplier).exceptions.csv $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		gmake catalog_run audit=$(audit) >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		gmake catalog_exceptions_run audit=$(audit) >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
	fi

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.idx $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap > $(REPORT_PATH)/run_${audit}/assessment.all.csv || true
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap $(REPORT_PATH)/run_${audit}/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	gmake catalog_run audit=$(audit) >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	gmake catalog_exceptions_run audit=$(audit) >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.security.csv || true;\
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.security.csv > $(REPORT_PATH)/run_${audit}/assessment.all.security.timeline.csv || true;\
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.audit.csv || true;\
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.audit.csv > $(REPORT_PATH)/run_${audit}/assessment.all.audit.timeline.csv || true;\
	$(EGREP) ';psirt' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.psirt.csv || true;\
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.psirt.csv > $(REPORT_PATH)/run_${audit}/assessment.all.psirt.timeline.csv || true;\
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.timeline.csv ;\
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv > $(REPORT_PATH)/run_${audit}/assessment.all.exception.timeline.csv || true ;\
	sort -u $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap > $(REPORT_PATH)/run_${audit}/assessment.all.idx ;\

ifeq ($(strip $(TMP_ASSESSMENT_FILES)),yes)
	$(ECHO) "cawk removing temporary assessment files ----"
	$(foreach scope,$(SUPPLIER_SCOPE),\
		rm -f $(REPORT_PATH)/run_${audit}/assessment.$(scope).* || true ;\
	)
	rm -f $(REPORT_PATH)/run_${audit}/*.swap || true
else
	$(ECHO) "cawk keeping assessment files ----"
endif

ifeq ($(strip $(JSON)),yes)
ifneq ($(wildcard $(CONFIGURATION_$(supplier)_RUN_PATH)/.),)
ifneq ($(wildcard $(TESTS_$(supplier)_RUN_PATH)/.),)
	$(ECHO) "cawk json reporting performed @$(wildcard $(CONFIGURATION_$(supplier)_RUN_PATH)/.)@ ----"
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.security.csv > $(REPORT_PATH)/run_${audit}/assessment.all.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.audit.csv > $(REPORT_PATH)/run_${audit}/assessment.all.audit.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.psirt.csv > $(REPORT_PATH)/run_${audit}/assessment.all.psirt.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv > $(REPORT_PATH)/run_${audit}/assessment.all.exception.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt > $(REPORT_PATH)/run_${audit}/assessment.all.summary.json
endif
endif
else
	$(ECHO) "cawk json reporting skipped ----"
endif
endif
else
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk compute run $(supplier) devices (parallel mode) ----"
	find $(CONFIGURATION_$(supplier)_RUN_PATH) $(FIND_CONF_SELECT) -exec ./$(TESTS_COMMON_PATH)/deadbeef_cawk_conf.script $(DEADBEEF_THRESHOLD_DAYS) {} \; > $(REPORT_PATH)/run/assessment.$(supplier).deadbeef.csv 2>/dev/null || true;\
	cat $(REPORT_PATH)/run/assessment.$(supplier).deadbeef.csv >> $(REPORT_PATH)/run/assessment.all.deadbeef.csv ;\
	find $(CONFIGURATION_$(supplier)_RUN_PATH) $(FIND_CONF_SELECT) > $(REPORT_PATH)/run/assessment.$(supplier).idx 2>/dev/null || true ;\
    awk -v supplier=$(supplier) '{print $$0,supplier}' $(REPORT_PATH)/run/assessment.$(supplier).idx >> $(REPORT_PATH)/run/assessment.all.idx.swap ;\
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/run/assessment.all.deadbeef.csv > $(REPORT_PATH)/run/assessment.all.deadbeef.idx
	find $(CONFIGURATION_$(supplier)_RUN_PATH) $(FIND_CONF_SELECT) > $(TESTS_TMP)/conf_list_files.run.$(supplier) 2>/dev/null || true
	$(if $(filter no,$(PSIRT)),\
		find $(TESTS_$(supplier)_RUN_PATH) -type f -name '*.gawk'  > $(TESTS_TMP)/conf_list_tests.run.$(supplier) 2>/dev/null || true;\
		$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk $(TESTS_TMP)/conf_list_files.run.$(supplier) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.run.$(supplier) > $(TESTS_TMP)/Makefile.run.$(supplier) 2>/dev/null || true; \
		gmake -f $(TESTS_TMP)/Makefile.run.$(supplier) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(REPORT_PATH)/run/assessment.$(supplier).csv.swap 2>/dev/null || true; \
		, \
		touch $(REPORT_PATH)/run/assessment.$(supplier).csv.swap ;\
	)
	find $(TESTS_$(supplier)_RUN_PSIRT_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.run.psirt.$(supplier) 2>/dev/null || true
	$(TESTS_COMMON_PATH)/gen_cawk_makefile.psirt.gawk $(TESTS_TMP)/conf_list_files.run.$(supplier) $(MAKE_FILES_PER_TARGET_PSIRT) $(TESTS_TMP)/conf_list_tests.run.psirt.$(supplier) > $(TESTS_TMP)/Makefile.run.psirt.$(supplier) 2>/dev/null || true
	gmake -f $(TESTS_TMP)/Makefile.run.psirt.$(supplier) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all >> $(REPORT_PATH)/run/assessment.$(supplier).csv.swap 2>/dev/null || true
	$(EGREP) -v -f $(EXCEPTION_PATH)/run/exceptions.$(supplier) $(REPORT_PATH)/run/assessment.$(supplier).csv.swap | sort -u > $(REPORT_PATH)/run/assessment.$(supplier).csv || true
	cat $(REPORT_PATH)/run/assessment.$(supplier).csv >> $(REPORT_PATH)/run/assessment.all.csv.swap
	$(EGREP) -f $(EXCEPTION_PATH)/run/exceptions.$(supplier) $(REPORT_PATH)/run/assessment.$(supplier).csv.swap | sort -u > $(REPORT_PATH)/run/assessment.$(supplier).exceptions.csv || true
	cat $(REPORT_PATH)/run/assessment.$(supplier).exceptions.csv >> $(REPORT_PATH)/run/assessment.all.exception.csv
	$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/run/assessment.all.deadbeef.csv $(REPORT_PATH)/run/assessment.$(supplier).exceptions.csv $(REPORT_PATH)/run/assessment.$(supplier).csv > $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	gmake catalog_run | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	gmake catalog_exceptions_run | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/run/assessment.all.deadbeef.idx $(REPORT_PATH)/run/assessment.all.csv.swap > $(REPORT_PATH)/run/assessment.all.csv || true
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/run/assessment.all.csv.swap $(REPORT_PATH)/run/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/run/assessment.all.deadbeef.csv $(REPORT_PATH)/run/assessment.all.exception.csv $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	gmake catalog_run >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	gmake catalog_exceptions_run >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.security.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.security.csv > $(REPORT_PATH)/run/assessment.all.security.timeline.csv || true
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.audit.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.audit.csv > $(REPORT_PATH)/run/assessment.all.audit.timeline.csv || true
	$(EGREP) ';psirt' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.psirt.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.psirt.csv > $(REPORT_PATH)/run/assessment.all.psirt.timeline.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.timeline.csv
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.exception.csv > $(REPORT_PATH)/run/assessment.all.exception.timeline.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.deadbeef.csv > $(REPORT_PATH)/run/assessment.all.deadbeef.timeline.csv || true
	sort -u $(REPORT_PATH)/run/assessment.all.idx.swap > $(REPORT_PATH)/run/assessment.all.idx

ifeq ($(strip $(TMP_ASSESSMENT_FILES)),yes)
	$(ECHO) "cawk removing temporary assessment files ----"
	$(foreach scope,$(SUPPLIER_SCOPE),\
		rm -f $(REPORT_PATH)/run/assessment.$(scope).* || true ;\
	)
	rm -f $(REPORT_PATH)/run/*.swap || true
else
	$(ECHO) "cawk keeping assessment files ----"
endif

ifeq ($(strip $(JSON)),yes)
	$(ECHO) "cawk json reporting performed ----"
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.security.csv > $(REPORT_PATH)/run/assessment.all.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.audit.csv > $(REPORT_PATH)/run/assessment.all.audit.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.psirt.csv > $(REPORT_PATH)/run/assessment.all.psirt.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.exception.csv > $(REPORT_PATH)/run/assessment.all.exception.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run/assessment.all.summary.txt > $(REPORT_PATH)/run/assessment.all.summary.json
else
	$(ECHO) "cawk json reporting skipped ----"
endif
else
ifeq ($(wildcard $(REPORT_PATH)/run_$(audit)/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
	exit 0
endif
	$(ECHO) "cawk compute run_${audit} $(supplier) devices (parallel mode) ----"
	find $(CONFIGURATION_$(supplier)_RUN_PATH) $(FIND_CONF_SELECT) -exec ./$(TESTS_COMMON_PATH)/deadbeef_cawk_conf.script $(DEADBEEF_THRESHOLD_DAYS) {} \; > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).deadbeef.csv 2>/dev/null || true ;\
	cat $(REPORT_PATH)/run_${audit}/assessment.$(supplier).deadbeef.csv >> $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv ;\
	find $(CONFIGURATION_$(supplier)_RUN_PATH) $(FIND_CONF_SELECT) > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).idx 2>/dev/null || true ;\
    awk -v supplier=$(supplier) '{print $$0,supplier}' $(REPORT_PATH)/run_${audit}/assessment.$(supplier).idx >> $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap ;\
	awk 'BEGIN { FS = ";" } { print $$1; }' $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv > $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.idx
	
	if [ ! -d "$(CONFIGURATION_$(supplier)_RUN_PATH)" ] || ([ ! -d "$(TESTS_$(supplier)_RUN_PATH)" ] && [ ! -d "$(TESTS_$(supplier)_RUN_PSIRT_PATH)" ]); then \
		$(ECHO) "cawk $(CONFIGURATION_$(supplier)_RUN_PATH) or $(TESTS_$(supplier)_RUN_PATH) do not exist, skip the ${audit} $(supplier) assessment ----"; \
		touch $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv;\
	else \
		find $(CONFIGURATION_$(supplier)_RUN_PATH) $(FIND_CONF_SELECT) > $(TESTS_TMP)/conf_list_files.${audit}.$(supplier) 2>/dev/null || true ; \
		find $(TESTS_$(supplier)_RUN_PATH) -type f -name '*.gawk'  > $(TESTS_TMP)/conf_list_tests.${audit}.$(supplier) 2>/dev/null || true ; \
		$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk $(TESTS_TMP)/conf_list_files.${audit}.$(supplier) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.${audit}.$(supplier) > $(TESTS_TMP)/Makefile.${audit}.$(supplier) 2>/dev/null || true; \
		gmake -f $(TESTS_TMP)/Makefile.${audit}.$(supplier) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap 2>/dev/null || true; \
		$(if $(filter no,$(PSIRT)),\
			find $(TESTS_$(supplier)_RUN_PSIRT_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.${audit}.psirt.$(supplier) 2>/dev/null || true ;\
			$(TESTS_COMMON_PATH)/gen_cawk_makefile.psirt.gawk $(TESTS_TMP)/conf_list_files.${audit}.$(supplier) $(MAKE_FILES_PER_TARGET_PSIRT) $(TESTS_TMP)/conf_list_tests.${audit}.psirt.$(supplier) > $(TESTS_TMP)/Makefile.${audit}.psirt.$(supplier) 2>/dev/null || true ;\
			gmake -f $(TESTS_TMP)/Makefile.${audit}.psirt.$(supplier) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap 2>/dev/null || true ;\
			, \
			touch $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap ;\
		) \
		$(EGREP) -v -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(supplier) $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap | sort -u > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv || true; \
		cat $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv >> $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap ; \
		$(EGREP) -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(supplier) $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap | sort -u > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).exceptions.csv || true; \
		cat $(REPORT_PATH)/run_${audit}/assessment.$(supplier).exceptions.csv >> $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv; \
		$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.$(supplier).exceptions.csv $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt; \
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		gmake catalog_run audit=$(audit) >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		gmake catalog_exceptions_run audit=$(audit) >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
	fi 

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.idx $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap > $(REPORT_PATH)/run_${audit}/assessment.all.csv || true
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap $(REPORT_PATH)/run_${audit}/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	gmake catalog_run audit=$(audit) >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	gmake catalog_exceptions_run audit=$(audit) >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.security.csv || true;\
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.security.csv > $(REPORT_PATH)/run_${audit}/assessment.all.security.timeline.csv || true;\
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.audit.csv || true;\
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.audit.csv > $(REPORT_PATH)/run_${audit}/assessment.all.audit.timeline.csv || true;\
	$(EGREP) ';psirt' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.psirt.csv || true;\
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.psirt.csv > $(REPORT_PATH)/run_${audit}/assessment.all.psirt.timeline.csv || true;\
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.timeline.csv ;\
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv > $(REPORT_PATH)/run_${audit}/assessment.all.exception.timeline.csv || true ;\
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv > $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.timeline.csv || true ;\
	sort -u $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap > $(REPORT_PATH)/run_${audit}/assessment.all.idx ;\

ifeq ($(strip $(TMP_ASSESSMENT_FILES)),yes)
	$(ECHO) "cawk removing temporary assessment files ----"
	$(foreach scope,$(SUPPLIER_SCOPE),\
		rm -f $(REPORT_PATH)/run_${audit}/assessment.$(scope).* || true ;\
	)
	rm -f $(REPORT_PATH)/run_${audit}/*.swap || true
else
	$(ECHO) "cawk keeping assessment files ----"
endif

ifeq ($(strip $(JSON)),yes)
ifneq ($(wildcard $(CONFIGURATION_$(supplier)_RUN_PATH)/.),)
ifneq ($(wildcard $(TESTS_$(supplier)_RUN_PATH)/.),)
	$(ECHO) "cawk json reporting performed ----"
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.security.csv > $(REPORT_PATH)/run_${audit}/assessment.all.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.audit.csv > $(REPORT_PATH)/run_${audit}/assessment.all.audit.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.psirt.csv > $(REPORT_PATH)/run_${audit}/assessment.all.psirt.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv > $(REPORT_PATH)/run_${audit}/assessment.all.exception.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt > $(REPORT_PATH)/run_${audit}/assessment.all.summary.json
endif
endif
else
	$(ECHO) "cawk json reporting skipped ----"
endif
endif
endif
endif
ifeq ($(strip $(audit)),)
	gmake archive_run
else
	gmake archive_run audit=$(audit)
endif
	$(ECHO) "cawk check_run done ----"

check_run_audit:
	@for dir in $(RUN_DIRS); do \
		gmake check_run audit=$$dir; \
	done
	$(ECHO) "cawk check_run_audit done ----"


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# VIEW MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


view_repo: check_supplier
	$(ECHO) "------------------------------------"
	$(ECHO) "---- Assessment all devices" ;\
	$(ECHO) "------------------------------------"
	cat $(REPORT_PATH)/repo/assessment.all.csv
	$(ECHO) "-------------------------"
	$(ECHO) "---- Summary all"
	$(ECHO) "-------------------------"
	cat $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "cawk view_repo done ----"

view_run: check_supplier
ifeq ($(strip $(audit)),)
	$(ECHO) "------------------------------------"
	$(ECHO) "---- Assessment all devices"
	$(ECHO) "------------------------------------"
	if [ -f $(REPORT_PATH)/run/assessment.all.csv ]; then \
	cat $(REPORT_PATH)/run/assessment.all.csv; \
	fi; \
	$(ECHO) "-------------------------"
	$(ECHO) "---- Summary all"
	$(ECHO) "-------------------------"
	if [ -f $(REPORT_PATH)/run/assessment.all.summary.txt ]; then \
		cat $(REPORT_PATH)/run/assessment.all.summary.txt; \
	fi
else
ifeq ($(wildcard $(REPORT_PATH)/run_$(audit)/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
	exit 0
endif
	$(ECHO) "------------------------------------"
	$(ECHO) "---- Assessment ${audit} all devices"
	$(ECHO) "------------------------------------"
	if [ -f $(REPORT_PATH)/run_${audit}/assessment.all.csv ]; then \
		cat $(REPORT_PATH)/run_${audit}/assessment.all.csv ;\
	fi
	$(ECHO) "---------------------------------"
	$(ECHO) "---- Summary ${audit} all"
	$(ECHO) "---------------------------------"
	if [ -f $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt ]; then \
		cat $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt ;\
	fi
endif
	$(ECHO) "cawk view_run done ----"

view_repo_error: check_supplier
ifeq ($(strip $(supplier)),)
	$(foreach test,$(SUPPLIER_SCOPE),\
		if [ -f $(REPORT_PATH)/repo/assessment.$(test).csv ]; then \
			cat $(REPORT_PATH)/repo/assessment.$(test).csv | $(EGREP) ";error" | sort -u; \
		fi ;\
	)
else
	if [ -f $(REPORT_PATH)/repo/assessment.$(supplier).csv ]; then \
		cat $(REPORT_PATH)/repo/assessment.$(supplier).csv | $(EGREP) ";error" | sort -u; \
	fi
endif
	$(ECHO) "cawk view_repo_error done ----"

view_run_error: check_supplier
ifeq ($(strip $(audit)),)
ifeq ($(strip $(supplier)),)
	$(foreach test,$(SUPPLIER_SCOPE),\
		if [ -f $(REPORT_PATH)/run/assessment.$(test).csv ]; then \
			cat $(REPORT_PATH)/run/assessment.$(test).csv | $(EGREP) ";error" | sort -u; \
		fi ;\
	)
else
	if [ -f $(REPORT_PATH)/run/assessment.$(supplier).csv ]; then \
		cat $(REPORT_PATH)/run/assessment.$(supplier).csv | $(EGREP) ";error" | sort -u; \
	fi
endif
else
ifeq ($(strip $(supplier)),)
	$(foreach test,$(SUPPLIER_SCOPE),\
		if [ -f $(REPORT_PATH)/run_${audit}/assessment.$(test).csv ]; then \
			cat $(REPORT_PATH)/run_${audit}/assessment.$(test).csv | $(EGREP) ";error" | sort -u; \
		fi ;\
	)
else
	if [ -f $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv ]; then \
		cat $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv | $(EGREP) ";error" | sort -u; \
	fi
endif
endif
	$(ECHO) "cawk view_run_error done ----"


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# ARCHIVE MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


archive_repo:
	if [ -n "$$(find reports/repo -name '*.csv' -o -name '*.txt')" ]; then \
		tar -czf reports/run/archives/repo_$(shell date +%Y-%m-%d).tar.gz $$(find reports/repo -name '*.csv' -o -name '*.txt') || true ;\
		$(ECHO) "cawk build archive in reports/repo/archives/repo_$(shell date +%Y-%m-%d).tar.gz"; \
	else \
		$(ECHO) "cawk no files *.csv and *.txt found in reports/repo, skip the archive ----" ;\
	fi	
	$(ECHO) "cawk archive_repo done ----"

archive_run:
ifeq ($(strip $(audit)),)
	@if [ -n "$$(find reports/run -name '*.csv' -o -name '*.txt')" ]; then \
		tar -czf reports/run/archives/run_$(shell date +%Y-%m-%d).tar.gz $$(find reports/run -name '*.csv' -o -name '*.txt') || true ;\
		$(ECHO) "cawk build archive in reports/run/archives/run_$(shell date +%Y-%m-%d).tar.gz"; \
	else \
		$(ECHO) "cawk no files *.csv and *.txt found in reports/run, skip the archive ----"; \
	fi	
else
	@if [ -n "$$(find reports/run_${audit} -name '*.csv' -o -name '*.txt')" ]; then \
		tar -czf reports/run_${audit}/archives/run_${audit}_$(shell date +%Y-%m-%d).tar.gz $$(find reports/run_${audit} -name '*.csv' -o -name '*.txt') || true ;\
		$(ECHO) "cawk build archive in reports/run_${audit}/archives/run_${audit}_$(shell date +%Y-%m-%d).tar.gz"; \
	else \
		$(ECHO) "cawk no files *.csv and *.txt found in reports/run_${audit}, skip the archive ----"; \
	fi	
endif
	$(ECHO) "cawk archive_run done ----"


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# CLEAN MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


clean: clean_tmp
	find $(TESTS_COMMON_PATH) -type f -name "*.gawk" -delete 2>/dev/null || true
	find $(TESTS_COMMON_PATH) -type f -name "*.script" -delete 2>/dev/null || true
	find $(DATABASE_SH_PATH) -type f -name "*.script" -delete 2>/dev/null || true
	find $(EXCEPTION_PATH) -type f -name "exceptions.*" ! -name "*.m4" ! -name "*.sed" -delete 2>/dev/null || true
	find $(TESTS_PATH)/repo -type f -name "*.gawk" -delete 2>/dev/null || true
	find $(TESTS_PATH)/repo -type f -name "*.swap" -delete 2>/dev/null || true
	find $(TESTS_PATH)/run -type f -name "*.gawk" -delete 2>/dev/null || true
	find $(TESTS_PATH)/run -type f -name "*.swap" -delete 2>/dev/null || true
	find $(TESTS_PATH)/run_* -type f -name "*.gawk" -delete 2>/dev/null || true
	find $(TESTS_PATH)/run_* -type f -name "*.swap" -delete 2>/dev/null || true
	rm -f *.tar *.tar.gz || true
	rm -f checkdiff/scripts/analyze_diff checkdiff/scripts/check_debug checkdiff/scripts/check_parallel_debug checkdiff/scripts/diff_reports checkdiff/scripts/run_check 2>/dev/null || true
	rm -f checkdiff/scripts/*.log checkdiff/scripts/*.txt 2>/dev/null || true
	rm -f checkdiff/checkdiff.baseline checkdiff/checkdiff.check.result 2>/dev/null || true
	find $(TESTS_COMMON_PATH) $(DATABASE_SH_PATH) $(EXCEPTION_PATH) $(TESTS_PATH)/repo $(TESTS_PATH)/run -type f -exec touch {} \; || true
	if [ -d "$(TESTS_PATH)/run_*" ]; then find $(TESTS_PATH)/run_* -type f -exec touch {} \; || true; fi
	$(ECHO) "cawk clean done ----"

clean_backup:
	rm -f $(BACKUP_PATH)/*.tar $(BACKUP_PATH)/*.tar.gz 2>/dev/null || true
	$(ECHO) "cawk clean $(BACKUP_PATH) done ----"

clean_orig:
	find . -type f -name "*.orig" -delete 2>/dev/null || true
	$(ECHO) "cawk clean all .orig backup files done ----"

clean_report_repo:
	rm -f $(REPORT_PATH)/repo/* 2>/dev/null || true
	$(ECHO) "cawk clean $(REPORT_PATH)/repo done ----"

clean_archive_repo:
	rm -f $(REPORT_PATH)/repo/archives/* 2>/dev/null || true
	$(ECHO) "cawk clean $(REPORT_PATH)/repo/archives done ----"

clean_report_run:
ifeq ($(strip $(audit)),)
	rm -f $(REPORT_PATH)/run/* 2>/dev/null || true
	$(ECHO) "cawk clean $(REPORT_PATH)/run done ----"
else
	rm -f $(REPORT_PATH)/run_${audit}/* 2>/dev/null || true
	$(ECHO) "cawk clean $(REPORT_PATH)/run_${audit} done ----"
endif

clean_archive_run:
ifeq ($(strip $(audit)),)
	rm -f $(REPORT_PATH)/run/archives/* 2>/dev/null || true
	$(ECHO) "cawk clean $(REPORT_PATH)/run/archives done ----"
else
	rm -f $(REPORT_PATH)/run_${audit}/archives/* 2>/dev/null || true
	$(ECHO) "cawk clean $(REPORT_PATH)/run_${audit}/archives done ----"
endif

clean_report_run_audit:
	@for dir in $(RUN_DIRS); do \
		gmake clean_report_run audit=$$dir; \
	done

clean_archive_run_audit:
	@for dir in $(RUN_DIRS); do \
		gmake clean_archive_run audit=$$dir; \
	done

clean_tmp:
	find $(TESTS_TMP) -type f -name "tmp*" -delete 2>/dev/null || true
	find $(TESTS_TMP) -type f -name "conf_*" -delete 2>/dev/null || true
	find $(TESTS_TMP) -type f -name "Makefile*" -delete 2>/dev/null || true
	find $(TESTS_TMP) -type f -name "*.swap" -delete 2>/dev/null || true
	$(ECHO) "cawk clean tmp done ----"

clean_force: clean
	@if [ "$(FORCE)" != "yes" ]; then \
		$(ECHO) "Error: FORCE=yes must be set to run clean_force."; \
		exit 1; \
	fi
	@$(ECHO) "FORCE='$(FORCE)'. Proceeding with clean_force..."
	gmake clean clean_report_repo clean_backup clean_report_run clean_report_run_audit clean_archive_repo clean_archive_run clean_archive_run_audit
	@$(ECHO) "cawk clean_force done ----"

clean_archive_older:
	find reports -type f -name '*.tar.gz' -mtime +$(ARCHIVE_OLDER_DAYS) -exec rm -f {} \; 2>/dev/null || true


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# CATALOG MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


catalog_build_repo: tests_target_common
	if [ -d tests/repo ]; then \
		find tests/repo -type f \( -name "*.m4" -o -name "*.template" \) | sort | while read file; do common/catalog_build_db.gawk repo "$$file"; done ;\
	else \
		$(ECHO) "cawk error: tests/repo directory does not exist ----" ;\
	fi
	$(ECHO) "cawk catalog_build_repo done ----"
	if [ -d tests/run ]; then \
		find tests/run -type f \( -name "*.m4" -o -name "*.template" \) | sort | while read file; do common/catalog_build_db.gawk run "$$file"; done ;\
	else \
		$(ECHO) "cawk error: tests/run directory does not exist ----" ;\
	fi
	$(ECHO) "cawk catalog_build_run done ----"

catalog_build_run: tests_target_common
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error: audit variable is not set for catalog_build_run ----"
else
	if [ -d tests/run_$(audit) ]; then \
		find tests/run_$(audit) -type f \( -name "*.m4" -o -name "*.template" \) | sort | while read file; do common/catalog_build_db.gawk $(audit) "$$file"; done ;\
	else \
		$(ECHO) "cawk error: tests/run_$(audit) directory does not exist ----" ;\
	fi
	$(ECHO) "cawk catalog_build_run $(audit) done ----"
endif

catalog_build: tests_target_common
	rm -f $(DATABASE_PATH)/db_info.txt
	touch $(DATABASE_PATH)/db_info.txt
	gmake catalog_build_repo
	@RUN_DIRS="$$(find tests -name '*run_*' -type d 2>/dev/null | awk -F'run_' '{print $$NF}' | sort -u || echo '')"; \
	if [ -z "$$RUN_DIRS" ]; then \
		$(ECHO) "cawk catalog_build: no run audits found, skipping catalog_build_run"; \
	else \
		for audit in $$RUN_DIRS; do \
			gmake catalog_build_run audit=$$audit; \
		done; \
	fi
	gmake catalog_nist_mappings
	$(ECHO) "cawk catalog_build done ----"

catalog_nist_mappings:
	$(TESTS_COMMON_PATH)/catalog_nist_mappings.gawk $(DATABASE_PATH)/db_info.txt > $(DATABASE_PATH)/db_nist_mappings.json
	$(ECHO) "cawk catalog_nist_mappings done - generated $(DATABASE_PATH)/db_nist_mappings.json"

catalog_repo: tests_target_common
	@for supplier in $(shell find confs/repo -maxdepth 1 -type d -name "confs.*" | sed 's|.*/confs\.||' | sort | xargs); do \
		$(ECHO) ""; \
		common/catalog_info.gawk repo $$supplier; \
	done
	$(ECHO) "cawk catalog_repo done ----"

catalog_run: tests_target_common
ifeq ($(strip $(audit)),)
	@for supplier in $(shell find confs/run -maxdepth 1 -type d -name "confs.*" | sed 's|.*/confs\.||' | sort | xargs); do \
		$(ECHO) ""; \
		common/catalog_info.gawk run $$supplier; \
	done
	$(ECHO) "cawk catalog_run done ----"
else
	@for supplier in $(shell find confs/run_$(audit) -maxdepth 1 -type d -name "confs.*" | sed 's|.*/confs\.||' | sort | xargs); do \
		$(ECHO) ""; \
		common/catalog_info.gawk $(audit) $$supplier; \
	done
	$(ECHO) "cawk catalog_run $(audit) done ----"
endif

nist_coverage_official:
	@$(ECHO) "NIST 800-53 Coverage Analysis (Official)"
	@$(ECHO) "=========================================="
	@total=$$(wc -l < $(DATABASE_PATH)/db_nist800-53.txt); total=$$(($$total - 1)); \
	$(ECHO) "Total NIST 800-53 controls in official benchmark: $$total"; \
	covered=$$(cut -d';' -f7 $(DATABASE_PATH)/db_info.txt | grep -v "to be defined" | grep -v "nist800-53_ref" | cut -d'|' -f1 | sort -u | wc -l); \
	$(ECHO) "NIST 800-53 controls covered by tests: $$covered"; \
	if [ $$total -gt 0 ]; then \
		percent=$$(($$covered * 100 / $$total)); \
		$(ECHO) "Coverage percentage: $$percent%"; \
	fi

nist_coverage_repo: nist_coverage_official
	@$(ECHO) ""
	@$(ECHO) "NIST 800-53 Coverage by Supplier (repo):"
	@$(ECHO) "========================================"
	@for supplier in $(SUPPLIER_SCOPE); do \
		covered=$$(grep "$$supplier" $(DATABASE_PATH)/db_info.txt | cut -d';' -f7 | grep -v "to be defined" | sort -u | wc -l); \
		if [ $$covered -gt 0 ]; then \
			$(ECHO) "$$supplier: $$covered controls"; \
		fi \
	done

nist_coverage_run: nist_coverage_official
ifeq ($(strip $(audit)),)
	@$(ECHO) ""
	@$(ECHO) "NIST 800-53 Coverage by Supplier (run):"
	@$(ECHO) "========================================"
	@for supplier in $(SUPPLIER_SCOPE); do \
		covered=$$(grep "$$supplier" $(DATABASE_PATH)/db_info.txt | cut -d';' -f7 | grep -v "to be defined" | sort -u | wc -l); \
		if [ $$covered -gt 0 ]; then \
			$(ECHO) "$$supplier: $$covered controls"; \
		fi \
	done
else
	@$(ECHO) ""
	@$(ECHO) "NIST 800-53 Coverage by Supplier (run_$(audit)):"
	@$(ECHO) "================================================"
	@for supplier in $(SUPPLIER_SCOPE); do \
		covered=$$(grep "$$supplier" $(DATABASE_PATH)/db_info.txt | cut -d';' -f7 | grep -v "to be defined" | sort -u | wc -l); \
		if [ $$covered -gt 0 ]; then \
			$(ECHO) "$$supplier: $$covered controls"; \
		fi \
	done
endif

catalog_exceptions_repo: tests_target_common
	@for supplier in $(shell find exceptions/repo -maxdepth 1 -name "exceptions.*.m4" | sed 's|.*exceptions\.||;s|\.m4||' | sort -u | xargs); do \
		$(ECHO) ""; \
		common/catalog_exceptions_info.gawk repo $$supplier; \
	done
	$(ECHO) "cawk catalog_exceptions_repo done ----"

catalog_exceptions_run: tests_target_common
ifeq ($(strip $(audit)),)
	@for supplier in $(shell find exceptions/run -maxdepth 1 -name "exceptions.*.m4" | sed 's|.*exceptions\.||;s|\.m4||' | sort -u | xargs); do \
		$(ECHO) ""; \
		common/catalog_exceptions_info.gawk run $$supplier; \
	done
	$(ECHO) "cawk catalog_exceptions_run done ----"
else
	@for supplier in $(shell find exceptions/run_$(audit) -maxdepth 1 -name "exceptions.*.m4" | sed 's|.*exceptions\.||;s|\.m4||' | sort -u | xargs); do \
		$(ECHO) ""; \
		common/catalog_exceptions_info.gawk $(audit) $$supplier; \
	done
	$(ECHO) "cawk catalog_exceptions_run $(audit) done ----"
endif

# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# EXCEPTIONS MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------

exceptions_repo:
	$(foreach exc,$(wildcard $(EXCEPTION_PATH)/repo/*.m4),m4 -I m4 $(exc) | sed '/^$$/d' > $(basename $(exc)) || true ; chmod 650 $(basename $(exc)) ;)
	$(ECHO) "cawk exceptions_repo done ----"

exceptions_run:
ifeq ($(strip $(audit)),)
	$(foreach exc,$(wildcard $(EXCEPTION_PATH)/run/*.m4),m4 -I m4 $(exc) | sed '/^$$/d' > $(basename $(exc)) || true ; chmod 650 $(basename $(exc)) ;)
else
	$(foreach exc,$(wildcard $(EXCEPTION_PATH)/run_${audit}/*.m4),m4 -I m4 $(exc) | sed '/^$$/d' > $(basename $(exc)) || true ; chmod 650 $(basename $(exc)) ;)
endif
	$(ECHO) "cawk exceptions_run done ----"

exceptions_build_repo: tests_target_common
	if [ -d exceptions/repo ]; then \
		find exceptions/repo -type f -name "*.m4" | sort | while read file; do common/catalog_build_exceptions_db.gawk repo "$$file"; done ;\
	else \
		$(ECHO) "cawk error: exceptions/repo directory does not exist ----" ;\
	fi
	$(ECHO) "cawk exceptions_build_repo done ----"
	if [ -d exceptions/run ]; then \
		find exceptions/run -type f -name "*.m4" | sort | while read file; do common/catalog_build_exceptions_db.gawk run "$$file"; done ;\
	else \
		$(ECHO) "cawk error: exceptions/run directory does not exist ----" ;\
	fi
	$(ECHO) "cawk exceptions_build_run done ----"

exceptions_build_run: tests_target_common
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error: audit variable is not set for exceptions_build_run ----"
else
	if [ -d exceptions/run_$(audit) ]; then \
		find exceptions/run_$(audit) -type f -name "*.m4" | sort | while read file; do common/catalog_build_exceptions_db.gawk $(audit) "$$file"; done ;\
	else \
		$(ECHO) "cawk error: exceptions/run_$(audit) directory does not exist ----" ;\
	fi
	$(ECHO) "cawk exceptions_build_run $(audit) done ----"
endif

exceptions_build: tests_target_common
	rm -f $(DATABASE_PATH)/db_exception.txt
	touch $(DATABASE_PATH)/db_exception.txt
	gmake exceptions_build_repo
	@RUN_DIRS="$$(find exceptions -name '*run_*' -type d 2>/dev/null | awk -F'run_' '{print $$NF}' | sort -u || echo '')"; \
	if [ -z "$$RUN_DIRS" ]; then \
		$(ECHO) "cawk exceptions_build: no run audits found, skipping exceptions_build_run"; \
	else \
		for audit in $$RUN_DIRS; do \
			gmake exceptions_build_run audit=$$audit; \
		done; \
	fi
	$(ECHO) "cawk exceptions_build done ----"


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# GIT MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


gitcheck: tests_target_common
	gmake clean clean_force FORCE=yes
	
	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start check databases\033[0m"
	rm -f $(DATABASE_PATH)/db_info.txt
	rm -f $(DATABASE_PATH)/db_exception.txt
	rm -f $(DATABASE_PATH)/db_email.txt
	rm -f $(DATABASE_PATH)/db_postaudit.txt
	rm -f $(DATABASE_PATH)/db_sync.txt
	rm -f $(DATABASE_PATH)/db_nist_mappings.json
	touch $(DATABASE_PATH)/db_email.txt
	touch $(DATABASE_PATH)/db_postaudit.txt
	touch $(DATABASE_PATH)/db_sync.txt
	touch $(DATABASE_PATH)/db_info.txt
	touch $(DATABASE_PATH)/db_exception.txt
	gmake catalog_build
	gmake exceptions_build
	@$(ECHO) "\033[31m================================================== : end check databases\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start filename without gawk code\033[0m"
	find tests/ -type f ! -name "*gawk*" ! -name ".gitkeep" | awk '{print "\033[37m" $$0 "\033[0m"}'
	@$(ECHO) "\033[31m================================================== : end check filename without gawk code\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start check tests error code\033[0m"
	gmake tests_check_nok
	gmake clean clean_force FORCE=yes
	@$(ECHO) "\033[31m================================================== : end check tests error code\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start check system check\033[0m"
	chmod 750 system/cawk_check_system
	@$(ECHO) "\033[0m" ; gmake system ; $(ECHO) "\033[0m"
	@$(ECHO) "\033[31m================================================== : end call system check\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start supplier list\033[0m"
	gmake supplier | awk '{print "\033[37m" $$0 "\033[0m"}'
	@$(ECHO) "\033[31m================================================== : end supplier list\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start audit list\033[0m"
	gmake list_audit | awk '{print "\033[37m" $$0 "\033[0m"}'
	@$(ECHO) "\033[31m================================================== : end audit list\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start no *.gawk must be there\033[0m"
	find . -name *.gawk | awk '{print "\033[37m" $$0 "\033[0m"}'
	@$(ECHO) "\033[31m================================================== : end no *.gawk must be there\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start no *.script must be there\033[0m"
	find . -name .DS_Store | xargs rm -f
	@$(ECHO) "\033[31m================================================== : end clean DS store file\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start clean vscode param\033[0m"
	find . -name .DS_Store | xargs rm -f
	rm -r -f .vscode
	@$(ECHO) "\033[31m================================================== : end clean vscode param\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start update run repository confs && tests && exceptions from repo\033[0m"
	rm -r confs/run && cp -r confs/repo confs/run
	rm -r tests/run && cp -r tests/repo tests/run
	rm -r exceptions/run && cp -r exceptions/repo exceptions/run
	@$(ECHO) "\033[31m================================================== : end update run repository confs && tests && exceptions from repo\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start touch .gitkeep in reports and tmp\033[0m"
	touch reports/repo/.gitkeep && touch reports/run/.gitkeep && touch tmp/.gitkeep
	touch reports/repo/archives/.gitkeep && touch reports/run/archives/.gitkeep
	@$(ECHO) "\033[31m================================================== : end touch .gitkeep in reports and tmp\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start check .gitkeep in directories\033[0m"
	@for dir in reports/repo reports/run tests/repo tests/run confs/repo confs/run exceptions/repo exceptions/run tmp; do \
		if [ ! -f "$$dir/.gitkeep" ]; then \
			$(ECHO) "$$dir" | awk '{print "\033[37m" $$0 "\033[0m"}'; \
		fi; \
	done
	@$(ECHO) "\033[31m================================================== : end check .gitkeep in directories\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start check CRLF in test templates\033[0m"
	find tests/repo -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -l "$$(printf '\r')" {} \; | awk '{print "\033[37m" $$0 "\033[0m"}'
	find database -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -l "$$(printf '\r')" {} \; | awk '{print "\033[37m" $$0 "\033[0m"}'
	find common -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -l "$$(printf '\r')" {} \; | awk '{print "\033[37m" $$0 "\033[0m"}'
	find confs -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -l "$$(printf '\r')" {} \; | awk '{print "\033[37m" $$0 "\033[0m"}'
	find exceptions -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -l "$$(printf '\r')" {} \; | awk '{print "\033[37m" $$0 "\033[0m"}'
	find m4 -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -l "$$(printf '\r')" {} \; | awk '{print "\033[37m" $$0 "\033[0m"}'
	find support -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -l "$$(printf '\r')" {} \; | awk '{print "\033[37m" $$0 "\033[0m"}'
	find system -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -l "$$(printf '\r')" {} \; | awk '{print "\033[37m" $$0 "\033[0m"}'
	@$(ECHO) "\033[31m================================================== : end check CRLF in test templates\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start check metadata in test templates\033[0m"
	@missing=$$(find tests/repo -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -L "# @test_name\|# @supplier\|# @purpose\|# @description\|# @actions\|# @nist800-53_ref\|# @authors" {} \;); \
	if [ -n "$$missing" ]; then \
		echo "$$missing" | sed 's/^/  /' | awk '{print "\033[37m❌ " $$0 "\033[0m"}'; \
	fi
	@$(ECHO) "\033[31m================================================== : end check metadata in test templates\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start check databases are not empty\033[0m"
	@for db in database/db_info.txt database/db_exception.txt; do \
		if [ ! -s "$$db" ]; then \
			$(ECHO) "$$db" | awk '{print "\033[37m❌ empty: " $$0 "\033[0m"}'; \
		fi; \
	done
	@$(ECHO) "\033[31m================================================== : end check databases are not empty\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start check critical directories exist\033[0m"
	@for dir in confs tests exceptions reports tmp database; do \
		if [ ! -d "$$dir" ]; then \
			$(ECHO) "$$dir" | awk '{print "\033[37m❌ missing directory: " $$0 "\033[0m"}'; \
		fi; \
	done
	@$(ECHO) "\033[31m================================================== : end check critical directories exist\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start check archives directories exist\033[0m"
	@for archdir in reports/repo/archives reports/run/archives; do \
		if [ ! -d "$$archdir" ]; then \
			$(ECHO) "$$archdir" | awk '{print "\033[37m❌ missing directory: " $$0 "\033[0m"}'; \
		fi; \
	done
	@$(ECHO) "\033[31m================================================== : end check archives directories exist\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start check file extensions (.template.m4 invalid)\033[0m"
	@invalid=$$(find tests/repo exceptions/repo -type f -name "*.template.m4" -o -name "*.m4.template"); \
	if [ -n "$$invalid" ]; then \
		echo "$$invalid" | awk '{print "\033[37m❌ invalid extension: " $$0 "\033[0m"}'; \
	fi
	@$(ECHO) "\033[31m================================================== : end check file extensions\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start check backup files (.orig)\033[0m"
	@backups=$$(find . -type f -name "*.orig" 2>/dev/null | sort); \
	if [ -n "$$backups" ]; then \
		$(ECHO) "\033[37m✓ Backup files found:\033[0m"; \
		echo "$$backups" | awk '{print "\033[37m  " $$0 "\033[0m"}'; \
	else \
		$(ECHO) "\033[37m ℹ No backup files (.orig) found\033[0m"; \
	fi
	@$(ECHO) "\033[31m================================================== : end check backup files\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start update Makefile.support.mk with CAWK_RELEASE = $(CAWK_RELEASE)\033[0m"
	@$(ECHO) "\033[31m================================================== : end update Makefile.support.mk with CAWK_RELEASE = $(CAWK_RELEASE)\033[0m"

git:
	# gmake gitcheck
	# find confs -type f -exec touch {} \;
	# git add .
	# git commit -m "*$(CAWK_RELEASE) ref ChangeLog"

gitpush:
	# git push https://github.com/cedricllorens/cawk.git master


# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# CHECK MANAGEMENT TARGETS
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------


check:
	gmake clean clean_force FORCE=yes
	find confs -type f -exec touch {} \;
	rm -f checkdiff/checkdiff.new

	gmake catalog_build
	gmake exceptions_build

	gmake check_repo
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	gmake check_repo supplier=cisco-ios
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	gmake check_repo JSON=no
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	gmake check_repo JSON=yes
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	gmake check_run
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	gmake check_run supplier=cisco-ios
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	gmake check_run JSON=no
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	gmake check_run JSON=yes
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	gmake check_run
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	gmake check_run supplier=cisco-ios
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	gmake check_run JSON=no
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	gmake check_run JSON=yes
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	gmake delete_audit audit=client1_skffqsfqhsf10948494
	gmake create_audit audit=client1_skffqsfqhsf10948494
	gmake sync_run audit=client1_skffqsfqhsf10948494
	gmake check_run audit=client1_skffqsfqhsf10948494
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	gmake check_run audit=client1_skffqsfqhsf10948494 supplier=cisco-ios
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	gmake delete_audit audit=client2_mqsdhqndqqos198440
	gmake create_audit audit=client2_mqsdhqndqqos198440
	gmake check_run audit=client2_mqsdhqndqqos198440
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	gmake check_run audit=client2_mqsdhqndqqos198440 supplier=cisco-ios
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	
	gmake clean
	gmake check_repo
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	gmake check_repo
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	gmake check_run
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	gmake check_run audit=client1_skffqsfqhsf10948494
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	gmake check_run audit=client2_mqsdhqndqqos198440

	gmake view_repo | wc -l >> checkdiff/checkdiff.new
	gmake view_repo_error | wc -l >> checkdiff/checkdiff.new
	gmake view_repo supplier=cisco-ios | wc -l >> checkdiff/checkdiff.new
	gmake view_run | wc -l >> checkdiff/checkdiff.new
	gmake view_run supplier=cisco-ios | wc -l >> checkdiff/checkdiff.new
	gmake view_run supplier=cisco-ios audit=client1_skffqsfqhsf10948494 | wc -l >> checkdiff/checkdiff.new
	gmake view_run supplier=cisco-ios audit=client2_mqsdhqndqqos198440 | wc -l >> checkdiff/checkdiff.new

	gmake backup_run audit=client2_mqsdhqndqqos198440
	gmake backup_run audit=client1_skffqsfqhsf10948494
	gmake backup_run_audit
	find backup/ -name '*.tar.gz' | wc -l >> checkdiff/checkdiff.new
	
	gmake clean
	gmake delete_audit audit=client1_skffqsfqhsf10948494
	gmake delete_audit audit=client2_mqsdhqndqqos198440
	gmake restore_run_audit file=backup/run_audit_$(shell date +%Y-%m-%d).tar.gz
	
	gmake check_run audit=client1_skffqsfqhsf10948494
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	gmake check_run audit=client1_skffqsfqhsf10948494 supplier=cisco-ios
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	gmake clean
	gmake delete_audit audit=client1_skffqsfqhsf10948494
	gmake delete_audit audit=client2_mqsdhqndqqos198440
	gmake restore_run_audit file=backup/run_audit_client1_skffqsfqhsf10948494_$(shell date +%Y-%m-%d).tar.gz

	gmake check_run audit=client1_skffqsfqhsf10948494
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	gmake check_run audit=client1_skffqsfqhsf10948494 supplier=cisco-ios
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	gmake clean
	gmake delete_audit audit=client1_skffqsfqhsf10948494
	gmake delete_audit audit=client2_mqsdhqndqqos198440

	gmake create_audit audit=client1_skffqsfqhsf10948494
	rm -r -f confs/run*client1_skffqsfqhsf10948494/*cisco-ios* tests/run*client1_skffqsfqhsf10948494/*cisco-ios* || true
	gmake check_run audit=client1_skffqsfqhsf10948494 JSON=no
	gmake check_run audit=client1_skffqsfqhsf10948494 JSON=yes
	gmake check_run audit=client1_skffqsfqhsf10948494 JSON=no supplier=cisco-ios
	gmake check_run audit=client1_skffqsfqhsf10948494 JSON=yes supplier=cisco-ios
	gmake delete_audit audit=client1_skffqsfqhsf10948494
	gmake clean clean_force FORCE=yes

	rm -f checkdiff/cawk-crypto-image.new
	sha512sum checkdiff/checkdiff.new > checkdiff/cawk-crypto-image.new

	$(ECHO) "------------------------------------------------------"
	$(ECHO) "------------------------------------------------------"
	$(ECHO) "CHECK MUST BE OK -------------------------------------"
	$(ECHO) "------------------------------------------------------"
	$(ECHO) "check cawk commands ----"
	diff checkdiff/checkdiff.new checkdiff/checkdiff.old >/dev/null && $(ECHO) OK || $(ECHO) NOK
	$(ECHO) "check cawk crypto image ----"
	diff checkdiff/cawk-crypto-image.new checkdiff/cawk-crypto-image.old >/dev/null && $(ECHO) OK || $(ECHO) NOK
	$(ECHO) "------------------------------------------------------"
	$(ECHO) "CHECK MUST BE OK -------------------------------------"
	$(ECHO) "------------------------------------------------------"
	$(ECHO) "------------------------------------------------------"
	$(ECHO) "cawk check done ----"

check_parallel:
	gmake check MAKE_PARALLEL=yes

check_update:
	rm -f checkdiff/cawk-crypto-image.new
	sha512sum checkdiff/checkdiff.new > checkdiff/cawk-crypto-image.new
	cp -v checkdiff/checkdiff.new checkdiff/checkdiff.old
	cp -v checkdiff/cawk-crypto-image.new checkdiff/cawk-crypto-image.old
	$(ECHO) "cawk check_update done ----"

check_debug: check_checkdiff
	./checkdiff/scripts/check_debug
	$(ECHO) "cawk check_debug completed - use 'gmake check_analyze' to see results"

check_analyze: check_checkdiff
	./checkdiff/scripts/analyze_diff
	$(ECHO) "cawk check_analyze completed - checkdiff/checkdiff_report.txt generated with analysis results"

check_debug_log: check_checkdiff
	./checkdiff/scripts/run_check log
	$(ECHO) "cawk check_debug_log completed - checkdiff/checkdiff_log.txt generated with debug logs"

check_parallel_debug: check_checkdiff
	./checkdiff/scripts/check_parallel_debug
	$(ECHO) "cawk check_parallel_debug completed - use 'gmake check_analyze' to see results"

check_checkdiff:
	gmake checkdiff/scripts/analyze_diff checkdiff/scripts/check_debug checkdiff/scripts/check_parallel_debug checkdiff/scripts/run_check checkdiff/scripts/diff_reports
	$(ECHO) "cawk check_checkdiff done ----"

