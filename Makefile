# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2025 by Cedric Llorens
# ------------------------------------------------------------

# ---------------

include Makefile.support.mk

# --------------- GNU MAKE TARGETS

.PHONY: all version check_repo check_run check_run_audit tests tests_target view_repo view_run view_repo_error view_run_error clean_force clean_report clean_backup clean_tmp clean clean clean_report_repo clean_report_run clean_report_run_audit clean_archive_older clean_archive_repo clean_archive_run clean_archive_run_audit catalog_repo catalog_run git gitpush gitcheckdist supplier check_supplier system common create_audit delete_audit list_audit archive_run archive_repo check_parallel check_update check sync_run sync_run_audit backup_run backup_run_audit restore_run restore_run_audit database_view database_sync_add database_sync_update database_sync_del database_email_add database_email_update database_email_del email_send email_send_audit database_target_sh tests_check tests_run_copy tests_run_audit_copy database_postaudit_add database_postaudit_del migrate database_postaudit_update database_scripts_copy database_repo_copy sync_run_audit_psirt

# --------------------------------

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
	$(ECHO) "# gmake clean_force : (USE WITH CAUTION) clean all including reports, backups, archives for all assessments"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK TESTS -------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# gmake tests_check : check if the tests are cawk compliant, all cawk pass and cawk error are displayed"
	$(ECHO) "# gmake tests_check_nok : check if the tests are cawk compliant, only cawk error are displayed"
	$(ECHO) "# gmake tests_common : build tests associated to common dir"
	$(ECHO) "# gmake tests_repo : build tests associated to repo dir"
	$(ECHO) "# gmake tests_run : build tests associated to run dir"
	$(ECHO) "# gmake tests_run audit=AUDIT_NAME : build tests associated to run_audit dir"
	$(ECHO) "# gmake tests_run_audit : build tests associated to all audit=AUDIT_NAME run_audit dirs"
	$(ECHO) "# CAUTION : for update or migration purpose, it will replace all the same repo tests in the run_audit dir"
	$(ECHO) "# CAUTION : user specific tests will remaint in the run_audit dir"	
	$(ECHO) "# NOTE    : only available for audit=AUDIT_NAME assessments"
	$(ECHO) "# gmake tests_run_copy audit=AUDIT_NAME : copy tests from repo to audit=AUDIT_NAME (ref run_audit)"
	$(ECHO) "# gmake tests_run_audit_copy : copy tests from repo to all audit=AUDIT_NAMEs (ref all run_audit)"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK ASSESSMENT --------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# gmake create_audit audit=AUDIT_NAME : create AUDIT_NAME tests, exceptions, confs directories (ref run_audit)"
	$(ECHO) "# gmake delete_audit audit=AUDIT_NAME : delete AUDIT_NAME tests, exceptions, confs directories (ref run_audit)"
	$(ECHO) "# gmake list_audit : list all the AUDIT_NAMEs (audit=AUDIT_NAME)"
	$(ECHO) "# gmake run_audit : run assessments for all the AUDIT_NAMEs (audit=AUDIT_NAME)"
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
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK SYNC --------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# NOTE    : only available for audit=AUDIT_NAME assessment"
	$(ECHO) "# NOTE    : it relies on the cawk sync database (i.e.README)"
	$(ECHO) "# CAUTION : local confs files are removed during sync (confs/run_audit dir) (i.e.README)"
	$(ECHO) "# gmake sync_run audit=AUDIT_NAME : build inventory and sync confs from a central repository to confs/run_audit dir"
	$(ECHO) "# gmake sync_run_audit : build inventory and sync confs from a central repository to all confs/run_audit dirs"
	$(ECHO) "# gmake sync_psirt : build psirt inventory to be used by psirt tests"
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
	$(ECHO) "# gmake catalog_repo : build the tests description catalog for repo"
	$(ECHO) "# gmake catalog_run : build the tests description catalog for run"
	$(ECHO) "# gmake catalog_run audit=AUDIT_NAME: build the tests description catalog for audit=AUDIT_NAME"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"

# --------------------------------

version:
	@$(ECHO) "cawk version: " $(CAWK_RELEASE)
	@$(ECHO) "cawk version done ----"

# --------------------------------

create_audit:
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
ifneq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	$(ECHO) "cawk error audit=${audit} already exist ----"
else
	cp -r $(TESTS_PATH)/repo $(TESTS_PATH)/run_${audit}
	cp -r $(EXCEPTION_PATH)/repo exceptions/run_${audit}
	cp -r $(CONFS_PATH)/repo $(CONFS_PATH)/run_${audit} 
	mkdir $(REPORT_PATH)/run_${audit}
	mkdir $(REPORT_PATH)/run_${audit}/archives
	mkdir $(LOGS_PATH)/run_${audit}
	gmake database_postaudit_add audit=${audit}
	gmake database_email_add audit=${audit} dst=none cc=none
	gmake database_sync_add audit=${audit} dir=none regex=.* scope=none regexos=.* regexpathexclude=none
endif
endif
	$(ECHO) "cawk create_audit end ----"

delete_audit:
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
else
	rm -f -r $(TESTS_PATH)/run_${audit}
	rm -f -r $(CONFS_PATH)/run_${audit}
	rm -f -r $(EXCEPTION_PATH)/run_${audit}
	rm -f -r $(REPORT_PATH)/run_${audit}
	rm -f -r $(LOGS_PATH)/run_${audit}
	$(EGREP) "^${audit}" $(DATABASE_PATH)/db_sync.txt > /dev/null && sed -i "/^${audit}/d" $(DATABASE_PATH)/db_sync.txt || true
	$(EGREP) "^${audit}" $(DATABASE_PATH)/db_postaudit.txt > /dev/null && sed -i "/^${audit}/d" $(DATABASE_PATH)/db_postaudit.txt || true
	$(EGREP) "^${audit}" $(DATABASE_PATH)/db_email.txt > /dev/null && sed -i "/^${audit}/d" $(DATABASE_PATH)/db_email.txt || true
endif
endif
	$(ECHO) "cawk delete_audit end ----"

list_audit:
	find tests -name '*run_*' -type d | awk -F'run_' '{print $$NF}' | sort -u
	$(ECHO) "cawk list_audit end ----"

# --------------------------------

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
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
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
	$(ECHO) "${audit} ${dir} ${regex} ${scope} ${regexos} $(regexpathexclude)" >> $(DATABASE_PATH)/db_sync.txt
endif
endif
endif
endif
endif
endif
endif
	$(ECHO) "cawk database_sync_add end ----"

database_sync_update:
	touch $(DATABASE_PATH)/db_sync.txt
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
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
	@sed -i "/^$(audit)/d" $(DATABASE_PATH)/db_sync.txt
	$(ECHO) "${audit} ${dir} ${regex} ${scope} ${regexos} $(regexpathexclude)" >> $(DATABASE_PATH)/db_sync.txt
