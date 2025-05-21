# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2025 by Cedric Llorens
# ------------------------------------------------------------

# ---------------

include Makefile.support.mk

# ---------------

CONFS_PATH = confs
COMMON_PATH = common
BACKUP_PATH = backup
DATABASE_PATH = database
LOGS_PATH = logs
DATABASE_PATH_SH = $(DATABASE_PATH)/scripts
DATABASE_SH = $(wildcard $(DATABASE_PATH_SH)/*.script.sh)
REPORT_PATH = reports

TESTS_COMMON_PATH = common
TESTS_PATH = tests
TESTS_COMMON_TEMPLATE = $(wildcard $(TESTS_COMMON_PATH)/*.template)
TESTS_COMMON_SH = $(wildcard $(TESTS_COMMON_PATH)/*.script.sh)
TESTS_SYSTEM = system
TESTS_TMP = tmp

EXCEPTION_PATH = exceptions
EXCEPTION_M4 = $(wildcard $(EXCEPTION_PATH)/repo/*.m4) $(wildcard $(EXCEPTION_PATH)/run*/*.m4)

# ---------------

# Define all suppliers/platforms
SUPPLIER_SCOPE = cisco-ios cisco-xr juniper-junos huawei-vrp fortinet-fortios nokia-sros paloalto-panos cisco-viptela cisco-cedge cisco-xe packetfilter-fwcli checkpoint-fwcli iptables-fwcli 6wind-linux

# Generic template for all suppliers
define supplier_template
CONFIGURATION_$(1)_REPO_PATH = $$(CONFS_PATH)/repo/confs.$(1)
ifeq ($$(strip $$(audit)),)
	CONFIGURATION_$(1)_RUN_PATH = $$(CONFS_PATH)/run/confs.$(1)
else
	CONFIGURATION_$(1)_RUN_PATH = $$(CONFS_PATH)/run_$${audit}/confs.$(1)
endif

TESTS_$(1)_REPO_PATH = $$(TESTS_PATH)/repo/tests.$(1)
ifeq ($$(strip $$(audit)),)
	TESTS_$(1)_RUN_PATH = $$(TESTS_PATH)/run/tests.$(1)
else
	TESTS_$(1)_RUN_PATH = $$(TESTS_PATH)/run_$${audit}/tests.$(1)
endif

