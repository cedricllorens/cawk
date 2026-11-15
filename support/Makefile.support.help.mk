# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

# HELP_SECTIONS and HELP_POS: support/Makefile.support.vars.mk

.PHONY: \
  help version help_all help_logo help_list $(addprefix help_,$(HELP_SECTIONS))

ifneq ($(filter help,$(MAKECMDGOALS)),)
.PHONY: $(HELP_SECTIONS) all
$(HELP_SECTIONS) all: ; @:
endif

# gmake help [section] : the sections; gmake help topic=WORD : every help line holding WORD (a positional word could be a real target, the topic= form never builds anything)
help:
	@set -- $(HELP_POS); pos=$$#; \
	if [ $$pos -gt 1 ] || { [ $$pos -eq 1 ] && [ -n "$(strip $(topic))" ]; }; then $(ECHO) "cawk error: one help section at a time, got <$(HELP_POS) $(topic)> (usage: $(GMAKE) help [section], sections: $(HELP_SECTIONS)) ----"; exit 1; fi; \
	[ $$pos -eq 1 ] || set -- $(topic); \
	if [ $$# -gt 1 ]; then $(ECHO) "cawk error: one help topic at a time, got <$(topic)> (usage: $(GMAKE) help topic=WORD) ----"; exit 1; fi; \
	if [ $$# -eq 0 ]; then $(GMAKE) --no-print-directory help_list; \
	elif [ "$$1" = "all" ]; then $(GMAKE) --no-print-directory help_all; \
	else \
		case " $(HELP_SECTIONS) " in \
			*" $$1 "*) $(GMAKE) --no-print-directory help_$$1 ;; \
			*) if [ $$pos -eq 1 ]; then \
				$(ECHO) "cawk error: unknown help section <$$1>$$([ "$$1" = check ] && echo " (the section of the check targets is checks)") (usage: $(GMAKE) help [section], sections: $(HELP_SECTIONS) all, search a word with: $(GMAKE) help topic=$$1) ----"; exit 1; \
			fi; \
			found=$$($(GMAKE) --no-print-directory help_all HELP_NOLOGO=yes 2>&1 | grep '^# ' | grep -iF -- "$$1") || true; \
			if [ -z "$$found" ]; then $(ECHO) "cawk error: no help line holds <$$1> (list the sections with: $(GMAKE) help) ----"; exit 1; fi; \
			printf '%s\n' "$$found"; \
			$(ECHO) "cawk help topic=$$1 done ----" ;; \
		esac; \
	fi

# the logo heads every help page (HELP_NOLOGO=yes: help all prints it once)
help_logo:
ifneq ($(HELP_NOLOGO),yes)
	$(ECHO) ""
	$(ECHO) ""
	$(ECHO) ""
	$(ECHO) "  ###    ###   #   #  #   #"
	$(ECHO) " #      #   #  #   #  #  # "
	$(ECHO) " #      #####  # # #  ###  "
	$(ECHO) " #      #   #  ## ##  #  # "
	$(ECHO) "  ###   #   #  #   #  #   #"
	$(ECHO) "  network configuration compliance checker and censor ($(CAWK_RELEASE))"
	$(ECHO) ""
	$(ECHO) ""
	$(ECHO) ""
endif

help_list:
	@$(GMAKE) --no-print-directory help_logo
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# $(GMAKE) help <section> : print the targets of one section (the section of the check targets is <checks>)"
	$(ECHO) "# $(GMAKE) help all : print every section"
	$(ECHO) "# $(GMAKE) help topic=WORD : print every help line holding WORD (a target, an option, ...)"
	$(ECHO) "# $(GMAKE) check_run audit=AUDIT_NAME DATA_SET=no : skip the automatic data_set update (default yes: check_run audit= feeds the data_set and the html evolution section)"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# info        : conventions (repo, run, run_AUDIT_NAME), several targets in one call"
	$(ECHO) "# main        : version, check, system, supplier, clean, archive, logs, backups"
	$(ECHO) "# assessment  : create, delete and list the named audits, status"
	$(ECHO) "# sync        : synchronize the configurations of an audit"
	$(ECHO) "# collect     : optional config collectors (scp, rsync, local)"
	$(ECHO) "# tests       : build, copy and check the tests"
	$(ECHO) "# exceptions  : build and copy the exception rules"
	$(ECHO) "# checks      : run the assessments (check_repo, check_run, check_parallel, ...)"
	$(ECHO) "# view        : view the reports and the errors"
	$(ECHO) "# email       : email notification of an audit"
	$(ECHO) "# postaudit   : post-audit commands"
	$(ECHO) "# backup      : backup, restore, migrate, update_custom_run"
	$(ECHO) "# database    : manage the cawk databases (sync, email, postaudit, collect, scripts, information, exceptions)"
	$(ECHO) "# catalog     : test catalog and NIST mapping"
	$(ECHO) "# roles       : roles and permissions"
	$(ECHO) "# git         : release workflow"
	$(ECHO) "# censor      : censor the configurations, the logs and the reports"
	$(ECHO) "# vars        : every variable of support/Makefile.support.vars.mk, explained"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# tab completion (bash): targets, audit=AUDIT_NAME, supplier=SUPPLIER and options (FORCE, HTML, JSON, PSIRT_ONLY, MAKE_PARALLEL, STANDARD_ONLY, VERBOSE)"
	$(ECHO) "#   source support/cawk-completion.bash               : enable it in the current shell (from the cawk root directory)"
	$(ECHO) "#   ~/.bashrc (to keep it everywhere)                 : export CAWK_HOME=/home/cedric/Documents/cawk"
	$(ECHO) "#                                                       source \"\$$CAWK_HOME/support/cawk-completion.bash\""
	$(ECHO) "#   $(GMAKE) <TAB><TAB>                                  : list the targets, then audit=<TAB> lists the audits (from the cawk root directory)"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# quick start (details: QUICK.md):"
	$(ECHO) "#   $(GMAKE) create_audit audit=client1                  : create the audit (once)"
	$(ECHO) "#   $(GMAKE) sync_run audit=client1                      : bring the configurations of the audit"
	$(ECHO) "#   $(GMAKE) clean check_run view_run audit=client1      : assess and read the report"
	$(ECHO) "#   $(GMAKE) censor_report_run audit=client1             : censor the report before sharing it"
	$(ECHO) "#   $(GMAKE) status audit=client1                        : show where the audit stands and the next command (status alone: every audit)"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"

