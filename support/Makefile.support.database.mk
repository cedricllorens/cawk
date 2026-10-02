# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

.PHONY: \
  database_email_add database_email_del database_email_update database_postaudit_add  \
  database_postaudit_del database_postaudit_update database_sync_add database_sync_del  \
  database_sync_update database_target_sh database_view database_view_sync  \
  database_view_email database_view_postaudit

database_target_sh: $(DATABASE_SH:.script.sh=.script)

database_view:
	touch $(DATABASE_PATH)/db_sync.txt
	touch $(DATABASE_PATH)/db_email.txt
	touch $(DATABASE_PATH)/db_postaudit.txt
	$(ECHO) ""
	$(ECHO) "-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_sync.txt"
	$(ECHO) "-------------------------------------------"
	sort $(DATABASE_PATH)/db_sync.txt || true
	$(ECHO) ""
	$(ECHO) "-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_email.txt"
	$(ECHO) "-------------------------------------------"
	sort $(DATABASE_PATH)/db_email.txt || true
	$(ECHO) ""
	$(ECHO) "-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_postaudit.txt"
	$(ECHO) "-------------------------------------------"
	sort $(DATABASE_PATH)/db_postaudit.txt || true
	$(ECHO) ""
	$(ECHO) "cawk database_view done ----"

database_view_sync:
	touch $(DATABASE_PATH)/db_sync.txt
	$(ECHO) ""
	$(ECHO) "-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_sync.txt"
	$(ECHO) "-------------------------------------------"
	sort $(DATABASE_PATH)/db_sync.txt || true
	$(ECHO) ""
	$(ECHO) "cawk database_view_sync done ----"

database_view_email:
	touch $(DATABASE_PATH)/db_email.txt
	$(ECHO) ""
	$(ECHO) "-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_email.txt"
	$(ECHO) "-------------------------------------------"
	sort $(DATABASE_PATH)/db_email.txt || true
	$(ECHO) ""
	$(ECHO) "cawk database_view_email done ----"

database_view_postaudit:
	touch $(DATABASE_PATH)/db_postaudit.txt
	$(ECHO) ""
	$(ECHO) "-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_postaudit.txt"
	$(ECHO) "-------------------------------------------"
	sort $(DATABASE_PATH)/db_postaudit.txt || true
	$(ECHO) ""
	$(ECHO) "cawk database_view_postaudit done ----"

database_sync_add:
	touch $(DATABASE_PATH)/db_sync.txt; \
	if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"; \
	elif [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error audit=$(audit) do not exist  ----"; \
	elif [ -z "$(dir)" ]; then \
		$(ECHO) "cawk error dir=SYNC_PATH must be set ----"; \
	elif [ -z "$(regexinventory)" ]; then \
		$(ECHO) "cawk error regexinventory=REGEX_PATTERN/.* must be set ----"; \
	elif [ -z "$(scope)" ]; then \
		$(ECHO) "cawk error scope=SCOPE_FILE/none must be set ----"; \
	elif [ -z "$(regexos)" ]; then \
		$(ECHO) "cawk error regexos=REGEX_PATTERN_OS/.* must be set ----"; \
	elif [ -z "$(regexpathexclude)" ]; then \
		$(ECHO) "cawk error regexpathexclude=REGEX_PATTERN_PATH_EXCLUDE/none must be set ----"; \
	elif [ -z "$(regexinventoryexclude)" ]; then \
		$(ECHO) "cawk error regexinventoryexclude=REGEX_PATTERN_INVENTORY_EXCLUDE/none must be set ----"; \
	else \
		$(ECHO) "$(audit) $(dir) $(regexinventory) $(scope) $(regexos) $(regexpathexclude) $(regexinventoryexclude)" >> $(DATABASE_PATH)/db_sync.txt; \
	fi
	$(call sort_database_file,$(DATABASE_PATH)/db_sync.txt)
	$(ECHO) "cawk database_sync_add done ----"

database_sync_update:
	touch $(DATABASE_PATH)/db_sync.txt; \
	if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"; \
	elif [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error audit=$(audit) do not exist  ----"; \
	elif [ -z "$(dir)" ]; then \
		$(ECHO) "cawk error dir=SYNC_PATH_DIR must be set ----"; \
	elif [ -z "$(regexinventory)" ]; then \
		$(ECHO) "cawk error regexinventory=REGEX_PATTERN/.* must be set ----"; \
	elif [ -z "$(scope)" ]; then \
		$(ECHO) "cawk error scope=SCOPE_FILE/none must be set ----"; \
	elif [ -z "$(regexos)" ]; then \
		$(ECHO) "cawk error regexos=REGEX_PATTERN_OS/.* must be set ----"; \
	elif [ -z "$(regexpathexclude)" ]; then \
		$(ECHO) "cawk error regexpathexclude=REGEX_PATTERN_PATH_EXCLUDE/none must be set ----"; \
	elif [ -z "$(regexinventoryexclude)" ]; then \
		$(ECHO) "cawk error regexinventoryexclude=REGEX_PATTERN_INVENTORY_EXCLUDE/none must be set ----"; \
	else \
		$(ECHO) "cawk update $(DATABASE_PATH)/db_sync.txt"; \
		sed -i "/^$(audit) /d" $(DATABASE_PATH)/db_sync.txt; \
		$(ECHO) "$(audit) $(dir) $(regexinventory) $(scope) $(regexos) $(regexpathexclude) $(regexinventoryexclude)" >> $(DATABASE_PATH)/db_sync.txt; \
	fi
	$(call sort_database_file,$(DATABASE_PATH)/db_sync.txt)
	$(ECHO) "cawk database_sync_update done ----"