TESTS_$(1)_REPO_TEMPLATE = $$(wildcard $$(TESTS_$(1)_REPO_PATH)/*.template)
TESTS_$(1)_REPO_M4 = $$(wildcard $$(TESTS_$(1)_REPO_PATH)/*.m4)
TESTS_$(1)_RUN_TEMPLATE = $$(wildcard $$(TESTS_$(1)_RUN_PATH)/*.template)
TESTS_$(1)_RUN_M4 = $$(wildcard $$(TESTS_$(1)_RUN_PATH)/*.m4)
endef

# Generate rules for all suppliers
$(foreach supplier,$(SUPPLIER_SCOPE),$(eval $(call supplier_template,$(supplier))))

# --------------- GNU MAKE TARGETS

.PHONY: all check_repo check_run check_run_audit tests tests_target view_repo view_run view_repo_error view_run_error clean_force clean_report clean_backup clean_tmp clean clean clean_report_repo clean_report_run clean_report_run_audit clean_archive_repo clean_archive_run clean_archive_run_audit catalog_repo catalog_run git gitpush gitcheckdist supplier check_supplier system common create_audit delete_audit list_audit archive_run archive_repo check_parallel check_update check sync_run sync_run_audit backup_run backup_run_audit restore_run restore_run_audit database_view database_sync_add database_sync_update database_sync_del database_email_add database_email_update database_email_del email_send email_send_audit database_target_sh tests_run_copy tests_run_audit_copy database_postaudit_add database_postaudit_del migrate

# --------------------------------

all:
	echo "# ---------------------------------------------------------------------------------------------------------------"
	echo "# -- CAWK INFO --------------------------------------------------------------------------------------------------"
	echo "# ---------------------------------------------------------------------------------------------------------------"
	echo "# note : %SED_GAWK_PATH% point out the gawk path, we set <!/usr/bin/env -S gawk -f> (ref support/tests.sed)"
	echo "# note : Makefile.support.mk contains variables that can change the cawk behavior"
	echo "# note : you can have several targets for a same gmake call like -> gmake clean check_repo view_repo"
	echo "# note : <repo> is the original cawk repository of coded tests, test's confs and exceptions"
	echo "# note : <run> is an empty repository used for your own tests/checks"
	echo "# note : <run_AUDIT_NAME> are repositories for all of your contexts or for your customers"
	echo "# note : please refer to the README file for further information"
	echo "# ---------------------------------------------------------------------------------------------------------------"
	echo "# -- CAWK MAIN --------------------------------------------------------------------------------------------------"
	echo "# ---------------------------------------------------------------------------------------------------------------"
	echo "# gmake : provide information on cawk running"
	echo "# gmake check : allow to run a cawk compliance check (result must be OK only after the first installation)"
	echo "# gmake system : allow to know if the system can run cawk"
	echo "# gmake supplier : provide the suppliers supported by cawk"
	echo "# gmake common : provide the list of functions available in the common dir"
	echo "# gmake clean : clean tests && tmp repository"
	echo "# gmake clean_report_repo / clean_report_run / clean_report_run audit=AUDIT_NAME : clean reports"
	echo "# gmake clean_archive_repo / clean_archive_run / clean_archive_run audit=AUDIT_NAME : clean archives"
	echo "# gmake clean_backup : clean all backups"
	echo "# gmake clean_force : (USE WITH CAUTION) clean all including reports, backups, archives for all assessments"
	echo "# ---------------------------------------------------------------------------------------------------------------"
	echo "# -- CAWK TESTS -------------------------------------------------------------------------------------------------"
	echo "# ---------------------------------------------------------------------------------------------------------------"
	echo "# gmake tests_common : build tests associated to common dir"
	echo "# gmake tests_repo : build tests associated to repo dir"
	echo "# gmake tests_run : build tests associated to run dir"
	echo "# gmake tests_run audit=AUDIT_NAME : build tests associated to run_audit dir"
	echo "# gmake tests_run_audit : build tests associated to all audit=AUDIT_NAME run_audit dirs"
	echo "# CAUTION : for update or migration purpose, it will replace all the same repo tests in the run_audit dir"
	echo "# CAUTION : user specific tests will remaint in the run_audit dir"	
	echo "# NOTE    : only available for audit=AUDIT_NAME assessments"
	echo "# gmake tests_run_copy audit=AUDIT_NAME : copy tests from repo to audit=AUDIT_NAME (ref run_audit)"
	echo "# gmake tests_run_audit_copy : copy tests from repo to all audit=AUDIT_NAMEs (ref all run_audit)"
	echo "# ---------------------------------------------------------------------------------------------------------------"
	echo "# -- CAWK ASSESSMENT --------------------------------------------------------------------------------------------"
	echo "# ---------------------------------------------------------------------------------------------------------------"
	echo "# gmake create_audit audit=AUDIT_NAME : create AUDIT_NAME tests, exceptions, confs directories (ref run_audit)"
	echo "# gmake delete_audit audit=AUDIT_NAME : delete AUDIT_NAME tests, exceptions, confs directories (ref run_audit)"
	echo "# gmake list_audit : list all the AUDIT_NAMEs (audit=AUDIT_NAME)"
	echo "# gmake run_audit : run assessments for all the AUDIT_NAMEs (audit=AUDIT_NAME)"
	echo "# ---------------------------------------------------------------------------------------------------------------"
	echo "# -- CAWK CHECK -------------------------------------------------------------------------------------------------"
	echo "# ---------------------------------------------------------------------------------------------------------------"
	echo "# gmake check_repo : assess the confs with <repo> tests (build tests if not)"
	echo "#  or gmake check_repo (run all suppliers)"
	echo "#  or gmake check_repo supplier=cisco-ios (or view_juniper-junos, etc.)"
	echo "# gmake check_run : assess the confs with <run> tests (build tests if not)"
	echo "#  or gmake check_run (run all suppliers)"
	echo "#  or gmake check_run supplier=cisco-ios (or view_juniper-junos, etc.)"
	echo "#  or gmake check_run audit=AUDIT_NAME (run all suppliers)"
	echo "#  or gmake check_run supplier=cisco-ios audit=AUDIT_NAME (or view_juniper-junos, etc.)"
	echo "# gmake check_run_audit : run assessments for all the audit=AUDIT_NAMEs"
	echo "# ---------------------------------------------------------------------------------------------------------------"
	echo "# -- CAWK VIEW --------------------------------------------------------------------------------------------------"
	echo "# ---------------------------------------------------------------------------------------------------------------"
	echo "# gmake view_repo : view the repo reports (all in report/repo dir)"
	echo "#  or gmake view_repo supplier=cisco-ios (or juniper-junos, etc.)"
	echo "# gmake view_repo_error : view the repo assessment reports errors (all in report/repo dir)"
	echo "#  or gmake view_repo_error supplier=cisco-ios (or juniper-junos, etc.)"
	echo "# gmake view_run : view the run reports (all in report/run or run_audit dirs)"
	echo "#  or gmake view_run supplier=cisco-ios (or juniper-junos, etc.)"
	echo "#  or gmake view_run supplier=cisco-ios audit=AUDIT_NAME (or juniper-junos, etc.)"
	echo "# gmake view_run_error : view the run assessment reports errors (all in report/run or run_audit dirs)"
	echo "#  or gmake view_run_error audit=AUDIT_NAME (all in report/repo dir)"
	echo "#  or gmake view_run_error supplier=cisco-ios audit=AUDIT_NAME (or juniper-junos, etc.)"
	echo "# ---------------------------------------------------------------------------------------------------------------"
	echo "# -- CAWK DATABASE ----------------------------------------------------------------------------------------------"
	echo "# ---------------------------------------------------------------------------------------------------------------"
	echo "# NOTE : only available for audit=AUDIT_NAME assessments"
	echo "# gmake database_view : view all the databases linked to audit=AUDIT_NAME assessments"
	echo "# ---- sync ----"
	echo "# gmake database_sync_(add,update) audit=AUDIT_NAME dir=SYNC_PATH regex=REGEX_PATTERN/.* scope=SCOPE_FILE/none"
	echo "#  add/update an entry in the cawk sync database, where fields are separated by spaces :"
	echo "#   - 1 field is the audit name"
	echo "#   - 2 field is the various sync paths separated by comma (no space) like /conf/ or /conf/cawk/,/conf/cawk_2/"
	echo "#   - 3 field is an extended regex to select devices pattern matching like .* or .*switch.*"
	echo "#   - 4 field is a file containing a list of devices matching a device scope based on internal inventory"
	echo "# gmake database_sync_del audit=AUDIT_NAME : delete an entry in the cawk sync database"
	echo "# ---- email ----"
	echo "# gmake database_email_(add,update) audit=AUDIT_NAME dst=EMAIL_LIST cc=EMAIL_LIST/none"
	echo "#  add/update an entry in the cawk email database, where fields are separated by spaces :"
	echo "#   - 1 field is the audit name"
	echo "#   - 2 field is the dst list of emails separated by comma (no space) like email1,email2,email3"
	echo "#   - 3 field is the cc list of emails separated by comma (no space) like email1,email2,email3 or none"
	echo "# gmake database_email_del audit=AUDIT_NAME : delete an entry in the cawk email database"
	echo "# ---- post audit ----"
	echo "# gmake database_postaudit_(add/del/update) audit=AUDIT_NAME"
	echo "#  add/delete an entry in the cawk post audit database, where fields are separated by spaces :"
	echo "#   - 1 field is the audit name"
	echo "# ---------------------------------------------------------------------------------------------------------------"
	echo "# -- CAWK SYNC --------------------------------------------------------------------------------------------------"
	echo "# ---------------------------------------------------------------------------------------------------------------"
	echo "# NOTE    : only available for audit=AUDIT_NAME assessment"
	echo "# NOTE    : it relies on the cawk sync database (i.e.README)"
	echo "# CAUTION : local confs files are removed during sync (confs/run_audit dir) (i.e.README)"
	echo "# gmake sync_run audit=AUDIT_NAME : sync confs from a central repository to confs/run_audit dir"
	echo "# gmake sync_run_audit : sync confs from a central repository to all run_audit dirs"
	echo "# ---------------------------------------------------------------------------------------------------------------"
	echo "# -- CAWK EMAIL -------------------------------------------------------------------------------------------------"
	echo "# ---------------------------------------------------------------------------------------------------------------"
	echo "# NOTE : only available for audit=AUDIT_NAME assessment"
	echo "# gmake email_send audit=AUDIT_NAME : send an email to the audit list of emails"
	echo "# gmake email_send_audit : send an email to all audits list of emails"
	echo "# ---------------------------------------------------------------------------------------------------------------"
	echo "# -- CAWK BACKUP AND RESTORE ------------------------------------------------------------------------------------"
	echo "# ---------------------------------------------------------------------------------------------------------------"
	echo "# NOTE : only available for audit=AUDIT_NAME assessment"
	echo "# gmake backup_run audit=AUDIT_NAME : backup all data linked to audit=AUDIT_NAME in backup dir"
	echo "# gmake restore_run audit=AUDIT_NAME file=BACKUP_PATH_FILE : restore all data from file_path"
	echo "# gmake backup_run_audit : backup cawk database and all data linked to all audit=AUDIT_NAMEs in backup dir"
	echo "# gmake restore_run_audit file=BACKUP_PATH_FILE : restore database and all data from file_path"
	echo "# gmake migrate file=BACKUP_PATH_FILE : run several targets to migrate to a new cakw version (i.e.README)"
	echo "# ---------------------------------------------------------------------------------------------------------------"
	echo "# -- CAWK CATALOG -----------------------------------------------------------------------------------------------"
	echo "# ---------------------------------------------------------------------------------------------------------------"
	echo "# gmake catalog_repo : build the tests description catalog for repo"
	echo "# gmake catalog_run : build the tests description catalog for run"
	echo "# gmake catalog_run audit=AUDIT_NAME: build the tests description catalog for audit=AUDIT_NAME"
	echo "# ---------------------------------------------------------------------------------------------------------------"

# --------------------------------

create_audit:
ifeq ($(strip $(audit)),)
	echo "cawk error audit=AUDIT_NAME must be set ----"
else
ifneq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	echo "cawk error audit=${audit} already exist ----"
else
	cp -r $(TESTS_PATH)/repo $(TESTS_PATH)/run_${audit}
	cp -r $(EXCEPTION_PATH)/repo exceptions/run_${audit}
	cp -r $(CONFS_PATH)/repo $(CONFS_PATH)/run_${audit} 
	mkdir $(REPORT_PATH)/run_${audit}
	mkdir $(REPORT_PATH)/run_${audit}/archives
	mkdir $(LOGS_PATH)/run_${audit}
	gmake database_postaudit_add audit=${audit}
	gmake database_email_add audit=${audit} dst=none cc=none
	gmake database_sync_add audit=${audit} dir=none regex=.* scope=none
endif
endif
	echo "cawk create_audit end ----"

delete_audit:
ifeq ($(strip $(audit)),)
	echo "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	echo "cawk error audit=${audit} do not exist  ----"
else
	rm -f -r $(TESTS_PATH)/run_${audit}
	rm -f -r $(CONFS_PATH)/run_${audit}
	rm -f -r $(EXCEPTION_PATH)/run_${audit}
	rm -f -r $(REPORT_PATH)/run_${audit}
	rm -f -r $(LOGS_PATH)/run_${audit}
	grep "^${audit}" $(DATABASE_PATH)/db_sync.txt > /dev/null && sed -i "/^${audit}/d" $(DATABASE_PATH)/db_sync.txt || true
	grep "^${audit}" $(DATABASE_PATH)/db_postaudit.txt > /dev/null && sed -i "/^${audit}/d" $(DATABASE_PATH)/db_postaudit.txt || true
	grep "^${audit}" $(DATABASE_PATH)/db_email.txt > /dev/null && sed -i "/^${audit}/d" $(DATABASE_PATH)/db_email.txt || true
endif
endif
	echo "cawk delete_audit end ----"

list_audit:
	find tests -name '*run_*' -type d | awk -F'run_' '{print $$NF}' | sort | uniq
	echo "cawk list_audit end ----"

# --------------------------------

database_view:
	touch $(DATABASE_PATH)/db_sync.txt
	touch $(DATABASE_PATH)/db_email.txt
	touch $(DATABASE_PATH)/db_postaudit.txt
	echo "\n-------------------------------------------"
	echo "cawk view $(DATABASE_PATH)/db_sync.txt"
	echo "-------------------------------------------"
	cat $(DATABASE_PATH)/db_sync.txt | sort || true
	echo "\n-------------------------------------------"
	echo "cawk view $(DATABASE_PATH)/db_email.txt"
	echo "-------------------------------------------"
	cat $(DATABASE_PATH)/db_email.txt | sort || true
	echo "\n-------------------------------------------"
	echo "cawk view $(DATABASE_PATH)/db_postaudit.txt"
	echo "-------------------------------------------"
	cat $(DATABASE_PATH)/db_postaudit.txt | sort || true
	echo "\n-------------------------------------------"
	echo "cawk database_view done ----"

database_sync_add:
	touch $(DATABASE_PATH)/db_sync.txt
ifeq ($(strip $(audit)),)
	echo "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	echo "cawk error audit=${audit} do not exist  ----"
else
ifeq ($(strip $(dir)),)
	echo "cawk error dir=SYNC_PATH must be set ----"
else
ifeq ($(strip $(regex)),)
	echo "cawk error regex=REGEX_PATTERN/.* must be set ----"
else
ifeq ($(strip $(scope)),)
	echo "cawk error scope=SCOPE_FILE/none must be set ----"
else
	echo "${audit} ${dir} ${regex} ${scope}" >> $(DATABASE_PATH)/db_sync.txt
endif
endif
endif
endif
endif
	echo "cawk database_sync_add end ----"

database_sync_update:
	touch $(DATABASE_PATH)/db_sync.txt
ifeq ($(strip $(audit)),)
	echo "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	echo "cawk error audit=${audit} do not exist  ----"
else
ifeq ($(strip $(dir)),)
	echo "cawk error dir=SYNC_PATH_DIR must be set ----"
else
ifeq ($(strip $(regex)),)
	echo "cawk error regex=REGEX_PATTERN/.* must be set ----"
else
ifeq ($(strip $(scope)),)
	echo "cawk error scope=SCOPE_FILE/none must be set ----"
else
	echo "cawk update $(DATABASE_PATH)/db_sync.txt"
	@sed -i "/^$(audit)/d" $(DATABASE_PATH)/db_sync.txt
	echo "${audit} ${dir} ${regex} ${scope}" >> $(DATABASE_PATH)/db_sync.txt
endif
endif
endif
endif
endif
	echo "cawk database_sync_add end ----"

database_sync_del:
	touch $(DATABASE_PATH)/db_sync.txt
ifeq ($(strip $(audit)),)
	echo "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	echo "cawk error audit=${audit} do not exist  ----"
else
	echo "cawk update $(DATABASE_PATH)/db_sync.txt"
	sed -i "/^$(audit)/d" $(DATABASE_PATH)/db_sync.txt
endif
endif
	echo "cawk database_sync_add end ----"

database_postaudit_add:
	touch $(DATABASE_PATH)/db_postaudit.txt
ifeq ($(strip $(audit)),)
	echo "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	echo "cawk error audit=${audit} do not exist  ----"
else
	echo "cawk update $(DATABASE_PATH)/db_postaudit.txt"
	echo "${audit}" >> $(DATABASE_PATH)/db_postaudit.txt
endif
endif
	echo "cawk database_postaudit_add end ----"

database_postaudit_update:
	touch $(DATABASE_PATH)/db_postaudit.txt
ifeq ($(strip $(audit)),)
	echo "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	echo "cawk error audit=${audit} do not exist  ----"
else
	echo "cawk update $(DATABASE_PATH)/db_postaudit.txt"
	sed -i "/^$(audit)/d" $(DATABASE_PATH)/db_postaudit.txt
	echo "${audit}" >> $(DATABASE_PATH)/db_postaudit.txt
endif
endif
	echo "cawk database_postaudit_add end ----"

database_postaudit_del:
	touch $(DATABASE_PATH)/db_postaudit.txt
ifeq ($(strip $(audit)),)
	echo "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	echo "cawk error audit=${audit} do not exist  ----"
else
	echo "cawk update $(DATABASE_PATH)/db_postaudit.txt"
	sed -i "/^$(audit)/d" $(DATABASE_PATH)/db_postaudit.txt
endif
endif
	echo "cawk database_postaudit_add end ----"

database_email_add:
	touch $(DATABASE_PATH)/db_email.txt
ifeq ($(strip $(audit)),)
	echo "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(strip $(dst)),)
	echo "cawk error dst=RECIPIENT_EMAIL must be set ----"
else
	cc=$(strip $(cc))
	if [ -z "$$cc" ]; then cc=none; fi; \
	echo "cawk update $(DATABASE_PATH)/db_email.txt"; \
	echo "$(audit) $(dst) $$cc" >> $(DATABASE_PATH)/db_email.txt
endif
endif
	echo "cawk email_database_add end ----"

database_email_update:
	touch $(DATABASE_PATH)/db_email.txt
ifeq ($(strip $(audit)),)
	echo "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(strip $(dst)),)
	echo "cawk error dst=RECIPIENT_EMAIL must be set ----"
else
	cc=$(strip $(cc))
	if [ -z "$$cc" ]; then cc=none; fi; \
	echo "cawk update $(DATABASE_PATH)/db_email.txt"; \
	sed -i "/^$(audit)/d" $(DATABASE_PATH)/db_email.txt
	echo "${audit} ${dst} ${cc}" >> $(DATABASE_PATH)/db_email.txt
endif
endif
	echo "cawk email_database_update end ----"

database_email_del:
	touch $(DATABASE_PATH)/db_email.txt
ifeq ($(strip $(audit)),)
	echo "cawk error audit=AUDIT_NAME must be set ----"
else
	echo "cawk update $(DATABASE_PATH)/db_email.txt"
	sed -i "/^$(audit)/d" $(DATABASE_PATH)/db_email.txt
endif
	echo "cawk email_database_del end ----"

# --------------------------------

sync_run: clean_tmp tests_target_common database_target_sh
	if [ ! -f $(DATABASE_PATH_SH)/database_sync.script ]; then \
		echo "cawk error: $(DATABASE_PATH_SH)/database_sync.script does not exist, execution skipped ----"; \
	else \
		echo "cawk $(DATABASE_PATH_SH)/database_sync.script execution ----"; \
		$(DATABASE_PATH_SH)/database_sync.script ${audit}; \
	fi
ifeq ($(strip $(audit)),)
	echo "cawk error audit=AUDIT_NAME must be set ----"
	echo "cawk sync_run done ----"
else
	echo "cawk cleaning local configurations before sync"
	find $(CONFS_PATH)/run_${audit} $(FIND_CONF_SELECT) | egrep -v '(gitkeep)' | while read file; do \
		rm -f $$file; \
	done
	echo "cawk sync files from $(DATABASE_PATH)/db_sync.txt"
	grep "^$(audit)" $(DATABASE_PATH)/db_sync.txt | while read line; do \
		paths=$$(echo "$$line" | gawk '{print $$2}'); \
		if [ "$$paths" != "none" ]; then \
			regex=$$(echo "$$line" | gawk '{print $$3}'); \
			scope=$$(echo "$$line" | gawk '{if ( $$4 == "") { print "none"; } else { print $$4; }}'); \
			cd $(CONFS_PATH)/run_$(audit) && ../../$(COMMON_PATH)/sync_cawk_conf.gawk "$$paths" "$$regex" "../../$$scope" && cd ../.. ; \
		else \
			echo "cawk error: $(DATABASE_PATH)/db_sync.txt audit $$(echo "$$line" | gawk '{print $$1}') path does not exist, execution skipped ----"; \
		fi \
	done
	echo "cawk sync_run_audit ${audit} done ----"
endif

sync_run_audit: 
	cat $(DATABASE_PATH)/db_sync.txt | while read line; do \
		audit=$$(echo "$$line" | gawk '{print $$1}'); \
		gmake sync_run audit=$$audit; \
	done
	gmake list_audit
	echo "cawk sync_run_audit all audit done ----"

# --------------------------------

postaudit_run: clean tests_target_common database_target_sh
ifeq ($(strip $(audit)),)
	echo "cawk error audit=AUDIT_NAME must be set ----"
	echo "cawk postaudit_run done ----"
else
	if [ ! -f $(DATABASE_PATH_SH)/database_postaudit.script ]; then \
		echo "cawk error: $(DATABASE_PATH_SH)/database_postaudit.script does not exist, execution skipped ----"; \
	else \
		echo "cawk $(DATABASE_PATH_SH)/database_postaudit.script execution ----"; \
		$(DATABASE_PATH_SH)/database_postaudit.script ${audit}; \
	fi
	echo "cawk postaudit_run ${audit} done ----"
endif

postaudit_run_audit:
	cat $(DATABASE_PATH)/db_postaudit.txt | while read line; do \
		echo $$line ; \
		audit=$$line; \
		gmake postaudit_run audit=$$audit; \
	done
	gmake list_audit
	echo "cawk postaudit_run_audit all audit done ----"

# --------------------------------

email_send:
ifeq ($(strip $(audit)),)
	echo "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	echo "cawk error audit=${audit} do not exist  ----"
else
	if grep -q "^${audit} " $(DATABASE_PATH)/db_email.txt; then \
		email_info=$$(grep "^${audit} " $(DATABASE_PATH)/db_email.txt); \
		dst=$$(echo $$email_info | awk '{print $$2}'); \
		cc=$$(echo $$email_info | awk '{print $$3}'); \
		if [ -z "$$dst" ]; then \
			echo "cawk error dst not found for audit ${audit} ----"; \
			exit 0; \
		fi; \
		if [ -z "$$(find $(REPORT_PATH)/run_${audit} -name '*.csv' -type f)" ]; then \
			echo "cawk error no csv files found in $(REPORT_PATH)/run_${audit} ----"; \
			exit 0; \
		fi; \
		zip -j -9 -q $(REPORT_PATH)/run_${audit}/assessment.run_${audit}.export.zip $$(find $(REPORT_PATH)/run_${audit} -name '*all.full.security.csv' -o -name '*all.full.audit.csv' -o -name '*all.full.summary.txt' -type f -o -name '*all.full.exceptions.csv' -type f) || true; \
		echo "cawk sending audit ${audit} to $$dst ----"; \
		if [ "$$cc" != "none" ]; then \
			if [ -n "$$(find $(REPORT_PATH)/run_${audit} -name '*all.full.summary.txt' -type f)" ]; then \
				cat $(COMMON_PATH)/common_message.txt $(REPORT_PATH)/run_${audit}/*all.full.summary.txt | mutt -s "cawk ${audit} assessment" -a $(REPORT_PATH)/run_${audit}/assessment.run_${audit}.export.zip -c $$cc -- $$dst; \
			else \
				echo "cawk reporting" | mutt -s "cawk ${audit} assessment" -a $(REPORT_PATH)/run_${audit}/assessment.run_${audit}.export.zip -c $$cc -- $$dst; \
			fi; \
		else \
			if [ -n "$$(find $(REPORT_PATH)/run_${audit} -name '*all.full.summary.txt' -type f)" ]; then \
				cat $(COMMON_PATH)/common_message.txt $(REPORT_PATH)/run_${audit}/*all.full.summary.txt | mutt -s "cawk ${audit} assessment" -a $(REPORT_PATH)/run_${audit}/assessment.run_${audit}.export.zip -- $$dst; \
			else \
				echo "cawk reporting" | mutt -s "cawk ${audit} assessment" -a $(REPORT_PATH)/run_${audit}/assessment.run_${audit}.export.zip -- $$dst; \
			fi; \
		fi; \
		echo "cawk email sent successfully ----"; \
	else \
		echo "cawk error no email info found for audit ${audit} ----"; \
	fi
endif
endif
	echo "cawk send_audit_email end ----"

email_send_audit:
	for audit in $(RUN_DIRS); do \
		gmake email_send audit=$$audit; \
	done
	echo "cawk email_send_audit done ----"

# --------------------------------

backup_run: clean
ifeq ($(strip $(audit)),)
	echo "cawk error audit=AUDIT_NAME must be set ----"
	echo "cawk backup_run done ----"
else
	rm -f backup/run_audit_${audit}_$(shell date +%Y-%m-%d).tar.gz backup/run_audit_${audit}_$(shell date +%Y-%m-%d).tar
	find confs/run_${audit}* tests/run_${audit}* exceptions/run_${audit}* reports/run_${audit}* -type f,d -print0 | tar cvf backup/run_audit_${audit}_$(shell date +%Y-%m-%d).tar --null -T - >/dev/null 2>&1
	gzip backup/run_audit_${audit}_$(shell date +%Y-%m-%d).tar
	echo "cawk backup_run_audit ${audit} done in backup/run_audit_${audit}_$(shell date +%Y-%m-%d).tar.gz ----"
endif

backup_run_audit: clean
	rm -f backup/run_audit_$(shell date +%Y-%m-%d).tar backup/run_audit_$(shell date +%Y-%m-%d).tar.gz
	find $(DATABASE_PATH_SH)/* $(DATABASE_PATH)/* confs/run_* tests/run_* exceptions/run_* reports/run_* -type f,d -print0 | tar cvf backup/run_audit_$(shell date +%Y-%m-%d).tar --null -T - >/dev/null 2>&1
	gzip backup/run_audit_$(shell date +%Y-%m-%d).tar
	gmake list_audit
	echo "cawk backup_run_audit all audits done in backup/run_audit_$(shell date +%Y-%m-%d).tar.gz ----"

restore_run: clean
ifeq ($(strip $(audit)),)
	echo "cawk error audit=AUDIT_NAME and file=BACKUP_PATH_FILE must be set ----"
	echo "cawk restore_run done ----"
else
ifeq ($(strip $(file)),)
	echo "cawk error audit=AUDIT_NAME and file=BACKUP_PATH_FILE must be set ----"
	echo "cawk restore_run done ----"
else
	if [ -f ${file} ]; then \
		tar -xzvf ${file} >/dev/null 2>&1; \
		echo "cawk restore_run ${audit} done ----"; \
	else \
		echo "cawk error: file ${file} does not exist ----"; \
	fi
endif
endif

restore_run_audit: clean
ifeq ($(strip $(file)),)
	echo "cawk error file=BACKUP_PATH_FILE must be set ----"
	echo "cawk restore_run_audit done ----"
else
	if [ -f ${file} ]; then \
		tar -xzvf ${file} >/dev/null 2>&1; \
		echo "cawk restore_run_audit done ----"; \
	else \
		echo "cawk error: file ${file} does not exist ----"; \
	fi
endif

migrate:
ifeq ($(strip $(file)),)
	echo "cawk error file=BACKUP_PATH_FILE must be set ----"
	exit 0
endif
	cp ${file} backup/
	gmake restore_run_audit file=backup/$(notdir ${file})
	gmake tests_run_audit_copy
	gmake tests_common tests_run_audit

# --------------------------------

check_supplier:
ifneq ($(strip $(supplier)),)
ifneq ($(findstring $(supplier),$(SUPPLIER_SCOPE)),$(supplier))
	echo "cawk error ($(supplier)) is not the list of suppliers covered by cawk ($(SUPPLIER_SCOPE)) ----"
	exit 0
endif
endif

supplier:
	echo $(SUPPLIER_SCOPE)
	echo "cawk supplier done ----"

# --------------------------------

system:
	$(TESTS_SYSTEM)/cawk_check_system

# --------------------------------

common:
	grep purpose common/*.template

# --------------------------------

SUPPLIER_M4_REPO_FILES = $(foreach supplier,$(SUPPLIER_SCOPE),$(TESTS_$(supplier)_REPO_M4:.gawk.m4=.gawk))
SUPPLIER_TEMPLATE_REPO_FILES = $(foreach supplier,$(SUPPLIER_SCOPE),$(TESTS_$(supplier)_REPO_TEMPLATE:.gawk.template=.gawk))

tests_target_common: $(TESTS_COMMON_TEMPLATE:.gawk.template=.gawk) $(TESTS_COMMON_SH:.script.sh=.script)

database_target_sh: $(DATABASE_SH:.script.sh=.script)

tests_target_repo: tests_target_common\
		$(SUPPLIER_M4_REPO_FILES) \
		$(SUPPLIER_TEMPLATE_REPO_FILES) \
		$(EXCEPTION_M4:.m4=)

SUPPLIER_M4_RUN_FILES = $(foreach supplier,$(SUPPLIER_SCOPE),$(TESTS_$(supplier)_RUN_M4:.gawk.m4=.gawk))
SUPPLIER_TEMPLATE_RUN_FILES = $(foreach supplier,$(SUPPLIER_SCOPE),$(TESTS_$(supplier)_RUN_TEMPLATE:.gawk.template=.gawk))

tests_target_run: tests_target_common \
		$(SUPPLIER_M4_RUN_FILES) \
		$(SUPPLIER_TEMPLATE_RUN_FILES) \
		$(EXCEPTION_M4:.m4=)

tests_common: tests_target_common
	echo "cawk tests_common done ----"

tests_repo: tests_target_repo
	echo "cawk tests_repo done ----"

tests_run_copy:
ifeq ($(strip $(audit)),)
	echo "cawk error audit=AUDIT_NAME must be set ----"
else
	@for supplier in $(SUPPLIER_SCOPE); do \
		if [ ! -d "$(TESTS_PATH)/run_${audit}/tests.$$supplier" ]; then \
			echo "cawk error: $(TESTS_PATH)/run_${audit}/tests.$$supplier does not exist ----"; \
		elif [ -d "$(TESTS_PATH)/repo/tests.$$supplier" ]; then \
			find $(TESTS_PATH)/repo/tests.$$supplier -name "*.template" -o -name "*.m4" -exec cp {} $(TESTS_PATH)/run_${audit}/tests.$$supplier/ \; 2>/dev/null || true; \
			echo "cawk tests_repo_copy $$supplier to run_${audit} done ----"; \
		else \
			echo "cawk error: $(TESTS_PATH)/repo/tests.$$supplier does not exist ----"; \
		fi \
	done
endif

RUN_DIRS := $(shell find tests -name '*run_*' -type d 2>/dev/null | awk -F'run_' '{print $$NF}' | sort | uniq || echo "")
tests_run_audit_copy:
	@for dir in $(RUN_DIRS); do \
		audit=$$dir; \
		for supplier in $(SUPPLIER_SCOPE); do \
			if [ ! -d "$(TESTS_PATH)/run_$${audit}/tests.$$supplier" ]; then \
				echo "cawk error: $(TESTS_PATH)/run_$${audit}/tests.$$supplier does not exist ----"; \
			elif [ -d "$(TESTS_PATH)/repo/tests.$$supplier" ]; then \
				find $(TESTS_PATH)/repo/tests.$$supplier -name "*.template" -o -name "*.m4" -exec cp {} $(TESTS_PATH)/run_$${audit}/tests.$$supplier/ \; 2>/dev/null || true; \
				echo "cawk tests_repo_copy $$supplier to run_$${audit} done ----"; \
			else \
				echo "cawk error: $(TESTS_PATH)/repo/tests.$$supplier does not exist ----"; \
			fi \
		done \
	done

tests_run: tests_target_run
	echo "cawk tests_run $$audit done ----"

tests_run_audit:
	@for dir in $(RUN_DIRS); do \
		gmake tests_run audit=$$dir; \
	done
	echo "cawk tests_run_audit end ----"

%.gawk: %.gawk.template
	sed -f support/tests.sed $< > $@ || true
	chmod 750 $@

%.script: %.script.sh
	cp $< $@ || true
	chmod 750 $@

%.gawk: %.gawk.m4
	m4 -I m4 $< | sed -f support/tests.sed > $@ || true
	chmod 750 $@

%: %.m4
	m4 -I m4 $< | sed '/^$$/d' > $@ || true
	chmod 650 $@
	
# --------------------------------

check_repo: clean_report_repo clean_tmp tests_repo check_supplier
ifneq ($(strip $(audit)),)
	echo "cawk error the use of <audit=AUDIT_NAME> can only be used with check_run target ----"
	exit 0
else
ifeq ($(strip $(supplier)),)
ifeq ($(strip $(MAKE_PARALLEL)),no)
	$(foreach scope,$(SUPPLIER_SCOPE),\
		echo "cawk compute $(scope) devices ----" ;\
		touch $(REPORT_PATH)/repo/assessment.$(scope).csv.swap ;\
		$(foreach test,$(shell find $(TESTS_$(scope)_REPO_PATH) -name '*.gawk' -type f 2>/dev/null),\
			find $(CONFIGURATION_$(scope)_REPO_PATH) $(FIND_CONF_SELECT) -exec ./$(test) {} \; >> $(REPORT_PATH)/repo/assessment.$(scope).csv.swap ;\
		) \
		egrep -v -f $(EXCEPTION_PATH)/repo/exceptions.$(scope) $(REPORT_PATH)/repo/assessment.$(scope).csv.swap | sort | uniq > $(REPORT_PATH)/repo/assessment.$(scope).csv || true ;\
		cat $(REPORT_PATH)/repo/assessment.$(scope).csv >> $(REPORT_PATH)/repo/assessment.all.full.csv ;\
		egrep -f $(EXCEPTION_PATH)/repo/exceptions.$(scope) $(REPORT_PATH)/repo/assessment.$(scope).csv.swap | sort | uniq > $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv || true ;\
		cat $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv >> $(REPORT_PATH)/repo/assessment.all.full.exceptions.csv ;\
		rm -f $(REPORT_PATH)/repo/assessment.$(scope).csv.swap ;\
		$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/repo/assessment.$(scope).csv > $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
		echo "------------------------" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
		echo "---- tests purposes ----" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
		echo "------------------------" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
		gmake catalog_repo | egrep "tests/" | grep $(scope) | sort >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
	)
	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/repo/assessment.all.full.csv > $(REPORT_PATH)/repo/assessment.all.full.summary.txt
	echo "------------------------" >> $(REPORT_PATH)/repo/assessment.all.full.summary.txt
	echo "---- tests purposes ----" >> $(REPORT_PATH)/repo/assessment.all.full.summary.txt
	echo "------------------------" >> $(REPORT_PATH)/repo/assessment.all.full.summary.txt
	gmake catalog_repo | egrep "tests/" | sort >> $(REPORT_PATH)/repo/assessment.all.full.summary.txt
	egrep '(high|medium|low);error' $(REPORT_PATH)/repo/assessment.all.full.csv > $(REPORT_PATH)/repo/assessment.all.full.security.csv || true
	egrep '(info;error|;warning)' $(REPORT_PATH)/repo/assessment.all.full.csv > $(REPORT_PATH)/repo/assessment.all.full.audit.csv || true
ifeq ($(strip $(JSON)),yes)
	echo "cawk json reporting performed ----"
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/repo/assessment.$(scope).summary.txt > $(REPORT_PATH)/repo/assessment.$(scope).summary.json ;\
		$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.$(scope).csv > $(REPORT_PATH)/repo/assessment.$(scope).json ;\
		$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv > $(REPORT_PATH)/repo/assessment.$(scope).exceptions.json ;\
	)
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.full.csv > $(REPORT_PATH)/repo/assessment.all.full.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.full.security.csv > $(REPORT_PATH)/repo/assessment.all.full.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.full.exceptions.csv > $(REPORT_PATH)/repo/assessment.all.full.exceptions.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/repo/assessment.all.full.summary.txt > $(REPORT_PATH)/repo/assessment.all.full.summary.json
else
	echo "cawk json reporting skipped ----"
endif
else
	$(foreach scope,$(SUPPLIER_SCOPE),\
		echo "cawk compute $(scope) devices ----" ;\
		touch $(REPORT_PATH)/repo/assessment.$(scope).csv.swap ;\
		find $(CONFIGURATION_$(scope)_REPO_PATH) $(FIND_CONF_SELECT)  > $(TESTS_TMP)/conf_list_files.repo.$(scope) 2>/dev/null ;\
		find $(TESTS_$(scope)_REPO_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.repo.$(scope) 2>/dev/null ;\
		$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk $(TESTS_TMP)/conf_list_files.repo.$(scope) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.repo.$(scope) > \
		$(TESTS_TMP)/Makefile.repo.$(scope) ;\
		gmake -f $(TESTS_TMP)/Makefile.repo.$(scope) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(REPORT_PATH)/repo/assessment.$(scope).csv.swap ;\
		egrep -v -f $(EXCEPTION_PATH)/repo/exceptions.$(scope) $(REPORT_PATH)/repo/assessment.$(scope).csv.swap | sort | uniq > $(REPORT_PATH)/repo/assessment.$(scope).csv || true ;\
		cat $(REPORT_PATH)/repo/assessment.$(scope).csv >> $(REPORT_PATH)/repo/assessment.all.full.csv ;\
		egrep -f $(EXCEPTION_PATH)/repo/exceptions.$(scope) $(REPORT_PATH)/repo/assessment.$(scope).csv.swap | sort | uniq > $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv || true ;\
		cat $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv >> $(REPORT_PATH)/repo/assessment.all.full.exceptions.csv ;\
		rm -f $(REPORT_PATH)/repo/assessment.$(scope).csv.swap ;\
		$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/repo/assessment.$(scope).csv > $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
		echo "------------------------" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
		echo "---- tests purposes ----" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
		echo "------------------------" >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
		gmake catalog_repo | egrep "tests/" | grep $(scope) | sort >> $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
	)
	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/repo/assessment.all.full.csv > $(REPORT_PATH)/repo/assessment.all.full.summary.txt
	echo "------------------------" >> $(REPORT_PATH)/repo/assessment.all.full.summary.txt
	echo "---- tests purposes ----" >> $(REPORT_PATH)/repo/assessment.all.full.summary.txt
	echo "------------------------" >> $(REPORT_PATH)/repo/assessment.all.full.summary.txt
	gmake catalog_repo | egrep "tests/" | sort >> $(REPORT_PATH)/repo/assessment.all.full.summary.txt
	egrep '(high|medium|low);error' $(REPORT_PATH)/repo/assessment.all.full.csv > $(REPORT_PATH)/repo/assessment.all.full.security.csv || true
	egrep '(info;error|;warning)' $(REPORT_PATH)/repo/assessment.all.full.csv > $(REPORT_PATH)/repo/assessment.all.full.audit.csv || true
ifeq ($(strip $(JSON)),yes)
	echo "cawk json reporting performed ----"
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/repo/assessment.$(scope).summary.txt > $(REPORT_PATH)/repo/assessment.$(scope).summary.json ;\
		$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.$(scope).csv > $(REPORT_PATH)/repo/assessment.$(scope).json ;\
		$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv > $(REPORT_PATH)/repo/assessment.$(scope).exceptions.json ;\
	)
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.full.csv > $(REPORT_PATH)/repo/assessment.all.full.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.full.security.csv > $(REPORT_PATH)/repo/assessment.all.full.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.full.exceptions.csv > $(REPORT_PATH)/repo/assessment.all.full.exceptions.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/repo/assessment.all.full.summary.txt > $(REPORT_PATH)/repo/assessment.all.full.summary.json
else
	echo "cawk json reporting skipped ----"
endif
endif
else
ifeq ($(strip $(MAKE_PARALLEL)),no)
	echo "cawk compute $(supplier) devices ----"
	touch $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap
	$(foreach test,$(shell find $(TESTS_$(supplier)_REPO_PATH) -name '*.gawk' -type f 2>/dev/null),\
		find $(CONFIGURATION_$(supplier)_REPO_PATH) $(FIND_CONF_SELECT) -exec ./$(test) {} \; >> $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap ;\
	)
	egrep -v -f $(EXCEPTION_PATH)/repo/exceptions.$(supplier) $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap | sort | uniq > $(REPORT_PATH)/repo/assessment.$(supplier).csv || true
	cat $(REPORT_PATH)/repo/assessment.$(supplier).csv >> $(REPORT_PATH)/repo/assessment.all.full.csv
	egrep -f $(EXCEPTION_PATH)/repo/exceptions.$(supplier) $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap | sort | uniq > $(REPORT_PATH)/repo/assessment.$(supplier).exceptions.csv || true
	cat $(REPORT_PATH)/repo/assessment.$(supplier).exceptions.csv >> $(REPORT_PATH)/repo/assessment.all.full.exceptions.csv
	rm -f $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap
	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/repo/assessment.$(supplier).csv > $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	echo "------------------------" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	echo "---- tests purposes ----" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	echo "------------------------" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	gmake catalog_repo | egrep "tests/" | grep $(supplier) | sort >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/repo/assessment.all.full.csv > $(REPORT_PATH)/repo/assessment.all.full.summary.txt
	echo "------------------------" >> $(REPORT_PATH)/repo/assessment.all.full.summary.txt
	echo "---- tests purposes ----" >> $(REPORT_PATH)/repo/assessment.all.full.summary.txt
	echo "------------------------" >> $(REPORT_PATH)/repo/assessment.all.full.summary.txt
	gmake catalog_repo | egrep "tests/" | sort >> $(REPORT_PATH)/repo/assessment.all.full.summary.txt
	egrep '(high|medium|low);error' $(REPORT_PATH)/repo/assessment.all.full.csv > $(REPORT_PATH)/repo/assessment.all.full.security.csv || true
	egrep '(info;error|;warning)' $(REPORT_PATH)/repo/assessment.all.full.csv > $(REPORT_PATH)/repo/assessment.all.full.audit.csv || true
ifeq ($(strip $(JSON)),yes)
	echo "cawk json reporting performed ----"
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt > $(REPORT_PATH)/repo/assessment.$(supplier).summary.json ;\
		$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.$(supplier).csv > $(REPORT_PATH)/repo/assessment.$(supplier).json ;\
		$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.$(supplier).exceptions.csv > $(REPORT_PATH)/repo/assessment.$(supplier).exceptions.json ;\
	)
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.full.csv > $(REPORT_PATH)/repo/assessment.all.full.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.full.security.csv > $(REPORT_PATH)/repo/assessment.all.full.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.full.exceptions.csv > $(REPORT_PATH)/repo/assessment.all.full.exceptions.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/repo/assessment.all.full.summary.txt > $(REPORT_PATH)/repo/assessment.all.full.summary.json
else
	echo "cawk json reporting skipped ----"
endif
else
	echo "cawk compute $(supplier) devices ----"
	touch $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap
	find $(CONFIGURATION_$(supplier)_REPO_PATH) $(FIND_CONF_SELECT) > $(TESTS_TMP)/conf_list_files.repo.$(supplier) 2>/dev/null
	find $(TESTS_$(supplier)_REPO_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.repo.$(supplier) 2>/dev/null
	$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk $(TESTS_TMP)/conf_list_files.repo.$(supplier) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.repo.$(supplier) > \
	$(TESTS_TMP)/Makefile.repo.$(supplier)
	gmake -f $(TESTS_TMP)/Makefile.repo.$(supplier) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap
	egrep -v -f $(EXCEPTION_PATH)/repo/exceptions.$(supplier) $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap | sort | uniq > $(REPORT_PATH)/repo/assessment.$(supplier).csv || true
	cat $(REPORT_PATH)/repo/assessment.$(supplier).csv >> $(REPORT_PATH)/repo/assessment.all.full.csv
	egrep -f $(EXCEPTION_PATH)/repo/exceptions.$(supplier) $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap | sort | uniq > $(REPORT_PATH)/repo/assessment.$(supplier).exceptions.csv || true
	cat $(REPORT_PATH)/repo/assessment.$(supplier).exceptions.csv >> $(REPORT_PATH)/repo/assessment.all.full.exceptions.csv
	rm -f $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap
	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/repo/assessment.$(supplier).csv > $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	echo "------------------------" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	echo "---- tests purposes ----" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	echo "------------------------" >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	gmake catalog_repo | egrep "tests/" | grep $(supplier) | sort >> $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/repo/assessment.all.full.csv > $(REPORT_PATH)/repo/assessment.all.full.summary.txt
	echo "------------------------" >> $(REPORT_PATH)/repo/assessment.all.full.summary.txt
	echo "---- tests purposes ----" >> $(REPORT_PATH)/repo/assessment.all.full.summary.txt
	echo "------------------------" >> $(REPORT_PATH)/repo/assessment.all.full.summary.txt
	gmake catalog_repo | egrep "tests/" | sort >> $(REPORT_PATH)/repo/assessment.all.full.summary.txt
	egrep '(high|medium|low);error' $(REPORT_PATH)/repo/assessment.all.full.csv > $(REPORT_PATH)/repo/assessment.all.full.security.csv || true
	egrep '(info;error|;warning)' $(REPORT_PATH)/repo/assessment.all.full.csv > $(REPORT_PATH)/repo/assessment.all.full.audit.csv || true
ifeq ($(strip $(JSON)),yes)
	echo "cawk json reporting performed ----"
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt > $(REPORT_PATH)/repo/assessment.$(supplier).summary.json ;\
		$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.$(supplier).csv > $(REPORT_PATH)/repo/assessment.$(supplier).json ;\
		$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.$(supplier).exceptions.csv > $(REPORT_PATH)/repo/assessment.$(supplier).exceptions.json ;\
	)
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.full.csv > $(REPORT_PATH)/repo/assessment.all.full.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.full.security.csv > $(REPORT_PATH)/repo/assessment.all.full.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/repo/assessment.all.full.exceptions.csv > $(REPORT_PATH)/repo/assessment.all.full.exceptions.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/repo/assessment.all.full.summary.txt > $(REPORT_PATH)/repo/assessment.all.full.summary.json
else
	echo "cawk json reporting skipped ----"
endif
endif
endif
endif
	gmake archive_repo
	echo "cawk check_repo done ----"


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
		echo "cawk compute $(scope) devices ----" ;\
		touch $(REPORT_PATH)/run/assessment.$(scope).csv.swap ;\
		$(foreach test,$(shell find $(TESTS_$(scope)_RUN_PATH) -name '*.gawk' -type f 2>/dev/null),\
			find $(CONFIGURATION_$(scope)_RUN_PATH) $(FIND_CONF_SELECT) -exec ./$(test) {} \; >> $(REPORT_PATH)/run/assessment.$(scope).csv.swap ;\
		) \
		egrep -v -f $(EXCEPTION_PATH)/run/exceptions.$(scope) $(REPORT_PATH)/run/assessment.$(scope).csv.swap | sort | uniq > $(REPORT_PATH)/run/assessment.$(scope).csv || true ;\
		cat $(REPORT_PATH)/run/assessment.$(scope).csv >> $(REPORT_PATH)/run/assessment.all.full.csv ;\
		egrep -f $(EXCEPTION_PATH)/run/exceptions.$(scope) $(REPORT_PATH)/run/assessment.$(scope).csv.swap | sort | uniq > $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv || true ;\
		cat $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv >> $(REPORT_PATH)/run/assessment.all.full.exceptions.csv ;\
		rm -f $(REPORT_PATH)/run/assessment.$(scope).csv.swap ;\
		$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run/assessment.$(scope).csv > $(REPORT_PATH)/run/assessment.$(scope).summary.txt ;\
		echo "------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		echo "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		echo "------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		gmake catalog_run | egrep "tests/" | sort >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
	)
	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run/assessment.all.full.csv > $(REPORT_PATH)/run/assessment.all.full.summary.txt
	echo "------------------------" >> $(REPORT_PATH)/run/assessment.all.full.summary.txt
	echo "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.all.full.summary.txt
	echo "------------------------" >> $(REPORT_PATH)/run/assessment.all.full.summary.txt
	gmake catalog_repo | egrep "tests/" | sort >> $(REPORT_PATH)/run/assessment.all.full.summary.txt
	egrep '(high|medium|low);error' $(REPORT_PATH)/run/assessment.all.full.csv > $(REPORT_PATH)/run/assessment.all.full.security.csv || true
	egrep '(info;error|;warning)' $(REPORT_PATH)/run/assessment.all.full.csv > $(REPORT_PATH)/run/assessment.all.full.audit.csv || true
ifeq ($(strip $(JSON)),yes)
	echo "cawk json reporting performed ----"
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run/assessment.$(scope).summary.txt > $(REPORT_PATH)/run/assessment.$(scope).summary.json ;\
		$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.$(scope).csv > $(REPORT_PATH)/run/assessment.$(scope).json ;\
		$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv > $(REPORT_PATH)/run/assessment.$(scope).exceptions.json ;\
	)
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.full.csv > $(REPORT_PATH)/run/assessment.all.full.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.full.security.csv > $(REPORT_PATH)/run/assessment.all.full.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.full.exceptions.csv > $(REPORT_PATH)/run/assessment.all.full.exceptions.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run/assessment.all.full.summary.txt > $(REPORT_PATH)/run/assessment.all.full.summary.json
else
	echo "cawk json reporting skipped ----"
endif
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	echo "cawk error audit=${audit} do not exist  ----"
	exit 0
endif
	$(foreach scope,$(SUPPLIER_SCOPE),\
		if [ ! -d "$(CONFIGURATION_$(scope)_RUN_PATH)" ] || [ ! -d "$(TESTS_$(scope)_RUN_PATH)" ]; then \
			echo "cawk $(CONFIGURATION_$(scope)_RUN_PATH) or $(TESTS_$(scope)_RUN_PATH) do not exist, skip the ${audit} $(scope) assessment ----"; \
		else \
			echo "cawk compute ${audit} $(scope) devices ----" ;\
			touch $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap ;\
			$(foreach test,$(shell find $(TESTS_$(scope)_RUN_PATH) -name '*.gawk' -type f 2>/dev/null),\
				find $(CONFIGURATION_$(scope)_RUN_PATH) $(FIND_CONF_SELECT) -exec ./$(test) {} \; >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap ;\
			) \
			egrep -v -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(scope) $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap | sort | uniq > $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv || true ;\
			cat $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv >> $(REPORT_PATH)/run_${audit}/assessment.all.full.csv ;\
			egrep -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(scope) $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap | sort | uniq > $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv || true ;\
			cat $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv >> $(REPORT_PATH)/run_${audit}/assessment.all.full.exceptions.csv ;\
			rm -f $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap ;\
			$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv > $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt ;\
			echo "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			echo "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			echo "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			gmake catalog_run audit=$(audit) | grep "tests/" | sort >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run_${audit}/assessment.all.full.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt;\
			echo "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt;\
			echo "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt;\
			echo "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt;\
			gmake catalog_run audit=$(audit) | grep "tests/" | sort >> $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt;\
			egrep '(high|medium|low);error' $(REPORT_PATH)/run_${audit}/assessment.all.full.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.security.csv || true;\
			egrep '(info;error|;warning)' $(REPORT_PATH)/run_${audit}/assessment.all.full.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.audit.csv || true;\
		fi; \
	)
ifeq ($(strip $(JSON)),yes)
	echo "cawk json reporting performed ----"
	$(foreach scope,$(SUPPLIER_SCOPE),\
		if [ ! -d "$(CONFIGURATION_$(scope)_RUN_PATH)" ] || [ ! -d "$(TESTS_$(scope)_RUN_PATH)" ]; then \
			echo "cawk $(CONFIGURATION_$(scope)_RUN_PATH) or $(TESTS_$(scope)_RUN_PATH) do not exist, skip the ${audit} $(scope) json reporting ----"; \
		else \
			$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt > $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.json ;\
			$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv > $(REPORT_PATH)/run_${audit}/assessment.$(scope).json ;\
			$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv > $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.json ;\
		fi;	\
	)
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.full.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.full.security.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.full.exceptions.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.exceptions.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt > $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.json
else
	echo "cawk json reporting skipped ----"
endif
endif
else
ifeq ($(strip $(audit)),)
	$(foreach scope,$(SUPPLIER_SCOPE),\
		echo "cawk compute $(scope) devices ----" ;\
		touch $(REPORT_PATH)/run/assessment.$(scope).csv.swap ;\
		find $(CONFIGURATION_$(scope)_RUN_PATH) $(FIND_CONF_SELECT) > $(TESTS_TMP)/conf_list_files.run.$(scope) 2>/dev/null ;\
		find $(TESTS_$(scope)_RUN_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.run.$(scope) 2>/dev/null ;\
		$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk \
		$(TESTS_TMP)/conf_list_files.run.$(scope) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.run.$(scope) > \
		$(TESTS_TMP)/Makefile.run.$(scope) ;\
		gmake -f $(TESTS_TMP)/Makefile.run.$(scope) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(REPORT_PATH)/run/assessment.$(scope).csv.swap ;\
		egrep -v -f $(EXCEPTION_PATH)/run/exceptions.$(scope) $(REPORT_PATH)/run/assessment.$(scope).csv.swap | sort | uniq > $(REPORT_PATH)/run/assessment.$(scope).csv || true ;\
		cat $(REPORT_PATH)/run/assessment.$(scope).csv >> $(REPORT_PATH)/run/assessment.all.full.csv ;\
		egrep -f $(EXCEPTION_PATH)/run/exceptions.$(scope) $(REPORT_PATH)/run/assessment.$(scope).csv.swap | sort | uniq > $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv || true ;\
		cat $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv >> $(REPORT_PATH)/run/assessment.all.full.exceptions.csv ;\
		rm -f $(REPORT_PATH)/run/assessment.$(scope).csv.swap ;\
		$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run/assessment.$(scope).csv > $(REPORT_PATH)/run/assessment.$(scope).summary.txt ;\
		echo "------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		echo "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		echo "------------------------" >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
		gmake catalog_run | egrep "tests/" | sort >> $(REPORT_PATH)/run/assessment.$(scope).summary.txt;\
	)
	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run/assessment.all.full.csv > $(REPORT_PATH)/run/assessment.all.full.summary.txt
	echo "------------------------" >> $(REPORT_PATH)/run/assessment.all.full.summary.txt
	echo "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.all.full.summary.txt
	echo "------------------------" >> $(REPORT_PATH)/run/assessment.all.full.summary.txt
	gmake catalog_repo | egrep "tests/" | sort >> $(REPORT_PATH)/run/assessment.all.full.summary.txt
	egrep '(high|medium|low);error' $(REPORT_PATH)/run/assessment.all.full.csv > $(REPORT_PATH)/run/assessment.all.full.security.csv || true
	egrep '(info;error|;warning)' $(REPORT_PATH)/run/assessment.all.full.csv > $(REPORT_PATH)/run/assessment.all.full.audit.csv || true
ifeq ($(strip $(JSON)),yes)
	echo "cawk json reporting performed ----"
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run/assessment.$(scope).summary.txt > $(REPORT_PATH)/run/assessment.$(scope).summary.json ;\
		$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.$(scope).csv > $(REPORT_PATH)/run/assessment.$(scope).json ;\
		$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv > $(REPORT_PATH)/run/assessment.$(scope).exceptions.json ;\
	)
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.full.csv > $(REPORT_PATH)/run/assessment.all.full.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.full.security.csv > $(REPORT_PATH)/run/assessment.all.full.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.full.exceptions.csv > $(REPORT_PATH)/run/assessment.all.full.exceptions.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run/assessment.all.full.summary.txt > $(REPORT_PATH)/run/assessment.all.full.summary.json
else
	echo "cawk json reporting skipped ----"
endif
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	echo "cawk error audit=${audit} do not exist  ----"
	exit 0
endif
	$(foreach scope,$(SUPPLIER_SCOPE),\
		if [ ! -d "$(CONFIGURATION_$(scope)_RUN_PATH)" ] || [ ! -d "$(TESTS_$(scope)_RUN_PATH)" ]; then \
			echo "cawk $(CONFIGURATION_$(scope)_RUN_PATH) or $(TESTS_$(scope)_RUN_PATH) do not exist, skip the ${audit} $(scope) assessment ----"; \
		else \
			echo "cawk compute ${audit} $(scope) devices ----" ;\
			touch $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap ;\
			find $(CONFIGURATION_$(scope)_RUN_PATH) $(FIND_CONF_SELECT) > $(TESTS_TMP)/conf_list_files.${audit}.$(scope) 2>/dev/null ;\
			find $(TESTS_$(scope)_RUN_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.${audit}.$(scope) 2>/dev/null ;\
			$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk \
			$(TESTS_TMP)/conf_list_files.${audit}.$(scope) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.${audit}.$(scope) > \
			$(TESTS_TMP)/Makefile.${audit}.$(scope) ;\
			gmake -f $(TESTS_TMP)/Makefile.${audit}.$(scope) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap ;\
			egrep -v -f $(EXCEPTION_PATH)/run_${audit}//exceptions.$(scope) $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap | sort | uniq > $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv || true ;\
			cat $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv >> $(REPORT_PATH)/run_${audit}/assessment.all.full.csv ;\
			egrep -f $(EXCEPTION_PATH)/run_${audit}//exceptions.$(scope) $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap | sort | uniq > $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv || true ;\
			cat $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv >> $(REPORT_PATH)/run_${audit}/assessment.all.full.exceptions.csv ;\
			rm -f $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap ;\
			$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv > $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt ;\
			echo "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			echo "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			echo "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			gmake catalog_run audit=$(audit) | grep "tests/" | sort >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt;\
			$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run_${audit}/assessment.all.full.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt;\
			echo "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt;\
			echo "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt;\
			echo "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt;\
			gmake catalog_run audit=$(audit) | grep "tests/" | sort >> $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt;\
			egrep '(high|medium|low);error' $(REPORT_PATH)/run_${audit}/assessment.all.full.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.security.csv || true;\
			egrep '(info;error|;warning)' $(REPORT_PATH)/run_${audit}/assessment.all.full.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.audit.csv || true;\
		fi; \
	)
ifeq ($(strip $(JSON)),yes)
ifneq ($(wildcard $(CONFIGURATION_$(supplier)_RUN_PATH)/.),)
ifneq ($(wildcard $(TESTS_$(supplier)_RUN_PATH)/.),)
	echo "cawk json reporting performed ----"
	$(foreach scope,$(SUPPLIER_SCOPE),\
		if [ ! -d "$(CONFIGURATION_$(scope)_RUN_PATH)" ] || [ ! -d "$(TESTS_$(scope)_RUN_PATH)" ]; then \
			echo "cawk $(CONFIGURATION_$(scope)_RUN_PATH) or $(TESTS_$(scope)_RUN_PATH) do not exist, skip the ${audit} $(scope) json reporting ----"; \
		else \
			$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt > $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.json ;\
			$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv > $(REPORT_PATH)/run_${audit}/assessment.$(scope).json ;\
			$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv > $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.json ;\
		fi;	\
	)
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.full.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.full.security.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.full.exceptions.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.exceptions.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt > $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.json
endif
endif
else
	echo "cawk json reporting skipped ----"
endif
endif
endif
else
ifeq ($(strip $(MAKE_PARALLEL)),no)
ifeq ($(strip $(audit)),)
	echo "cawk compute $(supplier) devices ----"
	touch $(REPORT_PATH)/run/assessment.$(supplier).csv.swap
	$(foreach test,$(shell find  $(TESTS_$(supplier)_RUN_PATH) -name '*.gawk' -type f 2>/dev/null),\
		find $(CONFIGURATION_$(supplier)_RUN_PATH) $(FIND_CONF_SELECT) -exec ./$(test) {} \; >> $(REPORT_PATH)/run/assessment.$(supplier).csv.swap ;\
	)
	egrep -v -f $(EXCEPTION_PATH)/run/exceptions.$(supplier) $(REPORT_PATH)/run/assessment.$(supplier).csv.swap | sort | uniq > $(REPORT_PATH)/run/assessment.$(supplier).csv || true
	cat $(REPORT_PATH)/run/assessment.$(supplier).csv >> $(REPORT_PATH)/run/assessment.all.full.csv
	egrep -f $(EXCEPTION_PATH)/run/exceptions.$(supplier) $(REPORT_PATH)/run/assessment.$(supplier).csv.swap | sort | uniq > $(REPORT_PATH)/run/assessment.$(supplier).exceptions.csv || true
	cat $(REPORT_PATH)/run/assessment.$(supplier).exceptions.csv >> $(REPORT_PATH)/run/assessment.all.full.exceptions.csv
	rm -f $(REPORT_PATH)/run/assessment.$(supplier).csv.swap
	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run/assessment.$(supplier).csv > $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	echo "------------------------" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	echo "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	echo "------------------------" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	make catalog_run | egrep "tests/" | sort >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run/assessment.all.full.csv > $(REPORT_PATH)/run/assessment.all.full.summary.txt
	echo "------------------------" >> $(REPORT_PATH)/run/assessment.all.full.summary.txt
	echo "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.all.full.summary.txt
	echo "------------------------" >> $(REPORT_PATH)/run/assessment.all.full.summary.txt
	gmake catalog_repo | egrep "tests/" | sort >> $(REPORT_PATH)/run/assessment.all.full.summary.txt
	egrep '(high|medium|low);error' $(REPORT_PATH)/run/assessment.all.full.csv > $(REPORT_PATH)/run/assessment.all.full.security.csv || true
	egrep '(info;error|;warning)' $(REPORT_PATH)/run/assessment.all.full.csv > $(REPORT_PATH)/run/assessment.all.full.audit.csv || true
ifeq ($(strip $(JSON)),yes)
	echo "cawk json reporting performed ----"
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run/assessment.$(scope).summary.txt > $(REPORT_PATH)/run/assessment.$(scope).summary.json ;\
		$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.$(scope).csv > $(REPORT_PATH)/run/assessment.$(scope).json ;\
		$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv > $(REPORT_PATH)/run/assessment.$(scope).exceptions.json ;\
	)
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.full.csv > $(REPORT_PATH)/run/assessment.all.full.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.full.security.csv > $(REPORT_PATH)/run/assessment.all.full.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.full.exceptions.csv > $(REPORT_PATH)/run/assessment.all.full.exceptions.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run/assessment.all.full.summary.txt > $(REPORT_PATH)/run/assessment.all.full.summary.json
else
	echo "cawk json reporting skipped ----"
endif
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	echo "cawk error audit=${audit} do not exist  ----"
	exit 0
endif
	echo "cawk compute ${audit} $(supplier) devices ----"
	touch $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap
	if [ ! -d "$(CONFIGURATION_$(supplier)_RUN_PATH)" ] || [ ! -d "$(TESTS_$(supplier)_RUN_PATH)" ]; then \
		echo "cawk $(CONFIGURATION_$(supplier)_RUN_PATH) or $(TESTS_$(supplier)_RUN_PATH) do not exist, skip the ${audit} $(supplier) assessment ----"; \
	else \
		$(foreach test,$(shell find  $(TESTS_$(supplier)_RUN_PATH) -name '*.gawk' -type f 2>/dev/null),\
			find $(CONFIGURATION_$(supplier)_RUN_PATH) $(FIND_CONF_SELECT) -exec ./$(test) {} \; >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap ;\
		) \
		egrep -v -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(supplier) $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap | sort | uniq > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv || true;\
		cat $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv >> $(REPORT_PATH)/run_${audit}/assessment.all.full.csv;\
		egrep -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(supplier) $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap | sort | uniq > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).exceptions.csv || true;\
		cat $(REPORT_PATH)/run_${audit}/assessment.$(supplier).exceptions.csv >> $(REPORT_PATH)/run_${audit}/assessment.all.full.exceptions.csv;\
		rm -f $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap;\
		$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		echo "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		echo "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		echo "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		gmake catalog_run audit=$(audit) | grep "tests/" | sort >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run_${audit}/assessment.all.full.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt;\
		echo "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt;\
		echo "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt;\
		echo "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt;\
		gmake catalog_run audit=$(audit) | grep "tests/" | sort >> $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt;\
		egrep '(high|medium|low);error' $(REPORT_PATH)/run_${audit}/assessment.all.full.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.security.csv || true;\
		egrep '(info;error|;warning)' $(REPORT_PATH)/run_${audit}/assessment.all.full.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.audit.csv || true;\
	fi
ifeq ($(strip $(JSON)),yes)
ifneq ($(wildcard $(CONFIGURATION_$(supplier)_RUN_PATH)/.),)
ifneq ($(wildcard $(TESTS_$(supplier)_RUN_PATH)/.),)
	echo "cawk json reporting performed @$(wildcard $(CONFIGURATION_$(supplier)_RUN_PATH)/.)@ ----"
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.$(supplier).exceptions.csv > $(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.full.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.full.security.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.full.exceptions.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.exceptions.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt > $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.json
endif
endif
else
	echo "cawk json reporting skipped ----"
endif
endif
else
ifeq ($(strip $(audit)),)
	echo "cawk compute $(supplier) devices ----"
	touch $(REPORT_PATH)/run/assessment.$(supplier).csv.swap
	find $(CONFIGURATION_$(supplier)_RUN_PATH) $(FIND_CONF_SELECT) > $(TESTS_TMP)/conf_list_files.run.$(supplier) 2>/dev/null
	find $(TESTS_$(supplier)_RUN_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.run.$(supplier) 2>/dev/null
	$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk $(TESTS_TMP)/conf_list_files.run.$(supplier) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.run.$(supplier) > \
	$(TESTS_TMP)/Makefile.run.$(supplier)
	gmake -f $(TESTS_TMP)/Makefile.run.$(supplier) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(REPORT_PATH)/run/assessment.$(supplier).csv.swap
	egrep -v -f $(EXCEPTION_PATH)/run/exceptions.$(supplier) $(REPORT_PATH)/run/assessment.$(supplier).csv.swap | sort | uniq > $(REPORT_PATH)/run/assessment.$(supplier).csv || true
	cat $(REPORT_PATH)/run/assessment.$(supplier).csv >> $(REPORT_PATH)/run/assessment.all.full.csv
	egrep -f $(EXCEPTION_PATH)/run/exceptions.$(supplier) $(REPORT_PATH)/run/assessment.$(supplier).csv.swap | sort | uniq > $(REPORT_PATH)/run/assessment.$(supplier).exceptions.csv || true
	cat $(REPORT_PATH)/run/assessment.$(supplier).exceptions.csv >> $(REPORT_PATH)/run/assessment.all.full.exceptions.csv
	rm -f $(REPORT_PATH)/run/assessment.$(supplier).csv.swap
	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run/assessment.$(supplier).csv > $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	echo "------------------------" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	echo "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	echo "------------------------" >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	make catalog_run | egrep "tests/" | sort >> $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
	$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run/assessment.all.full.csv > $(REPORT_PATH)/run/assessment.all.full.summary.txt
	echo "------------------------" >> $(REPORT_PATH)/run/assessment.all.full.summary.txt
	echo "---- tests purposes ----" >> $(REPORT_PATH)/run/assessment.all.full.summary.txt
	echo "------------------------" >> $(REPORT_PATH)/run/assessment.all.full.summary.txt
	gmake catalog_repo | egrep "tests/" | sort >> $(REPORT_PATH)/run/assessment.all.full.summary.txt
	egrep '(high|medium|low);error' $(REPORT_PATH)/run/assessment.all.full.csv > $(REPORT_PATH)/run/assessment.all.full.security.csv || true
	egrep '(info;error|;warning)' $(REPORT_PATH)/run/assessment.all.full.csv > $(REPORT_PATH)/run/assessment.all.full.audit.csv || true
ifeq ($(strip $(JSON)),yes)
	echo "cawk json reporting performed ----"
	$(foreach scope,$(SUPPLIER_SCOPE),\
		$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run/assessment.$(scope).summary.txt > $(REPORT_PATH)/run/assessment.$(scope).summary.json ;\
		$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.$(scope).csv > $(REPORT_PATH)/run/assessment.$(scope).json ;\
		$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.$(scope).exceptions.csv > $(REPORT_PATH)/run/assessment.$(scope).exceptions.json ;\
	)
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.full.csv > $(REPORT_PATH)/run/assessment.all.full.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.full.security.csv > $(REPORT_PATH)/run/assessment.all.full.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run/assessment.all.full.exceptions.csv > $(REPORT_PATH)/run/assessment.all.full.exceptions.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run/assessment.all.full.summary.txt > $(REPORT_PATH)/run/assessment.all.full.summary.json
else
	echo "cawk json reporting skipped ----"
endif
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	echo "cawk error audit=${audit} do not exist  ----"
	exit 0
endif
	echo "cawk compute ${audit} $(supplier) devices ----"
	if [ ! -d "$(CONFIGURATION_$(supplier)_RUN_PATH)" ] || [ ! -d "$(TESTS_$(supplier)_RUN_PATH)" ]; then \
		echo "cawk $(CONFIGURATION_$(supplier)_RUN_PATH) or $(TESTS_$(supplier)_RUN_PATH) do not exist, skip the ${audit} $(supplier) assessment ----"; \
	else \
		touch $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap; \
		find $(CONFIGURATION_$(supplier)_RUN_PATH) $(FIND_CONF_SELECT) > $(TESTS_TMP)/conf_list_files.${audit}.$(supplier) 2>/dev/null; \
		find $(TESTS_$(supplier)_RUN_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.${audit}.$(supplier) 2>/dev/null; \
		$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk \
		$(TESTS_TMP)/conf_list_files.${audit}.$(supplier) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.${audit}.$(supplier) > \
		$(TESTS_TMP)/Makefile.${audit}.$(supplier); \
		gmake -f $(TESTS_TMP)/Makefile.${audit}.$(supplier) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap; \
		egrep -v -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(supplier) $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap | sort | uniq > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv || true; \
		cat $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv >> $(REPORT_PATH)/run_${audit}/assessment.all.full.csv; \
		egrep -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(supplier) $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap | sort | uniq > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).exceptions.csv || true; \
		cat $(REPORT_PATH)/run_${audit}/assessment.$(supplier).exceptions.csv >> $(REPORT_PATH)/run_${audit}/assessment.all.full.exceptions.csv; \
		rm -f $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap; \
		$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt; \
		echo "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		echo "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		echo "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		gmake catalog_run audit=$(audit) | grep "tests/" | sort >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt;\
		$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run_${audit}/assessment.all.full.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt;\
		echo "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt;\
		echo "---- tests purposes ----" >> $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt;\
		echo "------------------------" >> $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt;\
		gmake catalog_run audit=$(audit) | grep "tests/" | sort >> $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt;\
		egrep '(high|medium|low);error' $(REPORT_PATH)/run_${audit}/assessment.all.full.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.security.csv || true;\
		egrep '(info;error|;warning)' $(REPORT_PATH)/run_${audit}/assessment.all.full.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.audit.csv || true;\
	fi 
ifeq ($(strip $(JSON)),yes)
ifneq ($(wildcard $(CONFIGURATION_$(supplier)_RUN_PATH)/.),)
ifneq ($(wildcard $(TESTS_$(supplier)_RUN_PATH)/.),)
	echo "cawk json reporting performed ----"
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.$(supplier).exceptions.csv > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).exceptions.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.full.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.full.security.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.security.json
	$(TESTS_COMMON_PATH)/report_json.gawk $(REPORT_PATH)/run_${audit}/assessment.all.full.exceptions.csv > $(REPORT_PATH)/run_${audit}/assessment.all.full.exceptions.json
	$(TESTS_COMMON_PATH)/report_sumjson.gawk $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.txt > $(REPORT_PATH)/run_${audit}/assessment.all.full.summary.json
endif
endif
else
	echo "cawk json reporting skipped ----"
endif
endif
endif
endif
ifeq ($(strip $(audit)),)
	gmake archive_run
else
	gmake archive_run audit=$(audit)
endif
	echo "cawk check_run done ----"


RUN_DIRS := $(shell find tests -name '*run_*' -type d | awk -F'run_' '{print $$NF}' | sort | uniq)
check_run_audit:
	@for dir in $(RUN_DIRS); do \
		gmake check_run audit=$$dir; \
	done
	echo "cawk check_run_audit end ----"

# --------------------------------

view_repo: check_supplier
ifeq ($(strip $(supplier)),)
	$(foreach test,$(SUPPLIER_SCOPE),\
		echo "------------------------------------" ;\
		echo "---- Assessment $(test) devices" ;\
		echo "------------------------------------" ;\
		cat $(REPORT_PATH)/repo/assessment.$(test).csv ;\
		echo "-------------------------" ;\
		echo "---- Summary $(test)" ;\
		echo "-------------------------" ;\
		cat $(REPORT_PATH)/repo/assessment.$(test).summary.txt ;\
	)
else
	echo "------------------------------------"
	echo "---- Assessment ${audit} $(supplier) devices"
	echo "------------------------------------"
	cat $(REPORT_PATH)/repo/assessment.$(supplier).csv
	echo "------------------------------"
	echo " ---- Summary ${audit} $(supplier)"
	echo "------------------------------"
	cat $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
endif
	echo "cawk view_repo done ----"

view_run: check_supplier
ifeq ($(strip $(supplier)),)
ifeq ($(strip $(audit)),)
	$(foreach test,$(SUPPLIER_SCOPE),\
		echo "------------------------------------" ;\
		echo "---- Assessment $(test) devices" ;\
		echo "------------------------------------" ;\
		if [ -f $(REPORT_PATH)/run/assessment.$(test).csv ]; then \
			cat $(REPORT_PATH)/run/assessment.$(test).csv; \
		fi; \
		echo "-------------------------" ;\
		echo "---- Summary $(test)" ;\
		echo "-------------------------" ;\
		if [ -f $(REPORT_PATH)/run/assessment.$(test).summary.txt ]; then \
			cat $(REPORT_PATH)/run/assessment.$(test).summary.txt; \
		fi; \
	)
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	echo "cawk error audit=${audit} do not exist  ----"
	exit 0
endif
	$(foreach test,$(SUPPLIER_SCOPE),\
		echo "------------------------------------" ;\
		echo "---- Assessment ${audit} $(test) devices" ;\
		echo "------------------------------------" ;\
		if [ -f $(REPORT_PATH)/run_${audit}/assessment.$(test).csv ]; then \
			cat $(REPORT_PATH)/run_${audit}/assessment.$(test).csv ;\
		fi ;\
		echo "---------------------------------" ;\
		echo "---- Summary ${audit} $(test)" ;\
		echo "---------------------------------" ;\
		if [ -f $(REPORT_PATH)/run_${audit}/assessment.$(test).summary.txt ]; then \
			cat $(REPORT_PATH)/run_${audit}/assessment.$(test).summary.txt ;\
		fi ;\
	)
endif
else
ifeq ($(strip $(audit)),)
	echo "--------------------------------------"
	echo "---- Assessment $(supplier) devices"
	echo "--------------------------------------"
	if [ -f $(REPORT_PATH)/run/assessment.$(supplier).csv ]; then \
		cat $(REPORT_PATH)/run/assessment.$(supplier).csv; \
	fi
	echo "------------------------------"
	echo " ---- Summary $(supplier)"
	echo "------------------------------"
	if [ -f $(REPORT_PATH)/run/assessment.$(supplier).summary.txt ]; then \
		cat $(REPORT_PATH)/run/assessment.$(supplier).summary.txt; \
	fi
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	echo "cawk error audit=${audit} do not exist  ----"
	exit 0
endif
	echo "-----------------------------------------------"
	echo "---- Assessment ${audit} $(supplier) devices"
	echo "-----------------------------------------------"
	if [ -f $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv ]; then \
		cat $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv; \
	fi
	echo "-------------------------------------"
	echo " ---- Summary ${audit} $(supplier)"
	echo "-------------------------------------"
	if [ -f $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt ]; then \
		cat $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt; \
	fi
endif
endif
	echo "cawk view_run done ----"

view_repo_error: check_supplier
ifeq ($(strip $(supplier)),)
	$(foreach test,$(SUPPLIER_SCOPE),\
		if [ -f $(REPORT_PATH)/repo/assessment.$(test).csv ]; then \
			cat $(REPORT_PATH)/repo/assessment.$(test).csv | grep ";error" | sort | uniq; \
		fi ;\
	)
else
	if [ -f $(REPORT_PATH)/repo/assessment.$(supplier).csv ]; then \
		cat $(REPORT_PATH)/repo/assessment.$(supplier).csv | grep ";error" | sort | uniq; \
	fi
endif
	echo "cawk view_repo_error done ----"

view_run_error: check_supplier
ifeq ($(strip $(audit)),)
ifeq ($(strip $(supplier)),)
	$(foreach test,$(SUPPLIER_SCOPE),\
		if [ -f $(REPORT_PATH)/run/assessment.$(test).csv ]; then \
			cat $(REPORT_PATH)/run/assessment.$(test).csv | grep ";error" | sort | uniq; \
		fi ;\
	)
else
	if [ -f $(REPORT_PATH)/run/assessment.$(supplier).csv ]; then \
		cat $(REPORT_PATH)/run/assessment.$(supplier).csv | grep ";error" | sort | uniq; \
	fi
endif
else
ifeq ($(strip $(supplier)),)
	$(foreach test,$(SUPPLIER_SCOPE),\
		if [ -f $(REPORT_PATH)/run_${audit}/assessment.$(test).csv ]; then \
			cat $(REPORT_PATH)/run_${audit}/assessment.$(test).csv | grep ";error" | sort | uniq; \
		fi ;\
	)
else
	if [ -f $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv ]; then \
		cat $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv | grep ";error" | sort | uniq; \
	fi
endif
endif
	echo "cawk view_run_error done ----"

# --------------------------------

archive_repo:
	if [ -n "$$(find reports/repo -name '*.csv' -o -name '*.txt')" ]; then \
		tar -czf reports/run/archives/repo_$(shell date +%Y-%m-%d).tar.gz $$(find reports/repo -name '*.csv' -o -name '*.txt') || true ;\
		echo "cawk build archive in reports/repo/archives/repo_$(shell date +%Y-%m-%d).tar.gz"; \
	else \
		echo "cawk no files *.csv and *.txt found in reports/repo, skip the archive ----" ;\
	fi	
	echo "cawk archive_repo done ----"

archive_run:
ifeq ($(strip $(audit)),)
	@if [ -n "$$(find reports/run -name '*.csv' -o -name '*.txt')" ]; then \
		tar -czf reports/run/archives/run_$(shell date +%Y-%m-%d).tar.gz $$(find reports/run -name '*.csv' -o -name '*.txt') || true ;\
		echo "cawk build archive in reports/run/archives/run_$(shell date +%Y-%m-%d).tar.gz"; \
	else \
		echo "cawk no files *.csv and *.txt found in reports/run, skip the archive ----"; \
	fi	
else
	@if [ -n "$$(find reports/run_${audit} -name '*.csv' -o -name '*.txt')" ]; then \
		tar -czf reports/run_${audit}/archives/run_${audit}_$(shell date +%Y-%m-%d).tar.gz $$(find reports/run_${audit} -name '*.csv' -o -name '*.txt') || true ;\
		echo "cawk build archive in reports/run_${audit}/archives/run_${audit}_$(shell date +%Y-%m-%d).tar.gz"; \
	else \
		echo "cawk no files *.csv and *.txt found in reports/run_${audit}, skip the archive ----"; \
	fi	
endif
	echo "cawk archive_run done ----"

# --------------------------------

clean: clean_tmp
	rm -f $(TESTS_COMMON_PATH)/*.gawk || true
	rm -f $(TESTS_COMMON_PATH)/*.script || true
	rm -f $(DATABASE_PATH_SH)/*.script || true
	$(foreach scope,$(SUPPLIER_SCOPE),\
		rm -f $(EXCEPTION_PATH)/*/*.$(scope) || true ;\
	)
	rm -f $(TESTS_PATH)/repo/*/*.gawk || true
	rm -f $(TESTS_PATH)/run/*/*.gawk || true
	rm -f $(TESTS_PATH)/run_*/*/*.gawk || true
	rm -f *.tar *.tar.gz || true
	find $(TESTS_COMMON_PATH) $(DATABASE_PATH_SH) $(EXCEPTION_PATH) $(TESTS_PATH)/repo $(TESTS_PATH)/run -type f -exec touch {} \; || true
	if [ -d "$(TESTS_PATH)/run_*" ]; then find $(TESTS_PATH)/run_* -type f -exec touch {} \; || true; fi
	echo "cawk clean done ----"

clean_backup:
	rm -f $(BACKUP_PATH)/*.tar $(BACKUP_PATH)/*.tar.gz 2>/dev/null || true
	echo "cawk clean $(BACKUP_PATH) done ----"

clean_report_repo:
	rm -f $(REPORT_PATH)/repo/* 2>/dev/null || true
	echo "cawk clean $(REPORT_PATH)/repo done ----"

clean_archive_repo:
	rm -f $(REPORT_PATH)/repo/archives/* 2>/dev/null || true
	echo "cawk clean $(REPORT_PATH)/repo/archives done ----"

clean_report_run:
ifeq ($(strip $(audit)),)
	rm -f $(REPORT_PATH)/run/* 2>/dev/null || true
	echo "cawk clean $(REPORT_PATH)/run done ----"
else
	rm -f $(REPORT_PATH)/run_${audit}/* 2>/dev/null || true
	echo "cawk clean $(REPORT_PATH)/run_${audit} done ----"
endif

clean_archive_run:
ifeq ($(strip $(audit)),)
	rm -f $(REPORT_PATH)/run/archives/* 2>/dev/null || true
	echo "cawk clean $(REPORT_PATH)/run/archives done ----"
else
	rm -f $(REPORT_PATH)/run_${audit}/archives/* 2>/dev/null || true
	echo "cawk clean $(REPORT_PATH)/run_${audit}/archives done ----"
endif

RUN_DIRS := $(shell find tests -name '*run_*' -type d | awk -F'run_' '{print $$NF}' | sort | uniq)
clean_report_run_audit:
	@for dir in $(RUN_DIRS); do \
		gmake clean_report_run audit=$$dir; \
	done

RUN_DIRS := $(shell find tests -name '*run_*' -type d | awk -F'run_' '{print $$NF}' | sort | uniq)
clean_archive_run_audit:
	@for dir in $(RUN_DIRS); do \
		gmake clean_archive_run audit=$$dir; \
	done

clean_tmp:
	rm -f $(TESTS_TMP)/tmp* || true
	rm -f $(TESTS_TMP)/conf_* || true
	rm -f $(TESTS_TMP)/Makefile* || true
	echo "cawk clean tmp done ----"

clean_force:
	gmake clean clean_report_repo clean_backup clean_report_run clean_report_run_audit clean_archive_repo clean_archive_run clean_archive_run_audit
	echo "cawk clean_force done ----"

# --------------------------------

catalog_repo:
	$(foreach dir,$(wildcard tests/repo),\
		echo "------------------------------";\
		echo "---- Tests <repo> catalog ----";\
		echo "------------------------------";\
		for file in $(wildcard $(dir)/*/*.m4) $(wildcard $(dir)/*/*.template); do \
			grep -H purpose $$file | sed -e 's/# purpose ://g' -e 's/tests\/tests\.//g' || true;\
		done;\
	)
	echo "cawk catalog_repo done ----"

catalog_run:
ifeq ($(strip $(audit)),)
	$(foreach dir,$(wildcard tests/run),\
		echo "-----------------------------";\
		echo "---- Tests <run> catalog ----";\
		echo "-----------------------------";\
		for file in $(wildcard $(dir)/*/*.m4) $(wildcard $(dir)/*/*.template); do \
			grep -H purpose $$file | sed -e 's/# purpose ://g' -e 's/tests\/tests\.//g' || true;\
		done;\
	)
	echo "cawk catalog_run done ----"
else
	$(foreach dir,$(wildcard tests/run_$(audit)),\
		echo "--------------------------------------------";\
		echo "---- Tests <run_$(audit)> catalog ----";\
		echo "--------------------------------------------";\
		for file in $(wildcard $(dir)/*/*.m4) $(wildcard $(dir)/*/*.template); do \
			grep -H purpose $$file | sed -e 's/# purpose ://g' -e 's/tests\/tests\.//g' || true;\
		done;\
	)
	echo "cawk catalog_run $(audit) done ----"
endif

# --------------------------------

gitcheckdist:
	echo "---- to be done : check databases"
	rm $(DATABASE_PATH)/db_email.txt
	rm $(DATABASE_PATH)/db_postaudit.txt
	rm $(DATABASE_PATH)/db_sync.txt
	touch $(DATABASE_PATH)/db_email.txt 
	touch $(DATABASE_PATH)/db_postaudit.txt
	touch $(DATABASE_PATH)/db_sync.txt
	echo "---- to be done : check remaining debug code"
	grep DEBUG tests/*/*/* || true
	echo "---- done : call system check"
	chmod 750 system/cawk_check_system
	gmake system
	echo "---- done : call system check"
	gmake supplier
	echo "---- to be done : Update ChangeLog"
	echo "---- to be done : Check no customer assessments"
	gmake list_audit
	echo "---- to be done : Update Authors"
	echo "---- done : no *.gawk must be there"
	find . -name *.gawk
	echo "---- done clean DS store file ----"
	find . -name .DS_Store | xargs rm -f
	echo "---- done clean vscode param ----"
	rm -r -f .vscode
	echo "---- done clean orig file ----"
	find . -name *.orig | xargs rm -f
	echo "---- done : Update run repository confs && tests && exceptions from repo"
	rm -r confs/run && cp -r confs/repo confs/run
	rm -r tests/run && cp -r tests/repo tests/run
	rm -r exceptions/run && cp -r exceptions/repo exceptions/run
	echo "---- done : touch ./gitkeep for reports/repo reports/run"
	touch reports/repo/.gitkeep && touch reports/run/.gitkeep && touch tmp/.gitkeep
	touch reports/repo/archives/.gitkeep && touch reports/run/archives/.gitkeep
	echo "---- to be done : Update Makefile.support.mk with CAWK_RELEASE = $(CAWK_RELEASE)"
	echo "---- done : Check .gitkeep in directories"
	find . -name .gitkeep
	echo "---- to be done : Update checkdiff"
	echo "Update checkdiff"
	echo "gmake check_update && gmake check"

git:
	# gmake gitcheckdist
	# git add .
	# git commit -m "*$(CAWK_RELEASE) ref ChangeLog"

gitpush:
	# git push https://github.com/cedricllorens/cawk.git master

# --------------------------------

check:
	rm -f  checkdiff/checkdiff.new
	
	gmake check_repo 
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	gmake check_repo supplier=cisco-ios
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	gmake check_repo JSON=no MAKE_PARALLEL=no
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	gmake check_repo JSON=no MAKE_PARALLEL=yes
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	gmake check_repo JSON=yes MAKE_PARALLEL=yes
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	gmake check_repo JSON=yes MAKE_PARALLEL=no
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	gmake check_run
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	gmake check_run supplier=cisco-ios
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	gmake check_run JSON=no MAKE_PARALLEL=no
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	gmake check_run JSON=no MAKE_PARALLEL=yes
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	gmake check_run JSON=yes MAKE_PARALLEL=yes
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	gmake check_run JSON=yes MAKE_PARALLEL=no
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
	find backup -name '*.tar.gz' | wc -l >> checkdiff/checkdiff.new
	
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
	gmake check_run audit=client1_skffqsfqhsf10948494 JSON=no MAKE_PARALLEL=no
	gmake check_run audit=client1_skffqsfqhsf10948494 JSON=no MAKE_PARALLEL=yes
	gmake check_run audit=client1_skffqsfqhsf10948494 JSON=yes MAKE_PARALLEL=yes
	gmake check_run audit=client1_skffqsfqhsf10948494 JSON=yes MAKE_PARALLEL=no
	gmake check_run audit=client1_skffqsfqhsf10948494 JSON=no MAKE_PARALLEL=no supplier=cisco-ios
	gmake check_run audit=client1_skffqsfqhsf10948494 JSON=no MAKE_PARALLEL=yes supplier=cisco-ios
	gmake check_run audit=client1_skffqsfqhsf10948494 JSON=yes MAKE_PARALLEL=yes supplier=cisco-ios
	gmake check_run audit=client1_skffqsfqhsf10948494 JSON=yes MAKE_PARALLEL=no supplier=cisco-ios
	gmake delete_audit audit=client1_skffqsfqhsf10948494
	gmake clean_force

	echo "------------------------------------------------------"
	echo "------------------------------------------------------"
	echo "CHECK MUST BE OK -------------------------------------"
	echo "------------------------------------------------------"
	@diff checkdiff/checkdiff.new checkdiff/checkdiff.old >/dev/null && echo OK || echo NOK
	echo "------------------------------------------------------"
	echo "CHECK MUST BE OK -------------------------------------"
	echo "------------------------------------------------------"
	echo "------------------------------------------------------"
	echo "cawk check done ----"

check_parallel:
	gmake check MAKE_PARALLEL=yes

check_update:
	@cp checkdiff/checkdiff.new checkdiff/checkdiff.old
	echo "cawk check_update done ----"