help_all:
	@$(GMAKE) --no-print-directory help_logo
	@for s in $(HELP_SECTIONS); do $(GMAKE) --no-print-directory help_$$s HELP_NOLOGO=yes || exit 1; done

help_info:
	@$(GMAKE) --no-print-directory help_logo
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK INFO --------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# NOTE : %SED_GAWK_PATH% is the gawk path, replaced by <!/usr/bin/env -S gawk -f> (see support/tests.sed)"
	$(ECHO) "# NOTE : Makefile.support.vars.mk holds every variable of cawk, the options change the behavior of cawk ($(GMAKE) help vars explains them)"
	$(ECHO) "# NOTE : several targets can be given in one $(GMAKE) call, e.g. $(GMAKE) clean check_repo view_repo"
	$(ECHO) "# NOTE : <repo> is the cawk repository of the shipped tests, test confs and exceptions"
	$(ECHO) "# NOTE : <run> is the default working copy of <repo>, for your own tests and checks"
	$(ECHO) "# NOTE : <run_AUDIT_NAME> is the repository of a named audit (one per context or customer)"
	$(ECHO) "# NOTE : $(GMAKE) help topic=WORD prints every help line holding WORD (a target, an option, ...)"
	$(ECHO) "# NOTE : tab completion of the targets, audit= and supplier= in bash: source support/cawk-completion.bash (~/.bashrc: export CAWK_HOME=<cawk root>, source \"\$$CAWK_HOME/support/cawk-completion.bash\")"
	$(ECHO) "# NOTE : after a cawk update, $(GMAKE) update_custom_run FORCE=yes runs your own changes (see $(GMAKE) help backup)"
	$(ECHO) "# NOTE : refer to the README file for further information"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"

help_main:
	@$(GMAKE) --no-print-directory help_logo
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK MAIN --------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# $(GMAKE) version : print the cawk release"
	$(ECHO) "# $(GMAKE) : print the help sections (same as $(GMAKE) help)"
	$(ECHO) "# $(GMAKE) check : run the cawk integrity check (the result must be OK after the installation)"
	$(ECHO) "# $(GMAKE) system : check that the system can run cawk"
	$(ECHO) "# $(GMAKE) supplier : list the suppliers supported by cawk"
	$(ECHO) "# $(GMAKE) common : list the functions of the common dir"
	$(ECHO) "# $(GMAKE) clean : remove the compiled tests and the content of the tmp dir"
	$(ECHO) "# $(GMAKE) clean_tmp : remove the temporary files of the tmp dir (tmp*, conf_*, Makefile*, *.swap)"
	$(ECHO) "# $(GMAKE) archive_repo / archive_run / archive_run audit=AUDIT_NAME : archive the current .csv/.txt reports into a dated .tar.gz (called automatically at the end of check_repo / check_run)"
	$(ECHO) "# $(GMAKE) archive_run_audit : archive the reports of every named audit"
	$(ECHO) "# $(GMAKE) clean_report_repo / clean_report_run / clean_report_run audit=AUDIT_NAME : remove the reports"
	$(ECHO) "# $(GMAKE) clean_report_run_audit : remove the reports of every named audit"
	$(ECHO) "# $(GMAKE) clean_archive_repo / clean_archive_run / clean_archive_run audit=AUDIT_NAME : remove the archives"
	$(ECHO) "# $(GMAKE) clean_archive_run_audit : remove the archives of every named audit"
	$(ECHO) "# $(GMAKE) clean_archive_older : remove the archives older than ARCHIVE_OLDER_DAYS (see Makefile.support.vars.mk)"
	$(ECHO) "# $(GMAKE) clean_archive_run audit=AUDIT_NAME ALL_ARCHIVE=yes FORCE=yes : remove every archive of the scope"
	$(ECHO) "# NOTE : clean_archive_* and clean_force remove only the archives older than ARCHIVE_OLDER_DAYS (>= 30, below it FORCE=yes is required)"
	$(ECHO) "# NOTE : check is refused while reports/*/archives hold archives (save and clean them first: check removes every archive, it only validates the cawk package and must not be used in production)"
	$(ECHO) "# $(GMAKE) clean_logs : remove all the logs, every scope (FORCE=yes required, not run by clean or clean_force)"
	$(ECHO) "# $(GMAKE) clean_logs_repo / clean_logs_run / clean_logs_run audit=AUDIT_NAME : remove the logs of one scope (FORCE=yes required)"
	$(ECHO) "# $(GMAKE) clean_logs_run_audit : remove the logs of every named audit (FORCE=yes required)"
	$(ECHO) "# $(GMAKE) clean_backup : remove all the backups"
	$(ECHO) "# $(GMAKE) clean_orig : remove all the backup files with the .orig suffix (FORCE=yes required)"
	$(ECHO) "# $(GMAKE) clean_orig_info : list the .orig backup files present in the repo"
	$(ECHO) "# $(GMAKE) clean_force : remove everything: reports, backups, archives and censored confs of every assessment (FORCE=yes required, USE WITH CAUTION)"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"

help_assessment:
	@$(GMAKE) --no-print-directory help_logo
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK ASSESSMENT --------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# $(GMAKE) create_audit audit=AUDIT_NAME : create the audit AUDIT_NAME (all suppliers)"
	$(ECHO) "# $(GMAKE) create_audit audit=AUDIT_NAME supplier=SUPPLIER : add SUPPLIER to the existing audit AUDIT_NAME"
	$(ECHO) "# $(GMAKE) delete_audit audit=AUDIT_NAME : delete the audit AUDIT_NAME (all suppliers)"
	$(ECHO) "# $(GMAKE) delete_audit audit=AUDIT_NAME supplier=SUPPLIER : remove SUPPLIER from the audit AUDIT_NAME"
	$(ECHO) "# $(GMAKE) list_audit : list the named audits (audit=AUDIT_NAME)"
	$(ECHO) "# $(GMAKE) status audit=AUDIT_NAME : show the confs by supplier, the tests, the last assessment, the exceptions, the censored files and the next command to run"
	$(ECHO) "# $(GMAKE) status : same for every named audit (one block per audit)"
	$(ECHO) "# $(GMAKE) check_run audit=AUDIT_NAME DATA_SET=no : skip the automatic data_set update (default yes: check_run audit= feeds the data_set and the html evolution section)"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"

