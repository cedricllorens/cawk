# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

.PHONY: \
  clean clean_archive_older clean_archive_repo clean_archive_run  \
  clean_archive_run_audit clean_backup clean_force clean_orig clean_orig_info \
  clean_report_repo clean_report_run clean_report_run_audit clean_tmp clean_logs \
  clean_logs_repo clean_logs_run clean_logs_run_audit \
  clean_censor_repo clean_censor_run clean_censor_run_audit \
  clean_censor_logs_repo clean_censor_logs_run clean_censor_logs_run_audit \
  clean_censor_report_repo clean_censor_report_run clean_censor_report_run_audit


clean: clean_tmp
	find $(TESTS_COMMON_PATH) -type f -name "*.gawk" -delete 2>/dev/null || true
	find $(TESTS_COMMON_PATH) -type f -name "*.script" -delete 2>/dev/null || true
	find $(DATABASE_SH_PATH) -type f -name "*.script" -delete 2>/dev/null || true
	find $(EXCEPTION_PATH) -type f -name "exceptions.*" ! -name "*.m4" ! -name "*.sed" -delete 2>/dev/null || true
	find $(TESTS_PATH)/repo -type f -name "*.gawk" -delete 2>/dev/null || true
	find $(TESTS_PATH)/repo -type f -name "*.swap" -delete 2>/dev/null || true
	find $(TESTS_PATH)/repo -type f -name "*.gawk.include.gen" -delete 2>/dev/null || true
	find $(TESTS_PATH)/run -type f -name "*.gawk" -delete 2>/dev/null || true
	find $(TESTS_PATH)/run -type f -name "*.swap" -delete 2>/dev/null || true
	find $(TESTS_PATH)/run -type f -name "*.gawk.include.gen" -delete 2>/dev/null || true
	find $(TESTS_PATH)/run_* -type f -name "*.gawk" -delete 2>/dev/null || true
	find $(TESTS_PATH)/run_* -type f -name "*.swap" -delete 2>/dev/null || true
	find $(TESTS_PATH)/run_* -type f -name "*.gawk.include.gen" -delete 2>/dev/null || true
	$(RM) -f *.tar *.tar.gz || true
	$(RM) -f checkdiff/scripts/analyze_diff checkdiff/scripts/check_debug checkdiff/scripts/check_parallel_debug checkdiff/scripts/diff_reports checkdiff/scripts/run_check 2>/dev/null || true
	$(RM) -f checkdiff/scripts/*.log checkdiff/scripts/*.txt 2>/dev/null || true
	$(RM) -f checkdiff/checkdiff.baseline checkdiff/checkdiff.check.result 2>/dev/null || true
	find $(TESTS_COMMON_PATH) $(DATABASE_SH_PATH) $(EXCEPTION_PATH) $(TESTS_PATH)/repo $(TESTS_PATH)/run -type f -exec touch {} + || true
	find $(TESTS_PATH)/run_* -type f -exec touch {} + 2>/dev/null || true
	@if find $(TESTS_PATH) -type f -name "*.gawk" -print -quit 2>/dev/null | grep -q .; then \
		$(ECHO) "cawk error: obsolete test has been detected and must be removed"; \
		exit 1; \
	fi
	$(ECHO) "cawk clean done ----"

clean_backup:
	$(RM) -f $(BACKUP_PATH)/*.tar $(BACKUP_PATH)/*.tar.gz 2>/dev/null || true
	$(ECHO) "cawk clean $(BACKUP_PATH) done ----"

clean_orig:
	@if [ "$(FORCE)" = "yes" ]; then \
		$(ECHO) "FORCE='$(FORCE)'. Proceeding with clean_orig..."; \
		find . -type f -name "*.orig" -delete 2>/dev/null || true; \
		$(ECHO) "cawk clean all .orig backup files done ----"; \
	else \
		$(ECHO) "cawk error: FORCE=yes must be set to run clean_orig ----"; \
		exit 1; \
	fi

clean_orig_info:
	find . -type f -name "*.orig" || true
	$(ECHO) "cawk clean info .orig backup files done ----"

clean_report_repo:
	$(RM) -f $(REPORT_PATH)/repo/* 2>/dev/null || true
	$(ECHO) "cawk clean $(REPORT_PATH)/repo done ----"

clean_archive_repo:
	$(RM) -f $(REPORT_PATH)/repo/archives/* 2>/dev/null || true
	$(ECHO) "cawk clean $(REPORT_PATH)/repo/archives done ----"

clean_report_run:
ifeq ($(strip $(audit)),)
	$(RM) -f $(REPORT_PATH)/run/* 2>/dev/null || true
	$(ECHO) "cawk clean $(REPORT_PATH)/run done ----"
else
	$(RM) -f $(REPORT_PATH)/run_$(audit)/* 2>/dev/null || true
	$(ECHO) "cawk clean $(REPORT_PATH)/run_$(audit) done ----"
endif

clean_archive_run:
ifeq ($(strip $(audit)),)
	$(RM) -f $(REPORT_PATH)/run/archives/* 2>/dev/null || true
	$(ECHO) "cawk clean $(REPORT_PATH)/run/archives done ----"
else
	$(RM) -f $(REPORT_PATH)/run_$(audit)/archives/* 2>/dev/null || true
	$(ECHO) "cawk clean $(REPORT_PATH)/run_$(audit)/archives done ----"
endif

clean_report_run_audit:
	@$(RUN_DIRS_FIND) | while read -r dir; do \
		$(GMAKE) clean_report_run audit=$$dir || exit 1; \
	done

clean_archive_run_audit:
	@$(RUN_DIRS_FIND) | while read -r dir; do \
		$(GMAKE) clean_archive_run audit=$$dir || exit 1; \
	done

# $(1) = confs directory of the assessment (confs/repo, confs/run or confs/run_<audit>)
# removes the confs.<supplier>.censored directories only (never a confs.<supplier>), the one of supplier= if given, all of them otherwise
define cawk_censor_clean
	@if [ -n "$(strip $(supplier))" ]; then \
		$(RM) -r "$(1)/confs.$(strip $(supplier)).censored"; \
	else \
		find "$(1)" -maxdepth 1 -type d -name "confs.*.censored" -exec $(RM) -r {} + 2>/dev/null || true; \
	fi
endef

clean_censor_repo: check_supplier
	$(call cawk_censor_clean,$(CONFS_PATH)/repo)
	$(ECHO) "cawk clean $(CONFS_PATH)/repo censored done ----"

clean_censor_run: check_supplier
ifeq ($(strip $(audit)),)
	$(call cawk_censor_clean,$(CONFS_PATH)/run)
	$(ECHO) "cawk clean $(CONFS_PATH)/run censored done ----"
else
	$(call cawk_censor_clean,$(CONFS_PATH)/run_$(audit))
	$(ECHO) "cawk clean $(CONFS_PATH)/run_$(audit) censored done ----"
endif

clean_censor_run_audit: check_supplier
	@$(RUN_DIRS_FIND) | while read -r dir; do \
		$(GMAKE) clean_censor_run audit=$$dir || exit 1; \
	done

# $(1) = logs/reports directory of the assessment (logs/repo, reports/run, ...)
# removes the $(1).censored directory only (never $(1) itself)
define cawk_censor_clean_dir
	$(RM) -f -r "$(1).censored"
endef

clean_censor_logs_repo: check_supplier
	$(call cawk_censor_clean_dir,$(LOGS_PATH)/repo)
	$(ECHO) "cawk clean $(LOGS_PATH)/repo.censored done ----"

clean_censor_logs_run: check_supplier
ifeq ($(strip $(audit)),)
	$(call cawk_censor_clean_dir,$(LOGS_PATH)/run)
	$(ECHO) "cawk clean $(LOGS_PATH)/run.censored done ----"
else
	$(call cawk_censor_clean_dir,$(LOGS_PATH)/run_$(audit))
	$(ECHO) "cawk clean $(LOGS_PATH)/run_$(audit).censored done ----"
endif

clean_censor_logs_run_audit: check_supplier
	@$(RUN_DIRS_FIND) | while read -r dir; do \
		$(GMAKE) clean_censor_logs_run audit=$$dir || exit 1; \
	done

clean_censor_report_repo: check_supplier
	$(call cawk_censor_clean_dir,$(REPORT_PATH)/repo)
	$(ECHO) "cawk clean $(REPORT_PATH)/repo.censored done ----"

clean_censor_report_run: check_supplier
ifeq ($(strip $(audit)),)
	$(call cawk_censor_clean_dir,$(REPORT_PATH)/run)
	$(ECHO) "cawk clean $(REPORT_PATH)/run.censored done ----"
else
	$(call cawk_censor_clean_dir,$(REPORT_PATH)/run_$(audit))
	$(ECHO) "cawk clean $(REPORT_PATH)/run_$(audit).censored done ----"
endif

clean_censor_report_run_audit: check_supplier
	@$(RUN_DIRS_FIND) | while read -r dir; do \
		$(GMAKE) clean_censor_report_run audit=$$dir || exit 1; \
	done

clean_tmp:
	find $(TESTS_TMP) -type f -name "tmp*" -delete 2>/dev/null || true
	find $(TESTS_TMP) -type f -name "conf_*" -delete 2>/dev/null || true
	find $(TESTS_TMP) -type f -name "Makefile*" -delete 2>/dev/null || true
	find $(TESTS_TMP) -type f -name "*.swap" -delete 2>/dev/null || true
	find $(TESTS_TMP) -type f -name "*.txt" -delete 2>/dev/null || true
	$(ECHO) "cawk clean tmp done ----"

# clean_logs_repo/clean_logs_run are called by check_repo/check_run at the start of each
# assessment, so a run's logs only ever reflect that run. clean_logs itself (the cross-scope
# variant purging $(LOGS_PATH) as a whole, including the top-level *.all.err files) stays a
# manual-only target — it is not a dependency of clean/clean_force/check_* — since it also
# reaches audits/scopes outside the one currently being checked.
# Logs are scoped under $(LOGS_PATH)/repo, $(LOGS_PATH)/run and $(LOGS_PATH)/run_<audit>
# (plus a few cross-audit *.all.err files staying at the top level), so no -maxdepth here.
clean_logs:
	@if [ "$(FORCE)" != "yes" ]; then \
		$(ECHO) "cawk error: FORCE=yes must be set to run clean_logs ----"; \
		exit 1; \
	fi
	find $(LOGS_PATH) -type f -name "*.err" -delete 2>/dev/null || true
	$(ECHO) "cawk clean $(LOGS_PATH) done ----"

clean_logs_repo:
	@if [ "$(FORCE)" != "yes" ]; then \
		$(ECHO) "cawk error: FORCE=yes must be set to run clean_logs_repo ----"; \
		exit 1; \
	fi
	$(RM) -f $(LOGS_PATH)/repo/*.err 2>/dev/null || true
	$(ECHO) "cawk clean $(LOGS_PATH)/repo done ----"

clean_logs_run:
	@if [ "$(FORCE)" != "yes" ]; then \
		$(ECHO) "cawk error: FORCE=yes must be set to run clean_logs_run ----"; \
		exit 1; \
	fi
ifeq ($(strip $(audit)),)
	$(RM) -f $(LOGS_PATH)/run/*.err 2>/dev/null || true
	$(ECHO) "cawk clean $(LOGS_PATH)/run done ----"
else
	$(RM) -f $(LOGS_PATH)/run_$(audit)/*.err 2>/dev/null || true
	$(ECHO) "cawk clean $(LOGS_PATH)/run_$(audit) done ----"
endif

clean_logs_run_audit:
	@if [ "$(FORCE)" != "yes" ]; then \
		$(ECHO) "cawk error: FORCE=yes must be set to run clean_logs_run_audit ----"; \
		exit 1; \
	fi
	@$(RUN_DIRS_FIND) | while read -r dir; do \
		$(GMAKE) clean_logs_run audit=$$dir || exit 1; \
	done

clean_force:
	@if [ "$(FORCE)" != "yes" ]; then \
		$(ECHO) "cawk error: FORCE=yes must be set to run clean_force ----"; \
		exit 1; \
	fi
	@$(ECHO) "FORCE='$(FORCE)'. Proceeding with clean_force..."
	$(GMAKE) clean clean_report_repo clean_backup clean_report_run clean_report_run_audit clean_archive_repo clean_archive_run clean_archive_run_audit clean_censor_repo clean_censor_run clean_censor_run_audit clean_censor_logs_repo clean_censor_logs_run clean_censor_logs_run_audit clean_censor_report_repo clean_censor_report_run clean_censor_report_run_audit
	@$(ECHO) "cawk clean_force done ----"

clean_archive_older:
	find -H reports -type f -name '*.tar.gz' -mtime +$(ARCHIVE_OLDER_DAYS) -exec $(RM) -f {} \; 2>/dev/null || true


