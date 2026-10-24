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
  database_view_collect database_view_email database_view_postaudit

# Field format of each flat-file database (fields, possible values, example), shown by database_view and database_view_*
# Canned recipes: one $(ECHO) per line (no -e), only called as a whole recipe line
define DB_FORMAT_COLLECT
$(ECHO) "format  : audit collector args  (space-separated, no space inside a field)"
$(ECHO) "audit     : audit name (audit=AUDIT_NAME)"
$(ECHO) "collector : none | scp | rsync | local  (script database/collectors/<collector>.collector.sh, none = no collection)"
$(ECHO) "            scp and rsync fetch the confs (one file per device) from ONE central unix/linux system, local copies them from a directory of this machine, the collected"
$(ECHO) "            files always go to confs/collect_<audit>/"
$(ECHO) "args      : comma-separated key=value pairs (no space, no comma in a value) | none"
$(ECHO) "  scp      : host=ADDRESS,user=USER,remote_path=REMOTE_DIR[,key=IDENTITY_FILE][,port=N][,timeout=SECONDS][,hostkey=yes|accept-new][,options=OPTS]"
$(ECHO) "  rsync    : host=ADDRESS,user=USER,remote_path=REMOTE_DIR[,key=IDENTITY_FILE][,port=N][,timeout=SECONDS][,hostkey=yes|accept-new][,options=OPTS]"
$(ECHO) "  local    : source_path=LOCAL_DIR"
$(ECHO) "            host = IP address or name of the central system, user = login account, remote_path = directory of the confs"
$(ECHO) "            options = extra scp (scp) or rsync (rsync) options, words separated by + (no space in an arg)"
$(ECHO) "            e.g. options=-4+-o+ServerAliveInterval=5 (scp) or options=--bwlimit=1000+--compress (rsync)"
$(ECHO) "            the copy is automatic (scp -rp / rsync -rt over ssh), key/agent authentication only, no command to write"
$(ECHO) "            source_path = absolute directory of this machine holding one file per device, copied with cp -p (no network)"
$(ECHO) "example   : client1 rsync host=192.0.2.10,user=cawk,remote_path=/srv/confs/,key=/home/cawk/.ssh/id_ed25519"
$(ECHO) "example   : client1 local source_path=/srv/confs/"
$(ECHO) "example   : client1 scp host=192.0.2.10,user=cawk,remote_path=/srv/confs/,key=/home/cawk/.ssh/id_ed25519"
endef

define DB_FORMAT_SYNC
$(ECHO) "format  : audit sync_paths regexinventory scope regexos regexpathexclude regexinventoryexclude  (space-separated, no space inside a field)"
$(ECHO) "audit                : audit name (audit=AUDIT_NAME)"
$(ECHO) "sync_paths           : comma-separated remote paths to sync (dir=), e.g. /conf/,/conf/backup/ or ../collect_<audit>/"
$(ECHO) "regexinventory       : extended regex a scope file line must match, e.g. .*switch.* (only applied if scope is not none)"
$(ECHO) "scope                : path of the device inventory file (first column = device) | none = every device"
$(ECHO) "regexos              : extended regex on the supplier, e.g. cisco-ios|cisco-xe"
$(ECHO) "regexpathexclude     : extended regex of the paths to exclude, e.g. _backup | none"
$(ECHO) "regexinventoryexclude: extended regex a scope file line must NOT match | none (only applied if scope is not none)"
$(ECHO) "example              : client1 /conf/,/conf/backup/ .*switch.* /inventory/scope.txt cisco-ios|cisco-xe _backup none"
endef

define DB_FORMAT_EMAIL
$(ECHO) "format  : audit dst_emails cc_emails  (space-separated, no space inside a field)"
$(ECHO) "audit      : audit name (audit=AUDIT_NAME)"
$(ECHO) "dst_emails : comma-separated recipient addresses (dst=)"
$(ECHO) "cc_emails  : comma-separated CC addresses (cc=) | none"
$(ECHO) "example    : client1 john@example.com,jane@example.com manager@example.com"
endef

define DB_FORMAT_POSTAUDIT
$(ECHO) "format  : audit  (one audit name per line)"
$(ECHO) "audit   : audit name (audit=AUDIT_NAME) whose post-audit request is pending"
$(ECHO) "example : client1"
endef

database_target_sh: $(DATABASE_SH:.script.sh=.script)

database_view:
	touch $(DATABASE_PATH)/db_collect.txt
	touch $(DATABASE_PATH)/db_sync.txt
	touch $(DATABASE_PATH)/db_email.txt
	touch $(DATABASE_PATH)/db_postaudit.txt
	$(ECHO) ""
	$(ECHO) "-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_collect.txt"
	$(DB_FORMAT_COLLECT)
	$(ECHO) "-------------------------------------------"
	sort $(DATABASE_PATH)/db_collect.txt || true
	$(ECHO) ""
	$(ECHO) "-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_sync.txt"
	$(DB_FORMAT_SYNC)
	$(ECHO) "-------------------------------------------"
	sort $(DATABASE_PATH)/db_sync.txt || true
	$(ECHO) ""
	$(ECHO) "-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_email.txt"
	$(DB_FORMAT_EMAIL)
	$(ECHO) "-------------------------------------------"
	sort $(DATABASE_PATH)/db_email.txt || true
	$(ECHO) ""
	$(ECHO) "-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_postaudit.txt"
	$(DB_FORMAT_POSTAUDIT)
	$(ECHO) "-------------------------------------------"
	sort $(DATABASE_PATH)/db_postaudit.txt || true
	$(ECHO) ""
	$(ECHO) "cawk database_view done ----"