help_sync:
	@$(GMAKE) --no-print-directory help_logo
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK SYNC --------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# NOTE : only available for named audits (audit=AUDIT_NAME)"
	$(ECHO) "# NOTE : relies on the cawk sync database (see README)"
	$(ECHO) "# CAUTION : the local confs files of confs/run_AUDIT_NAME are removed during the sync (see README)"
	$(ECHO) "# $(GMAKE) sync_run audit=AUDIT_NAME : build the inventory and sync the confs from a central repository to confs/run_AUDIT_NAME"
	$(ECHO) "# $(GMAKE) sync_run_audit : build the inventory and sync the confs from a central repository to every confs/run_AUDIT_NAME"
	$(ECHO) "# $(GMAKE) sync_psirt : build the psirt inventory used by the psirt tests"
	$(ECHO) "# $(GMAKE) sync_teststoconfs_run audit=AUDIT_NAME : sync the tests to the confs of AUDIT_NAME"
	$(ECHO) "# $(GMAKE) sync_teststoconfs_run_audit : sync the tests to the confs of every named audit"
	$(ECHO) "# $(GMAKE) sync_exceptionstoconfs_run audit=AUDIT_NAME : sync the exceptions to the confs of AUDIT_NAME"
	$(ECHO) "# $(GMAKE) sync_exceptionstoconfs_run_audit : sync the exceptions to the confs of every named audit"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"

help_collect:
	@$(GMAKE) --no-print-directory help_logo
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK COLLECT (optional config collectors: scp, rsync, local) -----------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# NOTE : collectors are external scripts (database/collectors), they only fill confs/collect_AUDIT_NAME (see README)"
	$(ECHO) "# NOTE : the sync_paths of the sync database must reference ../collect_AUDIT_NAME/ to sync the collected confs"
	$(ECHO) "# NOTE : the database_collect_* and database_view_collect targets are in $(GMAKE) help database"
	$(ECHO) "# $(GMAKE) collect_run audit=AUDIT_NAME : run the collector of AUDIT_NAME"
	$(ECHO) "# $(GMAKE) collect_run_audit : run the collectors of every named audit"
	$(ECHO) "# $(GMAKE) sync_run audit=AUDIT_NAME COLLECT=yes : collect, then sync"
	$(ECHO) "# $(GMAKE) check_collect : run the non-regression suite of the collectors (no network)"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"

help_tests:
	@$(GMAKE) --no-print-directory help_logo
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK TESTS -------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---- tests compile ----"
	$(ECHO) "# $(GMAKE) tests_common : build the tests of common"
	$(ECHO) "# $(GMAKE) tests_repo : build the tests of repo"
	$(ECHO) "# $(GMAKE) tests_run : build the tests of run"
	$(ECHO) "# $(GMAKE) tests_run audit=AUDIT_NAME : build the tests of run_AUDIT_NAME"
	$(ECHO) "# $(GMAKE) tests_run_audit : build the tests of every named audit"
	$(ECHO) "# $(GMAKE) tests_target_common / tests_target_repo / tests_target_run : build only the compiled files of common / repo / run (prerequisites of the other targets)"
	$(ECHO) "# ---- tests copy ----"
	$(ECHO) "# $(GMAKE) tests_run_copy audit=AUDIT_NAME : copy the tests from repo to run_AUDIT_NAME (overwrite)"
	$(ECHO) "# $(GMAKE) tests_run_audit_copy : copy the tests from repo to every named audit (overwrite)"
	$(ECHO) "# ---- tests check ----"
	$(ECHO) "# $(GMAKE) tests_check : check that the tests are cawk compliant (shows the passes and the cawk error: lines)"
	$(ECHO) "# $(GMAKE) tests_check_nok : check that the tests are cawk compliant (shows only the cawk error: lines)"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"

help_exceptions:
	@$(GMAKE) --no-print-directory help_logo
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK EXCEPTIONS --------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---- exceptions compile ----"
	$(ECHO) "# $(GMAKE) exceptions_repo : build the exceptions from the repo .m4 files (called automatically by check_repo)"
	$(ECHO) "# $(GMAKE) exceptions_run : build the exceptions from the run .m4 files (called automatically by check_run)"
	$(ECHO) "# $(GMAKE) exceptions_run audit=AUDIT_NAME : build the exceptions from the run_AUDIT_NAME .m4 files (called automatically by check_run audit=AUDIT_NAME)"
	$(ECHO) "# $(GMAKE) exceptions_run_audit : build the exceptions of every named audit"
	$(ECHO) "# ---- exceptions copy ----"
	$(ECHO) "# $(GMAKE) exceptions_run_copy audit=AUDIT_NAME : copy the exceptions from repo to run_AUDIT_NAME (no overwrite, existing files kept)"
	$(ECHO) "# $(GMAKE) exceptions_run_audit_copy : copy the exceptions from repo to every named audit (no overwrite)"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"

