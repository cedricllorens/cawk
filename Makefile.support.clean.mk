# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

.PHONY: \
  clean clean_archive_older clean_archive_repo clean_archive_run  \
  clean_archive_run_audit clean_backup clean_force clean_orig  \
  clean_report_repo clean_report_run clean_report_run_audit clean_tmp


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
	$(RM) -f *.tar *.tar.gz || true
	$(RM) -f checkdiff/scripts/analyze_diff checkdiff/scripts/check_debug checkdiff/scripts/check_parallel_debug checkdiff/scripts/diff_reports checkdiff/scripts/run_check 2>/dev/null || true
	$(RM) -f checkdiff/scripts/*.log checkdiff/scripts/*.txt 2>/dev/null || true
	$(RM) -f checkdiff/checkdiff.baseline checkdiff/checkdiff.check.result 2>/dev/null || true
	find $(TESTS_COMMON_PATH) $(DATABASE_SH_PATH) $(EXCEPTION_PATH) $(TESTS_PATH)/repo $(TESTS_PATH)/run -type f -exec touch {} \; || true
	find $(TESTS_PATH)/run_* -type f -exec touch {} \; 2>/dev/null || true
	$(ECHO) "cawk clean done ----"

clean_backup:
	$(RM) -f $(BACKUP_PATH)/*.tar $(BACKUP_PATH)/*.tar.gz 2>/dev/null || true
	$(ECHO) "cawk clean $(BACKUP_PATH) done ----"

clean_orig:
	find . -type f -name "*.orig" -delete 2>/dev/null || true
	$(ECHO) "cawk clean all .orig backup files done ----"

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
	@for dir in $(RUN_DIRS); do \
		$(GMAKE) clean_report_run audit=$$dir; \
	done

clean_archive_run_audit:
	@for dir in $(RUN_DIRS); do \
		$(GMAKE) clean_archive_run audit=$$dir; \
	done

clean_tmp:
	find $(TESTS_TMP) -type f -name "tmp*" -delete 2>/dev/null || true
	find $(TESTS_TMP) -type f -name "conf_*" -delete 2>/dev/null || true
	find $(TESTS_TMP) -type f -name "Makefile*" -delete 2>/dev/null || true
	find $(TESTS_TMP) -type f -name "*.swap" -delete 2>/dev/null || true
	$(ECHO) "cawk clean tmp done ----"

clean_force:
	@if [ "$(FORCE)" != "yes" ]; then \
		$(ECHO) "Error: FORCE=yes must be set to run clean_force."; \
		exit 1; \
	fi
	@$(ECHO) "FORCE='$(FORCE)'. Proceeding with clean_force..."
	$(GMAKE) clean clean_report_repo clean_backup clean_report_run clean_report_run_audit clean_archive_repo clean_archive_run clean_archive_run_audit
	@$(ECHO) "cawk clean_force done ----"

clean_archive_older:
	find reports -type f -name '*.tar.gz' -mtime +$(ARCHIVE_OLDER_DAYS) -exec $(RM) -f {} \; 2>/dev/null || true