database_sync_del:
	touch $(DATABASE_PATH)/db_sync.txt; \
	if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"; \
	elif [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error audit=$(audit) do not exist  ----"; \
	else \
		$(ECHO) "cawk update $(DATABASE_PATH)/db_sync.txt"; \
		sed -i "/^$(audit) /d" $(DATABASE_PATH)/db_sync.txt; \
	fi
	$(call sort_database_file,$(DATABASE_PATH)/db_sync.txt)
	$(ECHO) "cawk database_sync_del done ----"

database_postaudit_add:
	touch $(DATABASE_PATH)/db_postaudit.txt; \
	if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"; \
	elif [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error audit=$(audit) do not exist  ----"; \
	else \
		$(ECHO) "cawk update $(DATABASE_PATH)/db_postaudit.txt"; \
		$(ECHO) "$(audit)" >> $(DATABASE_PATH)/db_postaudit.txt; \
	fi
	$(call sort_database_file,$(DATABASE_PATH)/db_postaudit.txt)
	$(ECHO) "cawk database_postaudit_add done ----"

database_postaudit_update:
	touch $(DATABASE_PATH)/db_postaudit.txt; \
	if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"; \
	elif [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error audit=$(audit) do not exist  ----"; \
	else \
		$(ECHO) "cawk update $(DATABASE_PATH)/db_postaudit.txt"; \
		sed -i "/^$(audit)$$/d" $(DATABASE_PATH)/db_postaudit.txt; \
		$(ECHO) "$(audit)" >> $(DATABASE_PATH)/db_postaudit.txt; \
	fi
	$(call sort_database_file,$(DATABASE_PATH)/db_postaudit.txt)
	$(ECHO) "cawk database_postaudit_update done ----"

database_postaudit_del:
	touch $(DATABASE_PATH)/db_postaudit.txt; \
	if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"; \
	elif [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error audit=$(audit) do not exist  ----"; \
	else \
		$(ECHO) "cawk update $(DATABASE_PATH)/db_postaudit.txt"; \
		sed -i "/^$(audit)$$/d" $(DATABASE_PATH)/db_postaudit.txt; \
	fi
	$(call sort_database_file,$(DATABASE_PATH)/db_postaudit.txt)
	$(ECHO) "cawk database_postaudit_del done ----"

database_email_add:
	touch $(DATABASE_PATH)/db_email.txt; \
	if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"; \
	elif [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error audit=$(audit) do not exist  ----"; \
	elif [ -z "$(dst)" ]; then \
		$(ECHO) "cawk error dst=RECIPIENT_EMAIL must be set ----"; \
	else \
		cc=$(strip $(cc)); \
		if [ -z "$$cc" ]; then cc=none; fi; \
		$(ECHO) "cawk update $(DATABASE_PATH)/db_email.txt"; \
		$(ECHO) "$(audit) $(dst) $$cc" >> $(DATABASE_PATH)/db_email.txt; \
	fi
	$(call sort_database_file,$(DATABASE_PATH)/db_email.txt)
	$(ECHO) "cawk email_database_add done ----"

database_email_update:
	touch $(DATABASE_PATH)/db_email.txt; \
	if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"; \
	elif [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error audit=$(audit) do not exist  ----"; \
	elif [ -z "$(dst)" ]; then \
		$(ECHO) "cawk error dst=RECIPIENT_EMAIL must be set ----"; \
	else \
		cc=$(strip $(cc)); \
		if [ -z "$$cc" ]; then cc=none; fi; \
		$(ECHO) "cawk update $(DATABASE_PATH)/db_email.txt"; \
		sed -i "/^$(audit) /d" $(DATABASE_PATH)/db_email.txt; \
		$(ECHO) "$(audit) $(dst) $$cc" >> $(DATABASE_PATH)/db_email.txt; \
	fi
	$(call sort_database_file,$(DATABASE_PATH)/db_email.txt)
	$(ECHO) "cawk email_database_update done ----"

database_email_del:
	touch $(DATABASE_PATH)/db_email.txt
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
	$(ECHO) "cawk update $(DATABASE_PATH)/db_email.txt"
	sed -i "/^${audit} /d" $(DATABASE_PATH)/db_email.txt
	$(call sort_database_file,$(DATABASE_PATH)/db_email.txt)
endif
	$(ECHO) "cawk email_database_del done ----"