help_checks:
	@$(GMAKE) --no-print-directory help_logo
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK CHECK -------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# NOTE : options added to the $(GMAKE) call change the scope or the behavior of the assessment: PSIRT_ONLY=yes (psirt tests only), STANDARD_ONLY=yes (standard tests only, skip psirt), DEADBEEF=yes, SECRETSCAN=yes (censored csv reports), BADFORMAT=yes, CRLF=no, ... ($(GMAKE) help vars)"
	$(ECHO) "# $(GMAKE) check_repo : assess the repo confs with the repo tests (builds the tests when missing)"
	$(ECHO) "#  or $(GMAKE) check_repo supplier=cisco-ios (or juniper-junos, etc.)"
	$(ECHO) "# $(GMAKE) check_run : assess the run confs with the run tests (builds the tests when missing)"
	$(ECHO) "#  or $(GMAKE) check_run supplier=cisco-ios (or juniper-junos, etc.)"
	$(ECHO) "#  or $(GMAKE) check_run audit=AUDIT_NAME"
	$(ECHO) "#  or $(GMAKE) check_run supplier=cisco-ios audit=AUDIT_NAME (or juniper-junos, etc.)"
	$(ECHO) "# $(GMAKE) check_run_audit : run the assessment of every named audit"
	$(ECHO) "# $(GMAKE) check_supplier : validate supplier=, audit= and the options (yes/no, numbers), prerequisite of the check, view and censor targets"
	$(ECHO) "# $(GMAKE) check_deprecated_repo / check_deprecated_run : report the tests of repo / run using an obsolete function, and the obsolete files moved by a release (remove the pointed element)"
	$(ECHO) "# $(GMAKE) check_integrity : first control of check_repo / check_run, shows a cawk error: for an obsolete file of DEPRECATED_FILES or a censor rule problem (no exit 1), then goes on (remove the pointed element)"
	$(ECHO) "# $(GMAKE) check_deprecated_files : report the obsolete files listed in DEPRECATED_FILES (old:new pairs), remove the old file"
	$(ECHO) "# ---- cawk integrity check (see $(GMAKE) check) ----"
	$(ECHO) "# $(GMAKE) check_parallel : same as check with MAKE_PARALLEL=yes"
	$(ECHO) "# $(GMAKE) check_checkdiff : build the checkdiff scripts (prerequisite of the check_debug* and check_analyze targets)"
	$(ECHO) "# $(GMAKE) check_debug / check_parallel_debug : run the integrity check in debug mode (sequential / parallel)"
	$(ECHO) "# $(GMAKE) check_debug_log : run the integrity check and write checkdiff/checkdiff_log.txt"
	$(ECHO) "# $(GMAKE) check_analyze : analyze the differences of the last debug run into checkdiff/checkdiff_report.txt"
	$(ECHO) "# $(GMAKE) check_update : accept the current result as the new checkdiff reference, checkdiff.old (CAUTION)"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"

help_view:
	@$(GMAKE) --no-print-directory help_logo
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK VIEW --------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# $(GMAKE) view_repo : view the repo reports (reports/repo dir)"
	$(ECHO) "#  or $(GMAKE) view_repo supplier=cisco-ios (or juniper-junos, etc.)"
	$(ECHO) "# $(GMAKE) view_repo_error : view the errors of the repo assessment reports (reports/repo dir)"
	$(ECHO) "#  or $(GMAKE) view_repo_error supplier=cisco-ios (or juniper-junos, etc.)"
	$(ECHO) "# $(GMAKE) view_run : view the run reports (reports/run or reports/run_AUDIT_NAME dirs)"
	$(ECHO) "#  or $(GMAKE) view_run supplier=cisco-ios (or juniper-junos, etc.)"
	$(ECHO) "#  or $(GMAKE) view_run supplier=cisco-ios audit=AUDIT_NAME (or juniper-junos, etc.)"
	$(ECHO) "# $(GMAKE) view_run_error : view the errors of the run assessment reports (reports/run or reports/run_AUDIT_NAME dirs)"
	$(ECHO) "#  or $(GMAKE) view_run_error audit=AUDIT_NAME (reports/run_AUDIT_NAME dir)"
	$(ECHO) "#  or $(GMAKE) view_run_error supplier=cisco-ios audit=AUDIT_NAME (or juniper-junos, etc.)"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"

help_email:
	@$(GMAKE) --no-print-directory help_logo
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK EMAIL -------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# NOTE : only available for named audits (audit=AUDIT_NAME)"
	$(ECHO) "# $(GMAKE) email_send audit=AUDIT_NAME : send an email to the recipients of AUDIT_NAME in the email database"
	$(ECHO) "# $(GMAKE) email_send_audit : send an email to the recipients of every named audit in the email database"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"

help_postaudit:
	@$(GMAKE) --no-print-directory help_logo
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK POST AUDIT --------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# NOTE : only available for named audits (audit=AUDIT_NAME)"
	$(ECHO) "# $(GMAKE) postaudit_run audit=AUDIT_NAME : run database/scripts/database_postaudit.script for AUDIT_NAME (skipped when the script does not exist)"
	$(ECHO) "# $(GMAKE) postaudit_run_audit : run database/scripts/database_postaudit.script for every audit of the post audit database"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"

help_backup:
	@$(GMAKE) --no-print-directory help_logo
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK BACKUP, RESTORE AND UPDATE ----------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# NOTE : only available for named audits (audit=AUDIT_NAME)"
	$(ECHO) "# $(GMAKE) backup_run audit=AUDIT_NAME : save all the data of AUDIT_NAME in the backup dir"
	$(ECHO) "# $(GMAKE) restore_run audit=AUDIT_NAME file=BACKUP_PATH_FILE : restore all the data of AUDIT_NAME from BACKUP_PATH_FILE"
	$(ECHO) "# $(GMAKE) backup_run_audit : save the cawk database and all the data of every named audit in the backup dir"
	$(ECHO) "# $(GMAKE) restore_run_audit file=BACKUP_PATH_FILE : restore the database and all the data from BACKUP_PATH_FILE"
	$(ECHO) "# $(GMAKE) migrate file=BACKUP_PATH_FILE : run the targets needed to migrate to a new cawk version (see README)"
	$(ECHO) "# ---- after a cawk update ----"
	$(ECHO) "# NOTE : a cawk update replaces the system side (common/, support/, m4/) and never rewrites database/, so your own changes after an update (edits of database/ files, scripts, renames, ...) go in your own script"
	$(ECHO) "# $(GMAKE) update_custom_run FORCE=yes : run your own database/scripts/update_custom.script.sh after a cawk update or a migrate (global, no audit=)"
	$(ECHO) "#   - edit the script (empty by default, create it when missing): it is saved by backup_run and never overwritten by an update"
	$(ECHO) "#   - #!/bin/sh (POSIX), run from the cawk root directory, no argument, fail with cawk error: <message> ---- and exit 1"
	$(ECHO) "#   - missing script: cawk error, errors of the script: logs/update_custom.err"
	$(ECHO) "#   - never run by check, check_repo or check_run"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"

