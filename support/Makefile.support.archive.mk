# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

.PHONY: \
  archive_repo archive_run archive_run_audit

# TIMELINE=yes: the archive holds the timeline csv only, TIMELINE=no: the plain csv (same rule as email_send)
ARCHIVE_CSV_NAME = $(if $(filter yes,$(strip $(TIMELINE))),'*.timeline$(CSV_EXT)','*.csv')

# -------------------------------------------------------------------------------------------
# MACRO: cawk_archive — tar.gz the csv reports and the summary of a report dir
# -------------------------------------------------------------------------------------------
# HTML=yes: summary.html instead of the txt files, falls back on the txt files when no html was generated
# $(1) = report_dir, $(2) = archive file, $(3) = file receiving the stderr of tar, $(4) = label for the messages
# -------------------------------------------------------------------------------------------
define cawk_archive
@sum='*.txt'; \
	if [ "$(strip $(HTML))" = "yes" ]; then \
		if [ -n "$$(find $(1) -name '*.summary.html')" ]; then sum='*.summary.html'; else $(ECHO) "cawk warning: no summary.html found in $(1), archive the txt files instead ----"; fi; \
	fi; \
	files="$$(find $(1) -type f \( -name $(ARCHIVE_CSV_NAME) -o -name "$$sum" \))"; \
	if [ -n "$$files" ]; then \
		if tar -czf $(2) $$files 2>$(3); then \
			$(ECHO) "cawk build archive in $(2)"; \
		else \
			$(ECHO) "cawk error: $(4) failed (see $(3)) ----"; exit 1; \
		fi; \
	else \
		$(ECHO) "cawk no files $(ARCHIVE_CSV_NAME) and $$sum found in $(1), skip the archive ----"; \
	fi
endef

archive_repo:
	$(call cawk_archive,reports/repo,reports/repo/archives/repo_$(TODAY).tar.gz,$(LOGS_PATH)/repo/archive.repo.err,archive_repo)
	$(ECHO) "cawk archive_repo done ----"

archive_run:
	$(call cawk_archive,reports/run$(if $(audit),_$(audit)),reports/run$(if $(audit),_$(audit))/archives/run$(if $(audit),_$(audit))_$(TODAY).tar.gz,$(LOGS_PATH)/run$(if $(audit),_$(audit))/archive.$(if $(audit),$(audit),run).err,archive_run$(if $(audit), for $(audit)))
	$(ECHO) "cawk archive_run done ----"

archive_run_audit:
	@count=$$($(RUN_DIRS_FIND) | wc -l); \
	if [ "$$count" -eq 0 ]; then \
		$(ECHO) "cawk archive_run_audit: no run audits found ----" ; \
	else \
		$(RUN_DIRS_FIND) | while read -r audit; do \
			$(GMAKE) archive_run audit=$$audit || exit 1; \
		done ; \
	fi
	$(ECHO) "cawk archive_run_audit done ----"