endif
endif
endif
endif
endif
endif
endif
	$(ECHO) "cawk database_sync_add end ----"

database_sync_del:
	touch $(DATABASE_PATH)/db_sync.txt
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
else
	$(ECHO) "cawk update $(DATABASE_PATH)/db_sync.txt"
	sed -i "/^$(audit)/d" $(DATABASE_PATH)/db_sync.txt
endif
endif
	$(ECHO) "cawk database_sync_add end ----"

database_postaudit_add:
	touch $(DATABASE_PATH)/db_postaudit.txt
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
else
	$(ECHO) "cawk update $(DATABASE_PATH)/db_postaudit.txt"
	$(ECHO) "${audit}" >> $(DATABASE_PATH)/db_postaudit.txt
endif
endif
	$(ECHO) "cawk database_postaudit_add end ----"

database_postaudit_update:
	touch $(DATABASE_PATH)/db_postaudit.txt
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
else
	$(ECHO) "cawk update $(DATABASE_PATH)/db_postaudit.txt"
	sed -i "/^$(audit)/d" $(DATABASE_PATH)/db_postaudit.txt
	$(ECHO) "${audit}" >> $(DATABASE_PATH)/db_postaudit.txt
endif
endif
	$(ECHO) "cawk database_postaudit_add end ----"

database_postaudit_del:
	touch $(DATABASE_PATH)/db_postaudit.txt
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
else
	$(ECHO) "cawk update $(DATABASE_PATH)/db_postaudit.txt"
	sed -i "/^$(audit)/d" $(DATABASE_PATH)/db_postaudit.txt
endif
endif
	$(ECHO) "cawk database_postaudit_add end ----"

database_email_add:
	touch $(DATABASE_PATH)/db_email.txt
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(strip $(dst)),)
	$(ECHO) "cawk error dst=RECIPIENT_EMAIL must be set ----"
else
	cc=$(strip $(cc))
	if [ -z "$$cc" ]; then cc=none; fi; \
	$(ECHO) "cawk update $(DATABASE_PATH)/db_email.txt"; \
	$(ECHO) "$(audit) $(dst) $$cc" >> $(DATABASE_PATH)/db_email.txt
endif
endif
	$(ECHO) "cawk email_database_add end ----"

database_email_update:
	touch $(DATABASE_PATH)/db_email.txt
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(strip $(dst)),)
	$(ECHO) "cawk error dst=RECIPIENT_EMAIL must be set ----"
else
	cc=$(strip $(cc))
	if [ -z "$$cc" ]; then cc=none; fi; \
	$(ECHO) "cawk update $(DATABASE_PATH)/db_email.txt"; \
	sed -i "/^$(audit)/d" $(DATABASE_PATH)/db_email.txt
	$(ECHO) "${audit} ${dst} ${cc}" >> $(DATABASE_PATH)/db_email.txt
endif
endif
	$(ECHO) "cawk email_database_update end ----"

database_email_del:
	touch $(DATABASE_PATH)/db_email.txt
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
	$(ECHO) "cawk update $(DATABASE_PATH)/db_email.txt"
	sed -i "/^$(audit)/d" $(DATABASE_PATH)/db_email.txt
endif
	$(ECHO) "cawk email_database_del end ----"