help_database:
	@$(GMAKE) --no-print-directory help_logo
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK DATABASE ----------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# NOTE : only available for named audits (audit=AUDIT_NAME)"
	$(ECHO) "# NOTE : database_view and database_view_* never fail on an incomplete line: a missing field is shown with its default value (default), a missing required field is shown (missing, required)"
	$(ECHO) "# $(GMAKE) database_view : view all the cawk databases"
	$(ECHO) "# ---- sync ----"
	$(ECHO) "# $(GMAKE) database_view_sync : view only the cawk sync database"
	$(ECHO) "# $(GMAKE) database_sync_(add,update) audit=AUDIT_NAME dir=SYNC_PATH regexinventory=REGEX_PATTERN/.* scope=SCOPE_FILE/none"
	$(ECHO) "#   regexos=REGEX_PATTERN/.* regexpathexclude=REGEX_PATTERN/none regexinventoryexclude=REGEX_PATTERN/none"
	$(ECHO) "#  add or update an entry of the cawk sync database, fields separated by spaces:"
	$(ECHO) "#   - field 1 : audit name"
	$(ECHO) "#   - field 2 : sync paths separated by commas (no space), like /conf/ or /conf/cawk/,/conf/cawk_2/"
	$(ECHO) "#   - field 3 : extended regex selecting the lines of the inventory file (field 4), like .* or .*switch.*"
	$(ECHO) "#               (only applied when field 4 is an actual scope file, ignored when scope=none)"
	$(ECHO) "#   - field 4 : file listing the devices of the scope, based on the internal inventory"
	$(ECHO) "#   - field 5 : extended regex selecting the os, like (cisco-ios|cisco-xe) or .*"
	$(ECHO) "#   - field 6 : extended regex excluding device paths or device names, like (_home|_earth) or none"
	$(ECHO) "#   - field 7 : extended regex excluding lines of the inventory file (field 4), same restriction as field 3"
	$(ECHO) "# $(GMAKE) database_sync_del audit=AUDIT_NAME : delete an entry of the cawk sync database"
	$(ECHO) "# ---- email ----"
	$(ECHO) "# $(GMAKE) database_view_email : view only the cawk email database"
	$(ECHO) "# $(GMAKE) database_email_(add,update) audit=AUDIT_NAME dst=EMAIL_LIST cc=EMAIL_LIST/none"
	$(ECHO) "#  add or update an entry of the cawk email database, fields separated by spaces:"
	$(ECHO) "#   - field 1 : audit name"
	$(ECHO) "#   - field 2 : dst list of emails separated by commas (no space), like email1,email2,email3"
	$(ECHO) "#   - field 3 : cc list of emails separated by commas (no space), like email1,email2,email3 or none"
	$(ECHO) "# $(GMAKE) database_email_del audit=AUDIT_NAME : delete an entry of the cawk email database"
	$(ECHO) "# ---- post audit ----"
	$(ECHO) "# $(GMAKE) database_view_postaudit : view only the cawk post audit database"
	$(ECHO) "# $(GMAKE) database_postaudit_(add,update,del) audit=AUDIT_NAME"
	$(ECHO) "#  add, update or delete an entry of the cawk post audit database, fields separated by spaces:"
	$(ECHO) "#   - field 1 : audit name"
	$(ECHO) "# ---- collect ----"
	$(ECHO) "# $(GMAKE) database_view_collect : view only the cawk collect database"
	$(ECHO) "# $(GMAKE) database_collect_(add,update) audit=AUDIT_NAME collector=scp|rsync|local args=ARGS/none [sync=yes] : add or update the collector of AUDIT_NAME"
	$(ECHO) "# $(GMAKE) database_collect_del audit=AUDIT_NAME : delete the collector of AUDIT_NAME"
	$(ECHO) "# $(GMAKE) database_collect_sync audit=AUDIT_NAME : reference confs/collect_AUDIT_NAME in the sync database"
	$(ECHO) "# ---- scripts ----"
	$(ECHO) "# $(GMAKE) database_target_sh : build the database scripts (database/scripts/*.script) from their .script.sh source"
	$(ECHO) "# ---- information ----"
	$(ECHO) "# $(GMAKE) catalog_build : regenerate database/db_info.txt and database/db_nist_mappings.json (with CATALOG_BUILD=yes)"
	$(ECHO) "# $(GMAKE) catalog_build_repo / catalog_build_run / catalog_build_audit audit=AUDIT_NAME : refresh only the lines of repo / run / AUDIT_NAME in database/db_info.txt"
	$(ECHO) "# $(GMAKE) catalog_nist_mappings : regenerate database/db_nist_mappings.json from database/db_info.txt"
	$(ECHO) "#  database/db_info.txt holds the metadata of the tests, one test per line, fields separated by semicolons:"
	$(ECHO) "#   - field 1 : assessment context (repo or audit name)"
	$(ECHO) "#   - field 2 : supplier (vendor/platform)"
	$(ECHO) "#   - field 3 : test name"
	$(ECHO) "#   - field 4 : test purpose"
	$(ECHO) "#   - field 5 : test description"
	$(ECHO) "#   - field 6 : remediation actions"
	$(ECHO) "#   - field 7 : NIST 800-53 reference"
	$(ECHO) "#   - field 8 : risk level (high/medium/low/info)"
	$(ECHO) "#   - field 9 : test authors"
	$(ECHO) "# ---- exceptions ----"
	$(ECHO) "# $(GMAKE) exceptions_build : regenerate database/db_exception.txt from all the .m4 exception files"
	$(ECHO) "# $(GMAKE) exceptions_build_repo / exceptions_build_run / exceptions_build_run audit=AUDIT_NAME : add only the exceptions of repo / run / run_AUDIT_NAME to database/db_exception.txt"
	$(ECHO) "#  database/db_exception.txt holds the exceptions, one per line, fields separated by semicolons:"
	$(ECHO) "#   - field 1 : assessment context (repo or audit name)"
	$(ECHO) "#   - field 2 : supplier (vendor/platform)"
	$(ECHO) "#   - field 3 : exception ID"
	$(ECHO) "#   - field 4 : approver name"
	$(ECHO) "#   - field 5 : date (yyyy-mm-dd)"
	$(ECHO) "#   - field 6 : business context or reason of the exception"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"