database_view_sync:
	touch $(DATABASE_PATH)/db_sync.txt
	$(ECHO) ""
	$(ECHO) "-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_sync.txt"
	$(DB_FORMAT_SYNC)
	$(ECHO) "-------------------------------------------"
	sort $(DATABASE_PATH)/db_sync.txt || true
	$(ECHO) ""
	$(ECHO) "cawk database_view_sync done ----"

database_view_collect:
	touch $(DATABASE_PATH)/db_collect.txt
	$(ECHO) ""
	$(ECHO) "-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_collect.txt"
	$(DB_FORMAT_COLLECT)
	$(ECHO) "-------------------------------------------"
	sort $(DATABASE_PATH)/db_collect.txt || true
	$(ECHO) ""
	$(ECHO) "cawk database_view_collect done ----"

database_view_email:
	touch $(DATABASE_PATH)/db_email.txt
	$(ECHO) ""
	$(ECHO) "-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_email.txt"
	$(DB_FORMAT_EMAIL)
	$(ECHO) "-------------------------------------------"
	sort $(DATABASE_PATH)/db_email.txt || true
	$(ECHO) ""
	$(ECHO) "cawk database_view_email done ----"

database_view_postaudit:
	touch $(DATABASE_PATH)/db_postaudit.txt
	$(ECHO) ""
	$(ECHO) "-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_postaudit.txt"
	$(DB_FORMAT_POSTAUDIT)
	$(ECHO) "-------------------------------------------"
	sort $(DATABASE_PATH)/db_postaudit.txt || true
	$(ECHO) ""
	$(ECHO) "cawk database_view_postaudit done ----"

database_sync_add:
	touch $(DATABASE_PATH)/db_sync.txt; \
	if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"; exit 1; \
	elif [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error audit=$(audit) do not exist ----"; exit 1; \
	elif [ -z "$(dir)" ]; then \
		$(ECHO) "cawk error dir=SYNC_PATH must be set ----"; exit 1; \
	elif [ -z "$(regexinventory)" ]; then \
		$(ECHO) "cawk error regexinventory=REGEX_PATTERN/.* must be set ----"; exit 1; \
	elif [ -z "$(scope)" ]; then \
		$(ECHO) "cawk error scope=SCOPE_FILE/none must be set ----"; exit 1; \
	elif [ -z "$(regexos)" ]; then \
		$(ECHO) "cawk error regexos=REGEX_PATTERN_OS/.* must be set ----"; exit 1; \
	elif [ -z "$(regexpathexclude)" ]; then \
		$(ECHO) "cawk error regexpathexclude=REGEX_PATTERN_PATH_EXCLUDE/none must be set ----"; exit 1; \
	elif [ -z "$(regexinventoryexclude)" ]; then \
		$(ECHO) "cawk error regexinventoryexclude=REGEX_PATTERN_INVENTORY_EXCLUDE/none must be set ----"; exit 1; \
	elif grep -Eq "^$(audit) " $(DATABASE_PATH)/db_sync.txt; then \
		$(ECHO) "cawk error audit=$(audit) already in db_sync.txt, use update ----"; exit 1; \
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
		$(ECHO) "cawk error audit=$(audit) do not exist ----"; \
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
		$(ECHO) "cawk error audit=$(audit) do not exist ----"; \
	else \
		$(ECHO) "cawk update $(DATABASE_PATH)/db_sync.txt"; \
		sed -i "/^$(audit) /d" $(DATABASE_PATH)/db_sync.txt; \
	fi
	$(call sort_database_file,$(DATABASE_PATH)/db_sync.txt)
	$(ECHO) "cawk database_sync_del done ----"

database_postaudit_add:
	touch $(DATABASE_PATH)/db_postaudit.txt; \
	if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"; exit 1; \
	elif [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error audit=$(audit) do not exist ----"; exit 1; \
	elif grep -Eq "^$(audit)$$" $(DATABASE_PATH)/db_postaudit.txt; then \
		$(ECHO) "cawk error audit=$(audit) already in db_postaudit.txt, use update ----"; exit 1; \
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
		$(ECHO) "cawk error audit=$(audit) do not exist ----"; \
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
		$(ECHO) "cawk error audit=$(audit) do not exist ----"; \
	else \
		$(ECHO) "cawk update $(DATABASE_PATH)/db_postaudit.txt"; \
		sed -i "/^$(audit)$$/d" $(DATABASE_PATH)/db_postaudit.txt; \
	fi
	$(call sort_database_file,$(DATABASE_PATH)/db_postaudit.txt)
	$(ECHO) "cawk database_postaudit_del done ----"

database_email_add:
	touch $(DATABASE_PATH)/db_email.txt; \
	if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"; exit 1; \
	elif [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error audit=$(audit) do not exist ----"; exit 1; \
	elif [ -z "$(dst)" ]; then \
		$(ECHO) "cawk error dst=RECIPIENT_EMAIL must be set ----"; exit 1; \
	elif grep -Eq "^$(audit) " $(DATABASE_PATH)/db_email.txt; then \
		$(ECHO) "cawk error audit=$(audit) already in db_email.txt, use update ----"; exit 1; \
	else \
		cc=$(strip $(cc)); \
		if [ -z "$$cc" ]; then cc=none; fi; \
		$(ECHO) "cawk update $(DATABASE_PATH)/db_email.txt"; \
		$(ECHO) "$(audit) $(dst) $$cc" >> $(DATABASE_PATH)/db_email.txt; \
	fi
	$(call sort_database_file,$(DATABASE_PATH)/db_email.txt)
	$(ECHO) "cawk database_email_add done ----"

database_email_update:
	touch $(DATABASE_PATH)/db_email.txt; \
	if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"; \
	elif [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error audit=$(audit) do not exist ----"; \
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