database_repo_copy:
	# Ensure the database directories exist
	mkdir -p $(DATABASE_PATH) || true
	for dir in $(shell find $(DATABASE_REPO_PATH) -type d); do \
		target_dir=$(DATABASE_PATH)/$${dir#$(DATABASE_REPO_PATH)/}; \
		if [ ! -d "$$target_dir" ]; then \
			$(ECHO) "cawk creating directory $$target_dir ----"; \
			cp -r $$dir $$target_dir || true; \
		else \
			$(ECHO) "cawk directory $$target_dir already exists, skipping creation ----"; \
		fi \
	done
	# Ensure the database exist
	for base in $$(find $(DATABASE_REPO_PATH) -name 'db_*.txt'); do \
		if [ ! -f $(DATABASE_PATH)/$$(basename $$base) ]; then \
			$(ECHO) "cawk copy database base $$base to $(DATABASE_PATH)/"; \
			cp $$base $(DATABASE_PATH)/; \
		else \
			$(ECHO) "cawk database base $$base already exist in $(DATABASE_PATH)/, skipping copy"; \
		fi \
	done
	# Ensure the database scripts exist
	for script in $$(find $(DATABASE_REPO_PATH_SH) -name '*.sh'); do \
		if [ ! -f $(DATABASE_PATH_SH)/$$(basename $$script) ]; then \
			$(ECHO) "cawk copy database script $$script to $(DATABASE_PATH_SH)/"; \
			cp $$script $(DATABASE_PATH_SH)/; \
		else \
			$(ECHO) "cawk database script $$script already exist in $(DATABASE_PATH_SH)/, skipping copy"; \
		fi \
	done
	$(ECHO) "cawk database_scripts_copy done ----"

# --------------------------------

sync_run: clean_tmp tests_target_common database_target_sh
	if [ ! -f $(DATABASE_PATH_SH)/database_sync.script ]; then \
		$(ECHO) "cawk error: $(DATABASE_PATH_SH)/database_sync.script does not exist, execution skipped ----"; \
	else \
		$(ECHO) "cawk $(DATABASE_PATH_SH)/database_sync.script execution ----"; \
		$(DATABASE_PATH_SH)/database_sync.script ${audit}; \
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
	$(ECHO) "cawk sync_run_audit all audit done ----"

sync_psirt:
	if [ ! -f $(DATABASE_PATH_SH)/database_sync_psirt.script ]; then \
		$(ECHO) "cawk error: $(DATABASE_PATH_SH)/database_sync_psirt.script does not exist, execution skipped ----"; \
	else \
		$(ECHO) "cawk $(DATABASE_PATH_SH)/database_sync_psirt.script execution ----"; \
		$(DATABASE_PATH_SH)/database_sync_psirt.script ${audit}; \
	fi
	$(ECHO) "cawk sync_run_audit_psirt done ----"

# --------------------------------

postaudit_run: clean tests_target_common database_target_sh
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
	$(ECHO) "cawk postaudit_run done ----"
else
	if [ ! -f $(DATABASE_PATH_SH)/database_postaudit.script ]; then \
		$(ECHO) "cawk error: $(DATABASE_PATH_SH)/database_postaudit.script does not exist, execution skipped ----"; \
	else \
		$(ECHO) "cawk $(DATABASE_PATH_SH)/database_postaudit.script execution ----"; \
		$(DATABASE_PATH_SH)/database_postaudit.script ${audit}; \
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

# --------------------------------

email_send:
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
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
	$(ECHO) "cawk send_audit_email end ----"

email_send_audit:
	for audit in $(RUN_DIRS); do \
		gmake email_send audit=$$audit; \
	done
	$(ECHO) "cawk email_send_audit done ----"

# --------------------------------

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
	gmake database_repo_copy
	gmake tests_common tests_run_audit

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

# --------------------------------

tests_target_common: $(TESTS_COMMON_TEMPLATE:.gawk.template=.gawk) $(TESTS_COMMON_SH:.script.sh=.script)

database_target_sh: $(DATABASE_SH:.script.sh=.script)

tests_check: tests_target_common tests_target_repo tests_target_run
	find tests -name '*.gawk' -type f -exec common/check_test.gawk {} \; | awk '/cawk test pass/ {print "\033[32m" $$0 "\033[0m"} !/cawk test pass/ {print "\033[31m" $$0 "\033[0m"}'
	$(ECHO) "cawk tests_check done ----"

tests_check_nok: tests_target_common tests_target_repo tests_target_run
	find tests -name '*.gawk' -type f -exec common/check_test.gawk {} \; | awk '/cawk test pass/ {print "\033[32m" $$0 "\033[0m"} !/cawk test pass/ {print "\033[31m" $$0 "\033[0m"}' | $(EGREP) "cawk test error" || true
	$(ECHO) "cawk tests_check done ----"

tests_target_repo: tests_target_common\
		$(SUPPLIER_M4_REPO_FILES) \
		$(SUPPLIER_M4_REPO_PSIRT_FILES) \
		$(SUPPLIER_TEMPLATE_REPO_FILES) \
		$(SUPPLIER_TEMPLATE_REPO_PSIRT_FILES) \
		$(SUPPLIER_INCLUDE_REPO_PSIRT_FILES) \
		$(EXCEPTION_M4:.m4=)

tests_target_run: tests_target_common \
		$(SUPPLIER_M4_RUN_FILES) \
		$(SUPPLIER_M4_RUN_PSIRT_FILES) \
		$(SUPPLIER_TEMPLATE_RUN_FILES) \
		$(SUPPLIER_TEMPLATE_RUN_PSIRT_FILES) \
		$(SUPPLIER_INCLUDE_RUN_PSIRT_FILES) \
		$(EXCEPTION_M4:.m4=)

tests_common: tests_target_common
	$(ECHO) "cawk tests_common done ----"

tests_repo: tests_target_repo
	$(ECHO) "cawk tests_repo done ----"

tests_run_copy:
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
	for supplier in $(SUPPLIER_SCOPE); do \
		if [ ! -d "$(TESTS_PATH)/repo/tests.$$supplier" ]; then \
			$(ECHO) "cawk error: $(TESTS_PATH)/repo/tests.$$supplier does not exist ----"; \
		elif [ -d "$(TESTS_PATH)/repo/tests.$$supplier" ]; then \
			$(ECHO) "cawk tests_repo_copy $$supplier to run_$$audit start ----"; \
			mkdir -p $(TESTS_PATH)/run_$$audit/tests.$$supplier || true; \
			find $(TESTS_PATH)/repo/tests.$$supplier -name "*.template" -exec cp -v {} $(TESTS_PATH)/run_$$audit/tests.$$supplier/ \; || true; \
			find $(TESTS_PATH)/repo/tests.$$supplier -name "*.m4" -exec cp -v {} $(TESTS_PATH)/run_$$audit/tests.$$supplier/ \; || true; \
			$(ECHO) "cawk tests_repo_copy $$supplier to run_$$audit done ----"; \
		fi; \
		if [ ! -d "$(TESTS_PATH)/repo/tests.$$supplier.psirt" ]; then \
			$(ECHO) "cawk error: $(TESTS_PATH)/repo/tests.$$supplier.psirt does not exist ----"; \
		elif [ -d "$(TESTS_PATH)/repo/tests.$$supplier.psirt" ]; then \
			$(ECHO) "cawk tests_repo_copy $$supplier.psirt to run_$$audit start ----"; \
			mkdir -p $(TESTS_PATH)/run_$$audit/tests.$$supplier.psirt || true; \
			find $(TESTS_PATH)/repo/tests.$$supplier.psirt -name "*.template" -exec cp -v {} $(TESTS_PATH)/run_$$audit/tests.$$supplier.psirt/ \; || true; \
			find $(TESTS_PATH)/repo/tests.$$supplier.psirt -name "*.m4" -exec cp -v {} $(TESTS_PATH)/run_$$audit/tests.$$supplier.psirt/ \; || true; \
			find $(TESTS_PATH)/repo/tests.$$supplier.psirt -name "*.include" -exec cp -v {} $(TESTS_PATH)/run_$$audit/tests.$$supplier.psirt/ \; || true; \
			$(ECHO) "cawk tests_repo_copy $$supplier.psirt to run_$$audit done ----"; \
		fi; \
	done
endif

tests_run_audit_copy:
	for dir in $(RUN_DIRS); do \
		audit=$$dir; \
		for supplier in $(SUPPLIER_SCOPE); do \
			if [ ! -d "$(TESTS_PATH)/repo/tests.$$supplier" ]; then \
				$(ECHO) "cawk error: $(TESTS_PATH)/repo/tests.$$supplier does not exist ----"; \
			elif [ -d "$(TESTS_PATH)/repo/tests.$$supplier" ]; then \
				$(ECHO) "cawk tests_repo_copy $$supplier to run_$$audit start ----"; \
				mkdir -p $(TESTS_PATH)/run_$$audit/tests.$$supplier || true; \
				find $(TESTS_PATH)/repo/tests.$$supplier -name "*.template" -exec cp -v {} $(TESTS_PATH)/run_$$audit/tests.$$supplier/ \; || true; \
				find $(TESTS_PATH)/repo/tests.$$supplier -name "*.m4" -exec cp -v {} $(TESTS_PATH)/run_$$audit/tests.$$supplier/ \; || true; \
				$(ECHO) "cawk tests_repo_copy $$supplier to run_$$audit done ----"; \
			fi; \
			if [ ! -d "$(TESTS_PATH)/repo/tests.$$supplier.psirt" ]; then \
				$(ECHO) "cawk error: $(TESTS_PATH)/repo/tests.$$supplier.psirt does not exist ----"; \
			elif [ -d "$(TESTS_PATH)/repo/tests.$$supplier.psirt" ]; then \
				$(ECHO) "cawk tests_repo_copy $$supplier.psirt to run_$$audit tart ----"; \
				mkdir -p $(TESTS_PATH)/run_$$audit/tests.$$supplier.psirt || true; \
				find $(TESTS_PATH)/repo/tests.$$supplier.psirt -name "*.template" -exec cp -v {} $(TESTS_PATH)/run_$$audit/tests.$$supplier.psirt/ \; || true; \
				find $(TESTS_PATH)/repo/tests.$$supplier.psirt -name "*.m4" -exec cp -v {} $(TESTS_PATH)/run_$$audit/tests.$$supplier.psirt/ \; || true; \
				find $(TESTS_PATH)/repo/tests.$$supplier.psirt -name "*.include" -exec cp -v {} $(TESTS_PATH)/run_$$audit/tests.$$supplier.psirt/ \; || true; \
				$(ECHO) "cawk tests_repo_copy $$supplier.psirt to run_$$audit done ----"; \
			fi \
		done; \
	done

tests_run: tests_target_run
	$(ECHO) "cawk tests_run $$audit done ----"

tests_run_audit:
	@for dir in $(RUN_DIRS); do \
		gmake tests_run audit=$$dir; \
	done
	$(ECHO) "cawk tests_run_audit end ----"

# --------------------------------

check_repo: clean_report_repo clean_tmp tests_repo check_supplier
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
		\
		$(EGREP) -v -f $(EXCEPTION_PATH)/repo/exceptions.$(scope) $(REPORT_PATH)/repo/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/repo/assessment.$(scope).csv || true ;\
		cat $(REPORT_PATH)/repo/assessment.$(scope).csv | sort -u >> $(REPORT_PATH)/repo/assessment.all.csv.swap ;\
		$(EGREP) -f $(EXCEPTION_PATH)/repo/exceptions.$(scope) $(REPORT_PATH)/repo/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv || true ;\
		cat $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv | sort -u >> $(REPORT_PATH)/repo/assessment.all.exception.csv ;\
		$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/repo/assessment.all.deadbeef.csv $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv $(REPORT_PATH)/repo/assessment.$(scope).csv > $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt;\
		$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt;\
		gmake catalog_repo | $(EGREP) "tests/" | $(EGREP) $(scope) | sort >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
	)

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/repo/assessment.all.deadbeef.idx $(REPORT_PATH)/repo/assessment.all.csv.swap > $(REPORT_PATH)/repo/assessment.all.csv
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/repo/assessment.all.csv.swap $(REPORT_PATH)/repo/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/repo/assessment.all.deadbeef.csv $(REPORT_PATH)/repo/assessment.all.exception.csv $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	gmake catalog_repo | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.security.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.security.csv > $(REPORT_PATH)/repo/assessment.all.security.timeline.csv || true
	$(EGREP) ';psirt' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.psirt.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.psirt.csv > $(REPORT_PATH)/repo/assessment.all.psirt.timeline.csv || true
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.audit.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.audit.csv > $(REPORT_PATH)/repo/assessment.all.audit.timeline.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.timeline.csv
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.exception.csv > $(REPORT_PATH)/repo/assessment.all.exception.timeline.csv
	 $(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.deadbeef.csv > $(REPORT_PATH)/repo/assessment.all.deadbeef.timeline.csv
	sort -u $(REPORT_PATH)/repo/assessment.all.idx.swap > $(REPORT_PATH)/repo/assessment.all.idx; \

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
		find $(TESTS_$(scope)_REPO_PSIRT_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.repo.psirt.$(scope) 2>/dev/null || true ;\
		$(TESTS_COMMON_PATH)/gen_cawk_makefile.psirt.gawk $(TESTS_TMP)/conf_list_files.repo.$(scope) $(MAKE_FILES_PER_TARGET_PSIRT) $(TESTS_TMP)/conf_list_tests.repo.psirt.$(scope) > $(TESTS_TMP)/Makefile.repo.psirt.$(scope) 2>/dev/null || true ;\
		gmake -f $(TESTS_TMP)/Makefile.repo.psirt.$(scope) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all >> $(REPORT_PATH)/repo/assessment.$(scope).csv.swap 2>/dev/null || true ;\
		\
		$(EGREP) -v -f $(EXCEPTION_PATH)/repo/exceptions.$(scope) $(REPORT_PATH)/repo/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/repo/assessment.$(scope).csv || true ;\
		cat $(REPORT_PATH)/repo/assessment.$(scope).csv | sort -u >> $(REPORT_PATH)/repo/assessment.all.csv.swap ;\
		$(EGREP) -f $(EXCEPTION_PATH)/repo/exceptions.$(scope) $(REPORT_PATH)/repo/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv || true ;\
		cat $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv | sort -u >> $(REPORT_PATH)/repo/assessment.all.exception.csv ;\
		$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/repo/assessment.all.deadbeef.csv $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv $(REPORT_PATH)/repo/assessment.$(scope).csv > $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
		$(ECHO) "------------------------\n---- tests purposes ----\n------------------------" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt;\
		gmake catalog_repo | $(EGREP) "tests/" | $(EGREP) $(scope) | sort >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
	)

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/repo/assessment.all.deadbeef.idx $(REPORT_PATH)/repo/assessment.all.csv.swap > $(REPORT_PATH)/repo/assessment.all.csv || true
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/repo/assessment.all.csv.swap $(REPORT_PATH)/repo/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/repo/assessment.all.deadbeef.csv $(REPORT_PATH)/repo/assessment.all.exception.csv $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	gmake catalog_repo | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.security.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.security.csv > $(REPORT_PATH)/repo/assessment.all.security.timeline.csv || true
	$(EGREP) ';psirt' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.psirt.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.psirt.csv > $(REPORT_PATH)/repo/assessment.all.psirt.timeline.csv || true
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.audit.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.audit.csv > $(REPORT_PATH)/repo/assessment.all.audit.timeline.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.timeline.csv
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.exception.csv > $(REPORT_PATH)/repo/assessment.all.exception.timeline.csv || true
	 $(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.deadbeef.csv > $(REPORT_PATH)/repo/assessment.all.deadbeef.timeline.csv || true
	sort -u $(REPORT_PATH)/repo/assessment.all.idx.swap > $(REPORT_PATH)/repo/assessment.all.idx; \

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
	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/repo/assessment.all.deadbeef.csv $(REPORT_PATH)/repo/assessment.$(supplier).exceptions.csv $(REPORT_PATH)/repo/assessment.$(supplier).csv > $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	gmake catalog_repo | $(EGREP) "tests/" | $(EGREP) $(supplier) | sort >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/repo/assessment.all.deadbeef.idx $(REPORT_PATH)/repo/assessment.all.csv.swap > $(REPORT_PATH)/repo/assessment.all.csv || true
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/repo/assessment.all.csv.swap $(REPORT_PATH)/repo/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/repo/assessment.all.deadbeef.csv $(REPORT_PATH)/repo/assessment.all.exception.csv $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	gmake catalog_repo | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.security.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.security.csv > $(REPORT_PATH)/repo/assessment.all.security.timeline.csv || true
	$(EGREP) ';psirt' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.psirt.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.psirt.csv > $(REPORT_PATH)/repo/assessment.all.psirt.timeline.csv || true
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.audit.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.audit.csv > $(REPORT_PATH)/repo/assessment.all.audit.timeline.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.timeline.csv
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.exception.csv > $(REPORT_PATH)/repo/assessment.all.exception.timeline.csv || true
	 $(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.deadbeef.csv > $(REPORT_PATH)/repo/assessment.all.deadbeef.timeline.csv || true
	sort -u $(REPORT_PATH)/repo/assessment.all.idx.swap > $(REPORT_PATH)/repo/assessment.all.idx; \

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
	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/repo/assessment.all.deadbeef.csv $(REPORT_PATH)/repo/assessment.$(supplier).exceptions.csv $(REPORT_PATH)/repo/assessment.$(supplier).csv > $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	gmake catalog_repo | $(EGREP) "tests/" | $(EGREP) $(supplier) | sort >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/repo/assessment.all.deadbeef.idx $(REPORT_PATH)/repo/assessment.all.csv.swap > $(REPORT_PATH)/repo/assessment.all.csv || true
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/repo/assessment.all.csv.swap $(REPORT_PATH)/repo/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/repo/assessment.all.deadbeef.csv $(REPORT_PATH)/repo/assessment.all.exception.csv $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------\n---- tests purposes ----\n------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	gmake catalog_repo | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.security.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.security.csv > $(REPORT_PATH)/repo/assessment.all.security.timeline.csv || true
	$(EGREP) ';psirt' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.psirt.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.psirt.csv > $(REPORT_PATH)/repo/assessment.all.psirt.timeline.csv || true
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.audit.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.audit.csv > $(REPORT_PATH)/repo/assessment.all.audit.timeline.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.csv > $(REPORT_PATH)/repo/assessment.all.timeline.csv
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.exception.csv > $(REPORT_PATH)/repo/assessment.all.exception.timeline.csv || true
	 $(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/repo/assessment.all.idx.swap $(REPORT_PATH)/repo/assessment.all.deadbeef.csv > $(REPORT_PATH)/repo/assessment.all.deadbeef.timeline.csv || true
	sort -u $(REPORT_PATH)/repo/assessment.all.idx.swap > $(REPORT_PATH)/repo/assessment.all.idx; \

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

# --------------------------------

check_run: clean_tmp tests_run check_supplier
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
		\
		$(if $(filter no,$(PSIRT)),\
			$(foreach test,$(shell find $(TESTS_$(scope)_RUN_PATH) -name '*.gawk' -type f  2>/dev/null || true),\
				find $(CONFIGURATION_$(scope)_RUN_PATH) $(FIND_CONF_SELECT) $(TEST_EXE) >> $(REPORT_PATH)/run/assessment.$(scope).csv.swap 2>/dev/null || true ;\
			),\
			touch $(REPORT_PATH)/run/assessment.$(scope).csv.swap ;\
		) \
		$(foreach test,$(shell find $(TESTS_$(scope)_RUN_PSIRT_PATH) -name '*.gawk' -type f 2>/dev/null || true),\
			find $(CONFIGURATION_$(scope)_RUN_PATH) $(FIND_CONF_SELECT) $(TEST_EXE) >> $(REPORT_PATH)/run/assessment.$(scope).csv.swap 2>/dev/null || true ;\
		) \
		\
		$(EGREP) -v -f $(EXCEPTION_PATH)/run/exceptions.$(scope) $(REPORT_PATH)/run/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/run/assessment.$(scope).csv || true ;\
		cat $(REPORT_PATH)/run/assessment.$(scope).csv >> $(REPORT_PATH)/run/assessment.all.csv.swap ;\
		$(EGREP) -f $(EXCEPTION_PATH)/run/exceptions.$(scope) $(REPORT_PATH)/run/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv || true ;\
		cat $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv >> $(REPORT_PATH)/run/assessment.all.exception.csv ;\
		$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run/assessment.all.deadbeef.csv $(REPORT_PATH)/run/assessment.$(scope).csv > $(REPORT_PATH)/run/assessment.$(scope).summary.txt ;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		gmake catalog_run | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
	)

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/run/assessment.all.deadbeef.idx $(REPORT_PATH)/run/assessment.all.csv.swap > $(REPORT_PATH)/run/assessment.all.csv || true
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/run/assessment.all.csv.swap $(REPORT_PATH)/run/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run/assessment.all.deadbeef.csv $(REPORT_PATH)/run/assessment.all.exception.csv $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	gmake catalog_repo | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.security.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.security.csv > $(REPORT_PATH)/run/assessment.all.security.timeline.csv || true
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.audit.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.audit.csv > $(REPORT_PATH)/run/assessment.all.audit.timeline.csv || true
	$(EGREP) ';psirt' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.psirt.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.psirt.csv > $(REPORT_PATH)/run/assessment.all.psirt.timeline.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.timeline.csv
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.exception.csv > $(REPORT_PATH)/run/assessment.all.exception.timeline.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.deadbeef.csv > $(REPORT_PATH)/run/assessment.all.deadbeef.timeline.csv || true
	sort -u $(REPORT_PATH)/run/assessment.all.idx.swap > $(REPORT_PATH)/run/assessment.all.idx; \

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
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	$(ECHO) "cawk error audit=${audit} do not exist  ----"
	exit 0
endif
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
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
		else \
			$(ECHO) "cawk compute run_${audit} $(scope) devices ----" ;\
			\
			$(if $(filter no,$(PSIRT)),\
				$(foreach test,$(shell find $(TESTS_$(scope)_RUN_PATH) -name '*.gawk' -type f  2>/dev/null || true),\
					find $(CONFIGURATION_$(scope)_RUN_PATH) $(FIND_CONF_SELECT) $(TEST_EXE) >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap 2>/dev/null || true ;\
				),\
				touch $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap;\
			) \
			$(foreach test,$(shell find $(TESTS_$(scope)_RUN_PSIRT_PATH) -name '*.gawk' -type f 2>/dev/null || true),\
				find $(CONFIGURATION_$(scope)_RUN_PATH) $(FIND_CONF_SELECT) $(TEST_EXE) >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap 2>/dev/null || true ;\
			) \
			\
			$(EGREP) -v -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(scope) $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv || true ;\
			cat $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv >> $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap ;\
			$(EGREP) -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(scope) $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv || true ;\
			cat $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv >> $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv ;\
			$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv > $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt ;\
			$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			gmake catalog_run audit=$(audit) | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
		fi; \
	)

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.idx $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap > $(REPORT_PATH)/run_${audit}/assessment.all.csv || true
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap $(REPORT_PATH)/run_${audit}/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	gmake catalog_run audit=$(audit) | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.security.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.security.csv > $(REPORT_PATH)/run_${audit}/assessment.all.security.timeline.csv || true
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.audit.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.audit.csv > $(REPORT_PATH)/run_${audit}/assessment.all.audit.timeline.csv || true
	$(EGREP) ';psirt' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.psirt.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.psirt.csv > $(REPORT_PATH)/run_${audit}/assessment.all.psirt.timeline.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.timeline.csv
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv > $(REPORT_PATH)/run_${audit}/assessment.all.exception.timeline.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv > $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.timeline.csv || true
	sort -u $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap > $(REPORT_PATH)/run_${audit}/assessment.all.idx

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
		find $(TESTS_$(scope)_RUN_PSIRT_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.run.psirt.$(scope) 2>/dev/null || true ;\
		$(TESTS_COMMON_PATH)/gen_cawk_makefile.psirt.gawk $(TESTS_TMP)/conf_list_files.run.$(scope) $(MAKE_FILES_PER_TARGET_PSIRT) $(TESTS_TMP)/conf_list_tests.run.psirt.$(scope) > $(TESTS_TMP)/Makefile.run.psirt.$(scope) 2>/dev/null || true ;\
		gmake -f $(TESTS_TMP)/Makefile.run.psirt.$(scope) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all >> $(REPORT_PATH)/run/assessment.$(scope).csv.swap 2>/dev/null || true ;\
		$(EGREP) -v -f $(EXCEPTION_PATH)/run/exceptions.$(scope) $(REPORT_PATH)/run/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/run/assessment.$(scope).csv || true ;\
		cat $(REPORT_PATH)/run/assessment.$(scope).csv >> $(REPORT_PATH)/run/assessment.all.csv.swap ;\
		$(EGREP) -f $(EXCEPTION_PATH)/run/exceptions.$(scope) $(REPORT_PATH)/run/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv || true ;\
		cat $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv >> $(REPORT_PATH)/run/assessment.all.exception.csv ;\
		$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run/assessment.all.deadbeef.csv $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv $(REPORT_PATH)/run/assessment.$(scope).csv > $(REPORT_PATH)/run/assessment.$(scope).summary.txt ;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		gmake catalog_run | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
	)

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/run/assessment.all.deadbeef.idx $(REPORT_PATH)/run/assessment.all.csv.swap > $(REPORT_PATH)/run/assessment.all.csv || true
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/run/assessment.all.csv.swap $(REPORT_PATH)/run/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run/assessment.all.deadbeef.csv $(REPORT_PATH)/run/assessment.all.exception.csv $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.summary.txt
	${TESTS_COMMON_PATH}/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.timeline.csv || true
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	gmake catalog_repo | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.security.csv || true
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.audit.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.audit.csv > $(REPORT_PATH)/run/assessment.all.audit.timeline.csv || true
	$(EGREP) ';psirt' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.psirt.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.psirt.csv > $(REPORT_PATH)/run/assessment.all.psirt.timeline.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.security.csv > $(REPORT_PATH)/run/assessment.all.security.timeline.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.exception.csv > $(REPORT_PATH)/run/assessment.all.exception.timeline.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.deadbeef.csv > $(REPORT_PATH)/run/assessment.all.deadbeef.timeline.csv || true
	sort -u $(REPORT_PATH)/run/assessment.all.idx.swap > $(REPORT_PATH)/run/assessment.all.idx

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
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
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
			$(if $(filter no,$(PSIRT)),\
				find $(TESTS_$(scope)_RUN_PATH) -type f -name '*.gawk'  > $(TESTS_TMP)/conf_list_tests.${audit}.$(scope) 2>/dev/null || true ;\
				$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk $(TESTS_TMP)/conf_list_files.${audit}.$(scope) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.${audit}.$(scope) > $(TESTS_TMP)/Makefile.${audit}.$(scope) 2>/dev/null || true ;\
				gmake -f $(TESTS_TMP)/Makefile.${audit}.$(scope) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap 2>/dev/null || true ;\
				, \
				touch $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap ;\
			) \
			find $(TESTS_$(scope)_RUN_PSIRT_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.${audit}.psirt.$(scope) 2>/dev/null || true ;\
			$(TESTS_COMMON_PATH)/gen_cawk_makefile.psirt.gawk $(TESTS_TMP)/conf_list_files.${audit}.$(scope) $(MAKE_FILES_PER_TARGET_PSIRT) $(TESTS_TMP)/conf_list_tests.${audit}.psirt.$(scope) > $(TESTS_TMP)/Makefile.${audit}.psirt.$(scope) 2>/dev/null || true ;\
			gmake -f $(TESTS_TMP)/Makefile.${audit}.psirt.$(scope) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap 2>/dev/null || true;\
			$(EGREP) -v -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(scope) $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv || true ;\
			cat $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv >> $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap ;\
			$(EGREP) -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(scope) $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap | sort -u > $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv || true ;\
			cat $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv >> $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv ;\
			$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv > $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt ;\
			$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			gmake catalog_run audit=$(audit) | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
		fi; \
	)

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.idx $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap > $(REPORT_PATH)/run_${audit}/assessment.all.csv || true
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap $(REPORT_PATH)/run_${audit}/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	gmake catalog_run audit=$(audit) | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.security.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.security.csv > $(REPORT_PATH)/run_${audit}/assessment.all.security.timeline.csv || true
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.audit.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.audit.csv > $(REPORT_PATH)/run_${audit}/assessment.all.audit.timeline.csv || true
	$(EGREP) ';psirt' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.psirt.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.psirt.csv > $(REPORT_PATH)/run_${audit}/assessment.all.psirt.timeline.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.timeline.csv
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv > $(REPORT_PATH)/run_${audit}/assessment.all.exception.timeline.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv > $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.timeline.csv || true
	sort -u $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap > $(REPORT_PATH)/run_${audit}/assessment.all.idx

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
	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run/assessment.all.deadbeef.csv $(REPORT_PATH)/run/assessment.$(supplier).exceptions.csv $(REPORT_PATH)/run/assessment.$(supplier).csv > $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	make catalog_run | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/run/assessment.all.deadbeef.idx $(REPORT_PATH)/run/assessment.all.csv.swap > $(REPORT_PATH)/run/assessment.all.csv || true
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/run/assessment.all.csv.swap $(REPORT_PATH)/run/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run/assessment.all.deadbeef.csv $(REPORT_PATH)/run/assessment.all.exception.csv $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	gmake catalog_repo | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.security.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.security.csv > $(REPORT_PATH)/run/assessment.all.security.timeline.csv || true
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.audit.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.audit.csv > $(REPORT_PATH)/run/assessment.all.audit.timeline.csv || true
	$(EGREP) ';psirt' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.psirt.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.psirt.csv > $(REPORT_PATH)/run/assessment.all.psirt.timeline.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.timeline.csv
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.exception.csv > $(REPORT_PATH)/run/assessment.all.exception.timeline.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.deadbeef.csv > $(REPORT_PATH)/run/assessment.all.deadbeef.timeline.csv || true
	sort -u $(REPORT_PATH)/run/assessment.all.idx.swap > $(REPORT_PATH)/run/assessment.all.idx

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
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
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
		$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.$(supplier).exceptions.csv $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		gmake catalog_run audit=$(audit) | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
	fi

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.idx $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap > $(REPORT_PATH)/run_${audit}/assessment.all.csv || true
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap $(REPORT_PATH)/run_${audit}/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	gmake catalog_run audit=$(audit) | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.security.csv || true;\
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.security.csv > $(REPORT_PATH)/run_${audit}/assessment.all.security.timeline.csv || true;\
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.audit.csv || true;\
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.audit.csv > $(REPORT_PATH)/run_${audit}/assessment.all.audit.timeline.csv || true;\
	$(EGREP) ';psirt' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.psirt.csv || true;\
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.psirt.csv > $(REPORT_PATH)/run_${audit}/assessment.all.psirt.timeline.csv || true;\
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.timeline.csv ;\
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv > $(REPORT_PATH)/run_${audit}/assessment.all.exception.timeline.csv || true ;\
	sort -u $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap > $(REPORT_PATH)/run_${audit}/assessment.all.idx ;\

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
	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run/assessment.all.deadbeef.csv $(REPORT_PATH)/run/assessment.$(supplier).exceptions.csv $(REPORT_PATH)/run/assessment.$(supplier).csv > $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	make catalog_run | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/run/assessment.all.deadbeef.idx $(REPORT_PATH)/run/assessment.all.csv.swap > $(REPORT_PATH)/run/assessment.all.csv || true
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/run/assessment.all.csv.swap $(REPORT_PATH)/run/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run/assessment.all.deadbeef.csv $(REPORT_PATH)/run/assessment.all.exception.csv $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run/assessment.all.summary.txt
	gmake catalog_repo | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/run/assessment.all.summary.txt
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.security.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.security.csv > $(REPORT_PATH)/run/assessment.all.security.timeline.csv || true
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.audit.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.audit.csv > $(REPORT_PATH)/run/assessment.all.audit.timeline.csv || true
	$(EGREP) ';psirt' $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.psirt.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.psirt.csv > $(REPORT_PATH)/run/assessment.all.psirt.timeline.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.csv > $(REPORT_PATH)/run/assessment.all.timeline.csv
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.exception.csv > $(REPORT_PATH)/run/assessment.all.exception.timeline.csv || true
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run/assessment.all.idx.swap $(REPORT_PATH)/run/assessment.all.deadbeef.csv > $(REPORT_PATH)/run/assessment.all.deadbeef.timeline.csv || true
	sort -u $(REPORT_PATH)/run/assessment.all.idx.swap > $(REPORT_PATH)/run/assessment.all.idx

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
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
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
		$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.$(supplier).exceptions.csv $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt; \
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		gmake catalog_run audit=$(audit) | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
	fi 

ifeq ($(strip $(DEADBEEF)),yes)
	$(ECHO) "cawk deadbeef filter performed ----"
	$(EGREP) -v -f $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.idx $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap > $(REPORT_PATH)/run_${audit}/assessment.all.csv || true
else
	$(ECHO) "cawk deadbeef filter skipped ----"
	mv $(REPORT_PATH)/run_${audit}/assessment.all.csv.swap $(REPORT_PATH)/run_${audit}/assessment.all.csv || true
endif

	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	$(ECHO) "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	gmake catalog_run audit=$(audit) | $(EGREP) "tests/" | sort >> $(REPORT_PATH)/run_${audit}/assessment.all.summary.txt;\
	$(EGREP) '(high|medium|low);error' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.security.csv || true;\
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.security.csv > $(REPORT_PATH)/run_${audit}/assessment.all.security.timeline.csv || true;\
	$(EGREP) '(info;error|;warning)' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.audit.csv || true;\
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.audit.csv > $(REPORT_PATH)/run_${audit}/assessment.all.audit.timeline.csv || true;\
	$(EGREP) ';psirt' $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.psirt.csv || true;\
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.psirt.csv > $(REPORT_PATH)/run_${audit}/assessment.all.psirt.timeline.csv || true;\
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.csv > $(REPORT_PATH)/run_${audit}/assessment.all.timeline.csv ;\
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.exception.csv > $(REPORT_PATH)/run_${audit}/assessment.all.exception.timeline.csv || true ;\
	$(TESTS_COMMON_PATH)/reporttimeline.gawk $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.csv > $(REPORT_PATH)/run_${audit}/assessment.all.deadbeef.timeline.csv || true ;\
	sort -u $(REPORT_PATH)/run_${audit}/assessment.all.idx.swap > $(REPORT_PATH)/run_${audit}/assessment.all.idx ;\

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
	$(ECHO) "cawk check_run_audit end ----"

# --------------------------------

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
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
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

# --------------------------------

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

# --------------------------------

clean: clean_tmp
	rm -f $(TESTS_COMMON_PATH)/*.gawk || true
	rm -f $(TESTS_COMMON_PATH)/*.script || true
	rm -f $(DATABASE_PATH_SH)/*.script || true
	$(foreach scope,$(SUPPLIER_SCOPE),\
		rm -f $(EXCEPTION_PATH)/*/*.$(scope) || true ;\
	)
	rm -f $(TESTS_PATH)/repo/*/*.gawk || true
	rm -f $(TESTS_PATH)/repo/*/*.swap || true
	rm -f $(TESTS_PATH)/run/*/*.gawk || true
	rm -f $(TESTS_PATH)/run_*/*/*.gawk || true
	rm -f $(TESTS_PATH)/run_*/*/*.swap || true
	rm -f *.tar *.tar.gz || true
	find $(TESTS_COMMON_PATH) $(DATABASE_PATH_SH) $(EXCEPTION_PATH) $(TESTS_PATH)/repo $(TESTS_PATH)/run -type f -exec touch {} \; || true
	if [ -d "$(TESTS_PATH)/run_*" ]; then find $(TESTS_PATH)/run_* -type f -exec touch {} \; || true; fi
	$(ECHO) "cawk clean done ----"

clean_backup:
	rm -f $(BACKUP_PATH)/*.tar $(BACKUP_PATH)/*.tar.gz 2>/dev/null || true
	$(ECHO) "cawk clean $(BACKUP_PATH) done ----"

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
	rm -f $(TESTS_TMP)/tmp* || true
	rm -f $(TESTS_TMP)/conf_* || true
	rm -f $(TESTS_TMP)/Makefile* || true
	$(ECHO) "cawk clean tmp done ----"

clean_force:
	@if [ "$(FORCE)" != "yes" ]; then \
		$(ECHO) "Error: FORCE=yes must be set to run clean_force."; \
		exit 1; \
	fi
	@$(ECHO) "FORCE='$(FORCE)'. Proceeding with clean_force..."
	gmake clean clean_report_repo clean_backup clean_report_run clean_report_run_audit clean_archive_repo clean_archive_run clean_archive_run_audit
	@$(ECHO) "cawk clean_force done ----"

clean_archive_older:
	find reports -type f -name '*.tar.gz' -mtime +$(ARCHIVE_OLDER_DAYS) -exec rm -f {} \; 2>/dev/null || true

# --------------------------------

catalog_repo:
	$(foreach dir,$(wildcard tests/repo),\
		$(ECHO) "------------------------------";\
		$(ECHO) "---- Tests <repo> catalog ----";\
		$(ECHO) "------------------------------";\
		for file in $(wildcard $(dir)/*/*.m4) $(wildcard $(dir)/*/*.template); do \
			$(EGREP) -H purpose $$file | sed -e 's/# purpose ://g' -e 's/tests\/tests\.//g' || true;\
		done;\
	)
	$(ECHO) "cawk catalog_repo done ----"

catalog_run:
ifeq ($(strip $(audit)),)
	$(foreach dir,$(wildcard tests/run),\
		$(ECHO) "-----------------------------";\
		$(ECHO) "---- Tests <run> catalog ----";\
		$(ECHO) "-----------------------------";\
		for file in $(wildcard $(dir)/*/*.m4) $(wildcard $(dir)/*/*.template); do \
			$(EGREP) -H purpose $$file | sed -e 's/# purpose ://g' -e 's/tests\/tests\.//g' || true;\
		done;\
	)
	$(ECHO) "cawk catalog_run done ----"
else
	$(foreach dir,$(wildcard tests/run_$(audit)),\
		$(ECHO) "--------------------------------------------";\
		$(ECHO) "---- Tests <run_$(audit)> catalog ----";\
		$(ECHO) "--------------------------------------------";\
		for file in $(wildcard $(dir)/*/*.m4) $(wildcard $(dir)/*/*.template); do \
			$(EGREP) -H purpose $$file | sed -e 's/# purpose ://g' -e 's/tests\/tests\.//g' || true;\
		done;\
	)
	$(ECHO) "cawk catalog_run $(audit) done ----"
endif

# --------------------------------

gitcheckdist:
	gmake clean clean_force FORCE=yes
	rm $(DATABASE_PATH)/db_email.txt
	rm $(DATABASE_PATH)/db_postaudit.txt
	rm $(DATABASE_PATH)/db_sync.txt
	touch $(DATABASE_PATH)/db_email.txt 
	touch $(DATABASE_PATH)/db_postaudit.txt
	touch $(DATABASE_PATH)/db_sync.txt
	rm -f -r $(DATABASE_REPO_PATH) || true
	cp -r $(DATABASE_PATH) $(DATABASE_REPO_PATH)
	$(ECHO) "============================================== : end check databases"
	find tests/ -type f ! -name "*gawk*" | awk '{print "\033[31m" $$0 "\033[0m"}'
	$(ECHO) "============================================== : check filename without gawk code"
	gmake tests_check_nok
	gmake clean clean_force FORCE=yes
	$(ECHO) "============================================== : end check filename versus print_err code"
	chmod 750 system/cawk_check_system
	@$(ECHO) "\033[31m" ; gmake system ; $(ECHO) "\033[0m"
	$(ECHO) "=============================================== : end call system check"
	gmake supplier | awk '{print "\033[31m" $$0 "\033[0m"}'
	$(ECHO) "============================================== : end supplier list"
	gmake list_audit | awk '{print "\033[31m" $$0 "\033[0m"}'
	$(ECHO) "============================================== : end audit list"
	find . -name *.gawk | awk '{print "\033[31m" $$0 "\033[0m"}'
	$(ECHO) "============================================== : end no *.gawk must be there"
	find . -name .DS_Store | xargs rm -f
	$(ECHO) "============================================== : end clean DS store file"
	find . -name .DS_Store | xargs rm -f
	rm -r -f .vscode
	$(ECHO) "============================================== : end clean vscode param"
	find . -name *.orig | xargs rm -f
	$(ECHO) "============================================== : end clean orig file"
	rm -r confs/run && cp -r confs/repo confs/run
	rm -r tests/run && cp -r tests/repo tests/run
	rm -r exceptions/run && cp -r exceptions/repo exceptions/run
	$(ECHO) "============================================== : end update run repository confs && tests && exceptions from repo"
	touch reports/repo/.gitkeep && touch reports/run/.gitkeep && touch tmp/.gitkeep
	touch reports/repo/archives/.gitkeep && touch reports/run/archives/.gitkeep
	$(ECHO) "============================================== : end touch .gitkeep in reports and tmp"	
	find . -name .gitkeep | awk '{print "\033[31m" $$0 "\033[0m"}'
	$(ECHO) "==============================================  : end check .gitkeep in directories"
	$(ECHO) "Update checkdiff"
	$(ECHO) "gmake check_update && gmake check"
	$(ECHO) "==============================================  : end update checkdiff"
	$(ECHO) "============================================== : end update Makefile.support.mk with CAWK_RELEASE = $(CAWK_RELEASE)"

git:
	# gmake gitcheckdist
	# find confs -type f -exec touch {} \;
	# git add .
	# git commit -m "*$(CAWK_RELEASE) ref ChangeLog"

gitpush:
	# git push https://github.com/cedricllorens/cawk.git master

# --------------------------------

check:
	gmake clean clean_force FORCE=yes
	find confs -type f -exec touch {} \;
	rm -f  checkdiff/checkdiff.new
	
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

	$(ECHO) "------------------------------------------------------"
	$(ECHO) "------------------------------------------------------"
	$(ECHO) "CHECK MUST BE OK -------------------------------------"
	$(ECHO) "------------------------------------------------------"
	diff checkdiff/checkdiff.new checkdiff/checkdiff.old >/dev/null && $(ECHO) OK || $(ECHO) NOK
	$(ECHO) "------------------------------------------------------"
	$(ECHO) "CHECK MUST BE OK -------------------------------------"
	$(ECHO) "------------------------------------------------------"
	$(ECHO) "------------------------------------------------------"
	$(ECHO) "cawk check done ----"

check_parallel:
	gmake check MAKE_PARALLEL=yes

check_update:
	cp -v checkdiff/checkdiff.new checkdiff/checkdiff.old
	$(ECHO) "cawk check_update done ----"