help_catalog:
	@$(GMAKE) --no-print-directory help_logo
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK CATALOG -----------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---- tests ----"
	$(ECHO) "# $(GMAKE) catalog_repo : build the catalog of the tests description for repo"
	$(ECHO) "# $(GMAKE) catalog_run : build the catalog of the tests description for run"
	$(ECHO) "# $(GMAKE) catalog_run audit=AUDIT_NAME : build the catalog of the tests description for AUDIT_NAME"
	$(ECHO) "# $(GMAKE) catalog_build : build the catalog of the tests description for all the assessments (repo and every named audit)"
	$(ECHO) "# ---- exceptions ----"
	$(ECHO) "# $(GMAKE) catalog_exceptions_repo : build the catalog of the exceptions description for repo"
	$(ECHO) "# $(GMAKE) catalog_exceptions_run : build the catalog of the exceptions description for run"
	$(ECHO) "# $(GMAKE) catalog_exceptions_run audit=AUDIT_NAME : build the catalog of the exceptions description for AUDIT_NAME"
	$(ECHO) "# ---- nist coverage ----"
	$(ECHO) "# $(GMAKE) nist_coverage_official : count the NIST 800-53 controls of the official benchmark (database/db_nist800-53.txt)"
	$(ECHO) "# $(GMAKE) nist_coverage_repo : show the NIST 800-53 coverage of the repo tests by supplier"
	$(ECHO) "# $(GMAKE) nist_coverage_run [audit=AUDIT_NAME] : show the NIST 800-53 coverage of the run (or run_AUDIT_NAME) tests by supplier"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"

help_roles:
	@$(GMAKE) --no-print-directory help_logo
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK ROLES -------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# $(GMAKE) roles_list : list the members of the cawk_admin group"
	$(ECHO) "# $(GMAKE) roles_perm : apply the cawk permissions (runs roles/cawk_perm with sudo)"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"

help_git:
	@$(GMAKE) --no-print-directory help_logo
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK GIT (release workflow, every target except gitcheck* needs FORCE=yes) ---------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# MODE 1, direct to master : gitinstallcicd -> gitcommit -> gitpush -> gitpushtag"
	$(ECHO) "# MODE 2, via a branch and a pull request : gitnewbranch -> gitcommit -> gitpushbranch -> gitpr -> gitprmerge -> gitmasterupdate -> gitpushtag"
	$(ECHO) "# $(GMAKE) gitcheck : release gate (databases, tests, system, directories, extensions, .orig files, orthogonality) after a clean_force"
	$(ECHO) "# $(GMAKE) gitcheck_orthogonality : check the consistency between the tests, confs and exceptions of the suppliers"
	$(ECHO) "# $(GMAKE) git_branch_master_check / git_branch_not_master_check : fail unless the current branch is / is not master"
	$(ECHO) "# $(GMAKE) gitinstallcicd FORCE=yes : copy cicd/*.yml into .github/workflows"
	$(ECHO) "# $(GMAKE) gitcommit FORCE=yes : git add and commit with the message *<CAWK_RELEASE> ref ChangeLog (CO_AUTHOR= adds a trailer)"
	$(ECHO) "# $(GMAKE) gitnewbranch FORCE=yes : create the branch <CAWK_RELEASE>-beta from master"
	$(ECHO) "# $(GMAKE) gitpush FORCE=yes : push master to origin"
	$(ECHO) "# $(GMAKE) gitpushbranch FORCE=yes : push the <CAWK_RELEASE>-beta branch to origin"
	$(ECHO) "# $(GMAKE) gitpr FORCE=yes : open the pull request of the current branch (gh)"
	$(ECHO) "# $(GMAKE) gitprmerge FORCE=yes : merge the pull request and delete the branch (gh)"
	$(ECHO) "# $(GMAKE) gitmasterupdate FORCE=yes : checkout and pull master"
	$(ECHO) "# $(GMAKE) gitpushtag FORCE=yes : tag <CAWK_RELEASE> and push the tag"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"

