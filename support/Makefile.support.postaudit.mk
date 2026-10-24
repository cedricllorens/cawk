# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

.PHONY: \
  postaudit_run postaudit_run_audit

postaudit_run: clean tests_target_common database_target_sh
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
	exit 1
else
	mkdir -p $(LOGS_PATH)/run_$(audit)
	if [ ! -f $(DATABASE_SH_PATH)/database_postaudit.script ]; then \
		$(ECHO) "cawk error: $(DATABASE_SH_PATH)/database_postaudit.script does not exist ----"; exit 1; \
	else \
		$(ECHO) "cawk $(DATABASE_SH_PATH)/database_postaudit.script execution ----"; \
		$(DATABASE_SH_PATH)/database_postaudit.script $(audit) 2>$(LOGS_PATH)/run_$(audit)/postaudit.$(audit).err || { $(ECHO) "cawk error: database_postaudit.script failed for $(audit) (see $(LOGS_PATH)/run_$(audit)/postaudit.$(audit).err) ----"; exit 1; }; \
	fi
	$(ECHO) "cawk postaudit_run $(audit) done ----"
endif

postaudit_run_audit:
	while read line; do \
		$(ECHO) $$line ; \
		audit=$$line; \
		$(GMAKE) postaudit_run audit=$$audit || exit 1; \
	done < $(DATABASE_PATH)/db_postaudit.txt
	$(GMAKE) list_audit
	$(ECHO) "cawk postaudit_run_audit all audit done ----"