help_censor:
	@$(GMAKE) --no-print-directory help_logo
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK CENSOR ------------------------------------------------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# $(GMAKE) censor_repo : censor confs/repo/confs.<supplier> into confs/repo/confs.<supplier>.censored"
	$(ECHO) "# $(GMAKE) censor_run : same for confs/run"
	$(ECHO) "# $(GMAKE) censor_run audit=AUDIT_NAME : same for confs/run_AUDIT_NAME"
	$(ECHO) "# $(GMAKE) censor_run_audit : same for every named audit"
	$(ECHO) "# $(GMAKE) censor_file in=PATH_FILE out=PATH_FILE_OUT : censor one file into one file"
	$(ECHO) "# $(GMAKE) censor_stdout in=PATH_FILE : censor one file to the standard output"
	$(ECHO) "# $(GMAKE) censor_check in=PATH_FILE_OR_DIR : fail when a secret known by the regexes is still there"
	$(ECHO) "# $(GMAKE) censor_logs_repo : censor logs/repo into logs/repo.censored"
	$(ECHO) "# $(GMAKE) censor_logs_run : same for logs/run"
	$(ECHO) "# $(GMAKE) censor_logs_run audit=AUDIT_NAME : same for logs/run_AUDIT_NAME"
	$(ECHO) "# $(GMAKE) censor_logs_run_audit : same for every named audit"
	$(ECHO) "# $(GMAKE) censor_report_repo : censor reports/repo into reports/repo.censored (the reports hold conf lines)"
	$(ECHO) "# $(GMAKE) censor_report_run : same for reports/run"
	$(ECHO) "# $(GMAKE) censor_report_run audit=AUDIT_NAME : same for reports/run_AUDIT_NAME"
	$(ECHO) "# $(GMAKE) censor_report_run_audit : same for every named audit"
	$(ECHO) "# $(GMAKE) clean_censor_repo : remove confs/repo/confs.<supplier>.censored"
	$(ECHO) "# $(GMAKE) clean_censor_run : same for confs/run"
	$(ECHO) "# $(GMAKE) clean_censor_run audit=AUDIT_NAME : same for confs/run_AUDIT_NAME"
	$(ECHO) "# $(GMAKE) clean_censor_run_audit : same for every named audit"
	$(ECHO) "# $(GMAKE) clean_censor_logs_repo : remove logs/repo.censored"
	$(ECHO) "# $(GMAKE) clean_censor_logs_run : same for logs/run"
	$(ECHO) "# $(GMAKE) clean_censor_logs_run_audit : same for every named audit"
	$(ECHO) "# $(GMAKE) clean_censor_logs_run audit=AUDIT_NAME : same for logs/run_AUDIT_NAME"
	$(ECHO) "# $(GMAKE) clean_censor_report_repo : remove reports/repo.censored"
	$(ECHO) "# $(GMAKE) clean_censor_report_run : same for reports/run"
	$(ECHO) "# $(GMAKE) clean_censor_report_run audit=AUDIT_NAME : same for reports/run_AUDIT_NAME"
	$(ECHO) "# $(GMAKE) clean_censor_report_run_audit : same for every named audit"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"


version:
	@$(ECHO) "cawk version: $(CAWK_RELEASE)"
	@$(ECHO) "cawk version done ----"

# one line per variable of support/Makefile.support.vars.mk (validate/vars checks that none is missing here)
help_vars:
	@$(GMAKE) --no-print-directory help_logo
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# -- CAWK VARIABLES (support/Makefile.support.vars.mk) ------------------------------------------------------"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"
	$(ECHO) "# NOTE : every cawk variable is defined in support/Makefile.support.vars.mk and nowhere else, a new variable is added there and described here"
	$(ECHO) "# NOTE : the options (default shown) are overridden per call: $(GMAKE) check_run audit=client1 JSON=yes PSIRT_ONLY=yes"
	$(ECHO) "# NOTE : an unknown NAME=value on the command line (PSIRT_ONY=yes) is a cawk error that stops gmake before any target, with the closest known names"
	$(ECHO) "# CMDLINE_PARAMS : the words accepted on the command line besides the variables of this file (audit, supplier, topic, in, out, args, collector, dir, file, sync, FORCE, ...)"
	$(ECHO) "# -- execution options --------------------------------------------------------------------------------------"
	$(ECHO) "# VERBOSE (yes) : yes prints the line of every phase of a check, no only the final recap, the warnings and the errors"
	$(ECHO) "# MAKE_PARALLEL (no) : yes spawns several make jobs to run the tests"
	$(ECHO) "# MAKE_J, MAKE_LOAD_AVG (nproc, else 4 / 3) : job count and load-average ceiling of MAKE_PARALLEL=yes"
	$(ECHO) "# MAKE_FILES_PER_TARGET (100), MAKE_FILES_PER_TARGET_PSIRT (1) : confs per parallel job, standard and psirt tests"
	$(ECHO) "# MAKE_FILES_PER_TARGET_MAX (2000) : ceiling of the two above (ARG_MAX), checked by check_supplier"
	$(ECHO) "# -- assessment and reporting options -----------------------------------------------------------------------"
	$(ECHO) "# PSIRT_ONLY (no) : yes runs the psirt tests only"
	$(ECHO) "# STANDARD_ONLY (no) : yes runs the standard tests only, rejected with PSIRT_ONLY=yes"
	$(ECHO) "# JSON (no) : yes writes the json reports next to the text reports"
	$(ECHO) "# HTML (yes) : yes writes the standalone html report assessment.all.summary.html"
	$(ECHO) "# HYPERCUBE_INCONSISTENCY (yes) : yes reports the inconsistent rules of the acl_configconsistency tests"
	$(ECHO) "# HYPERCUBE_REDUNDANCY (yes) : yes reports the redundant rules of the acl_configconsistency tests"
	$(ECHO) "# TIMELINE (yes) : yes writes the timeline csv reports"
	$(ECHO) "# DATA_SET (yes) : yes writes the file of the day in the data_set of an audit (check_run audit=, not with supplier=)"
	$(ECHO) "# DATA_SET_KEEP (180) : number of dates (files) kept per audit in the data_set, a number >= 1"
	$(ECHO) "# DEADBEEF (no), DEADBEEF_THRESHOLD_DAYS (30) : yes excludes the configurations not modified for more than N days"
	$(ECHO) "# BADFORMAT (no) : yes excludes the badformat configurations (first-level indentation violations)"
	$(ECHO) "# CRLF (yes) : yes excludes the crlf configurations (windows format)"
	$(ECHO) "# SECRETSCAN (no) : yes censors the final csv reports (CENSOR_LEVEL) and removes the originals"
	$(ECHO) "# CENSOR_LEVEL (internal) : internal or external, the level of the censor macros applied by the censor_* targets"
	$(ECHO) "# TMP_ASSESSMENT_FILES (yes) : yes removes the intermediate assessment files after reporting"
	$(ECHO) "# CATALOG_BUILD (no) : yes rebuilds the test catalog (db_info.txt) before an assessment"
	$(ECHO) "# COLLECT (no) : yes runs collect_run first in sync_run audit="
	$(ECHO) "# EMAIL_ZIPFILE_LARGE (no) : yes adds the audit, psirt and exception csv to the email export zip"
	$(ECHO) "# ARCHIVE_OLDER_DAYS (120) : the clean_archive_* targets remove the archives older than N days (N >= 30, below it FORCE=yes is required)"
	$(ECHO) "# ALL_ARCHIVE (no) : yes (with FORCE=yes) makes clean_archive_* and clean_force remove every archive"
	$(ECHO) "# LOGO_HTML (docs/logo/logo-cawk.svg) : logo embedded in the html report"
	$(ECHO) "# CHECK_TRACK (no) : yes records each phase of check in checkdiff/track/trace (set by check_track)"
	$(ECHO) "# -- tools and release --------------------------------------------------------------------------------------"
	$(ECHO) "# CAWK_RELEASE : cawk version printed by version and the logo"
	$(ECHO) "# RM (rm), GMAKE (gmake), ECHO (echo), EGREP (grep -E) : commands used by the recipes"
	$(ECHO) "# MAKEFLAGS : silent, no builtin rules"
	$(ECHO) "# cawk_comma : a comma, for the make functions"
	$(ECHO) "# TODAY : date of the day (YYYY-MM-DD)"
	$(ECHO) "# -- directories ---------------------------------------------------------------------------------------------"
	$(ECHO) "# CONFS_PATH, COMMON_PATH, BACKUP_PATH, DATABASE_PATH, LOGS_PATH, REPORT_PATH, EXCEPTION_PATH : top-level directories"
	$(ECHO) "# DATABASE_CIS_INFO : the generated db_info.txt"
	$(ECHO) "# DATABASE_EXCEPTION : the generated db_exception.txt"
	$(ECHO) "# DATABASE_SH_PATH, DATABASE_SH : database scripts directory and *.script.sh list"
	$(ECHO) "# UPDATE_CUSTOM_SCRIPT : your own script run by update_custom_run (database/scripts/update_custom.script, built from update_custom.script.sh)"
	$(ECHO) "# COLLECTORS_PATH : optional config collectors"
	$(ECHO) "# DATA_SET_PATH, DATA_SET_SCRIPT : data_set directory (run_<audit> inside) and the script that writes a date"
	$(ECHO) "# TESTS_PATH, TESTS_COMMON_PATH, TESTS_COMMON_TEMPLATE, TESTS_COMMON_SH, TESTS_SYSTEM, TESTS_TMP : tests and common sources, system and tmp directories"
	$(ECHO) "# TRACK_PATH, TRACK_SCRIPTS : check_track trace directory and its scripts"
	$(ECHO) "# RUN_DIRS, RUN_DIRS_FIND, EXC_DIRS_FIND : named audits found under tests/ and exceptions/"
	$(ECHO) "# -- suppliers and generated test lists -----------------------------------------------------------------------"
	$(ECHO) "# SUPPLIER_SCOPE, CHECK_SCOPE : suppliers handled, restricted by supplier="
	$(ECHO) "# SUPPLIER_M4_REPO_FILES, SUPPLIER_TEMPLATE_REPO_FILES, SUPPLIER_M4_RUN_FILES, SUPPLIER_TEMPLATE_RUN_FILES : compiled standard tests"
	$(ECHO) "# SUPPLIER_M4_REPO_PSIRT_FILES, SUPPLIER_INCLUDEM4_REPO_PSIRT_FILES, SUPPLIER_TEMPLATE_REPO_PSIRT_FILES, SUPPLIER_INCLUDE_REPO_PSIRT_FILES : compiled psirt tests (repo)"
	$(ECHO) "# SUPPLIER_M4_RUN_PSIRT_FILES, SUPPLIER_INCLUDEM4_RUN_PSIRT_FILES, SUPPLIER_TEMPLATE_RUN_PSIRT_FILES, SUPPLIER_INCLUDE_RUN_PSIRT_FILES : compiled psirt tests (run)"
	$(ECHO) "# -- helpers -------------------------------------------------------------------------------------------------"
	$(ECHO) "# CAWK_IN_CHECK, CHECK_QUIET, ECHO_INFO : quiet info lines inside check when VERBOSE=no"
	$(ECHO) "# FIND_CONF_SELECT : find filter selecting the configuration files"
	$(ECHO) "# VIEW_FILTER : filter of view_* by supplier="
	$(ECHO) "# CSV_EXT, JSON_EXT : report extensions (.censored.* with SECRETSCAN=yes)"
	$(ECHO) "# CAWK_SECRETSCAN_GLOB : csv reports censored by SECRETSCAN=yes"
	$(ECHO) "# EMAIL_CSV_TIMELINE, EMAIL_ZIP_LARGE_NAMES : csv names added to the email zip"
	$(ECHO) "# ARCHIVE_CSV_NAME : csv names archived (timeline or not)"
	$(ECHO) "# DEPRECATED_FUNCTIONS : regex of the deprecated test functions"
	$(ECHO) "# NIST_REFERENCE_SRC, NIST_REFERENCE : NIST 800-53 reference shipped in common/database and its working copy in database/ (replaced when older)"
	$(ECHO) "# PHASE_ERR_DIR (logs/phase_err) : staging of the errors of the integrity, compile, catalog_dir, exceptions_dir, tests_copy and deprecated phases, moved by check_repo/check_run to logs/<context>/<phase>.<name>.err (scanned with the other .err logs)"
	$(ECHO) "# INTEGRITY_FATAL : no (default) = integrity errors (check_integrity, censor_*) shown as cawk error: and the target goes on; yes = exit 1"
	$(ECHO) "# DEPRECATED_FILES : old:new pairs of the files moved by a release, the old file must be removed"
	$(ECHO) "# HELP_SECTIONS, HELP_POS : help sections and the word given to help"
	$(ECHO) "# ---------------------------------------------------------------------------------------------------------------"

# unknown target: suggest the known targets containing the word or a few typos away (a prerequisite file that exists never reaches this rule)
.DEFAULT:
	@similar=$$($(GMAKE) --no-print-directory -pRrq : 2>/dev/null | gawk -v t="$@" -f support/similar_target.awk) || { $(ECHO) "cawk error: unknown target <$@>, similar targets lookup failed (list the sections with: $(GMAKE) help) ----"; exit 1; }; \
	$(ECHO) "cawk error: unknown target <$@>$${similar:+, similar targets: $$similar} (list the sections with: $(GMAKE) help, search a word with: $(GMAKE) help topic=WORD) ----"; \
	exit 1
