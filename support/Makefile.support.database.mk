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
$(ECHO) "example              : client1 /conf/,/conf/backup/ .*switch.* database/sync_scopes/client1_inventory_sync_scope.txt cisco-ios|cisco-xe _backup none"
endef

define DB_FORMAT_EMAIL
$(ECHO) "format  : audit dst_emails cc_emails  (space-separated, no space inside a field)"
$(ECHO) "audit      : audit name (audit=AUDIT_NAME)"
$(ECHO) "dst_emails : comma-separated recipient addresses (dst=)"
$(ECHO) "cc_emails  : comma-separated CC addresses (cc=) | none"
$(ECHO) "example    : client1 john@example.com,jane@example.com manager@example.com"
endef

# Shared awk library of the block views: default shown for a missing field, one separator before each entry, summary at the end (the strict format check is gmake check_database)
define DB_VIEW_LIB
BEGIN { sep = "- - - - - - - - - - - - - - - - - - - - - -" } function v(i, d) { if (i <= NF) return $$i; inc = 1; return (d == "" ? "(missing, required)" : d " (default)") } function chk(max) { if (NF > max) print "cawk warning: " f " line has " NF " fields, " max " expected, extra fields ignored: " $$0 " ----" > "/dev/stderr" } function lst(lab, w, i, d,  k, p, j) { if (i > NF) { printf "%-*s : %s\n", w, lab, v(i, d); return } k = split($$i, p, ","); for (j = 1; j <= k; j++) if (j == 1) printf "%-*s : %s\n", w, lab, p[j]; else printf "%-*s   %s\n", w, "", p[j] } function fin() { print sep; printf "cawk %d entries, %d incomplete%s\n", n, m, (m ? " (default values shown, run gmake check_database)" : "") }
endef

# Block view of db_email.txt: one block per audit, one address per line
define DB_VIEW_EMAIL
sort $(DATABASE_PATH)/db_email.txt | gawk -v f=$(DATABASE_PATH)/db_email.txt '$(DB_VIEW_LIB) NF == 0 { next } { inc = 0; n++; chk(3); print sep; printf "%-10s : %s\n", "audit", $$1; lst("dst_emails", 10, 2, ""); lst("cc_emails", 10, 3, "none"); if (inc) m++ } END { fin() }'
endef

# Block view of db_sync.txt, db_collect.txt and db_postaudit.txt: one block per line, one value per line for the comma-separated list
define DB_VIEW_SYNC
sort $(DATABASE_PATH)/db_sync.txt | gawk -v f=$(DATABASE_PATH)/db_sync.txt '$(DB_VIEW_LIB) NF == 0 { next } { inc = 0; n++; chk(7); print sep; printf "%-21s : %s\n", "audit", $$1; lst("sync_paths", 21, 2, ""); printf "%-21s : %s\n", "regexinventory", v(3, ".*"); printf "%-21s : %s\n", "scope", v(4, "none"); printf "%-21s : %s\n", "regexos", v(5, ".*"); printf "%-21s : %s\n", "regexpathexclude", v(6, "none"); printf "%-21s : %s\n", "regexinventoryexclude", v(7, "none"); if (inc) m++ } END { fin() }'
endef

define DB_VIEW_COLLECT
sort $(DATABASE_PATH)/db_collect.txt | gawk -v f=$(DATABASE_PATH)/db_collect.txt '$(DB_VIEW_LIB) NF == 0 { next } { inc = 0; n++; chk(3); print sep; printf "%-9s : %s\n", "audit", $$1; printf "%-9s : %s\n", "collector", v(2, ""); lst("args", 9, 3, "none"); if (inc) m++ } END { fin() }'
endef

define DB_VIEW_POSTAUDIT
sort $(DATABASE_PATH)/db_postaudit.txt | gawk -v f=$(DATABASE_PATH)/db_postaudit.txt '$(DB_VIEW_LIB) NF == 0 { next } { inc = 0; n++; chk(1); print sep; printf "%-5s : %s\n", "audit", $$1 } END { fin() }'
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
	$(DB_VIEW_COLLECT)
	$(ECHO) ""
	$(ECHO) "-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_sync.txt"
	$(DB_FORMAT_SYNC)
	$(ECHO) "-------------------------------------------"
	$(DB_VIEW_SYNC)
	$(ECHO) ""
	$(ECHO) "-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_email.txt"
	$(DB_FORMAT_EMAIL)
	$(ECHO) "-------------------------------------------"
	$(DB_VIEW_EMAIL)
	$(ECHO) ""
	$(ECHO) "-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_postaudit.txt"
	$(DB_FORMAT_POSTAUDIT)
	$(ECHO) "-------------------------------------------"
	$(DB_VIEW_POSTAUDIT)
	$(ECHO) ""
	$(ECHO) "cawk database_view done ----"

database_view_sync:
	touch $(DATABASE_PATH)/db_sync.txt
	$(ECHO) ""
	$(ECHO) "-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_sync.txt"
	$(DB_FORMAT_SYNC)
	$(ECHO) "-------------------------------------------"
	$(DB_VIEW_SYNC)
	$(ECHO) ""
	$(ECHO) "cawk database_view_sync done ----"

database_view_collect:
	touch $(DATABASE_PATH)/db_collect.txt
	$(ECHO) ""
	$(ECHO) "-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_collect.txt"
	$(DB_FORMAT_COLLECT)
	$(ECHO) "-------------------------------------------"
	$(DB_VIEW_COLLECT)
	$(ECHO) ""
	$(ECHO) "cawk database_view_collect done ----"

database_view_email:
	touch $(DATABASE_PATH)/db_email.txt
	$(ECHO) ""
	$(ECHO) "-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_email.txt"
	$(DB_FORMAT_EMAIL)
	$(ECHO) "-------------------------------------------"
	$(DB_VIEW_EMAIL)
	$(ECHO) ""
	$(ECHO) "cawk database_view_email done ----"

database_view_postaudit:
	touch $(DATABASE_PATH)/db_postaudit.txt
	$(ECHO) ""
	$(ECHO) "-------------------------------------------"
	$(ECHO) "cawk view $(DATABASE_PATH)/db_postaudit.txt"
	$(DB_FORMAT_POSTAUDIT)
	$(ECHO) "-------------------------------------------"
	$(DB_VIEW_POSTAUDIT)
	$(ECHO) ""
	$(ECHO) "cawk database_view_postaudit done ----"

database_sync_add:
	touch $(DATABASE_PATH)/db_sync.txt; \
	if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error: audit= must be set (usage: $(GMAKE) <target> audit=<name>, list the audits with: $(GMAKE) list_audit) ----"; exit 1; \
	elif [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error: audit $(audit) does not exist (create it with: $(GMAKE) create_audit audit=$(audit), list the audits with: $(GMAKE) list_audit) ----"; exit 1; \
	elif [ -z "$(dir)" ]; then \
		$(ECHO) "cawk error: dir=SYNC_PATH must be set ----"; exit 1; \
	elif [ -z "$(regexinventory)" ]; then \
		$(ECHO) "cawk error: regexinventory=REGEX_PATTERN/.* must be set ----"; exit 1; \
	elif [ -z "$(scope)" ]; then \
		$(ECHO) "cawk error: scope=SCOPE_FILE/none must be set ----"; exit 1; \
	elif [ -z "$(regexos)" ]; then \
		$(ECHO) "cawk error: regexos=REGEX_PATTERN_OS/.* must be set ----"; exit 1; \
	elif [ -z "$(regexpathexclude)" ]; then \
		$(ECHO) "cawk error: regexpathexclude=REGEX_PATTERN_PATH_EXCLUDE/none must be set ----"; exit 1; \
	elif [ -z "$(regexinventoryexclude)" ]; then \
		$(ECHO) "cawk error: regexinventoryexclude=REGEX_PATTERN_INVENTORY_EXCLUDE/none must be set ----"; exit 1; \
	elif grep -Eq "^$(audit) " $(DATABASE_PATH)/db_sync.txt; then \
		$(ECHO) "cawk error: audit=$(audit) already in db_sync.txt, use update ----"; exit 1; \
	else \
		$(ECHO) "$(audit) $(dir) $(regexinventory) $(scope) $(regexos) $(regexpathexclude) $(regexinventoryexclude)" >> $(DATABASE_PATH)/db_sync.txt; \
		if [ "$(scope)" != "none" ] && [ ! -e "$(scope)" ]; then mkdir -p "$$(dirname "$(scope)")" && : > "$(scope)" && $(ECHO) "cawk empty scope file $(scope) created (an empty scope file is no scope: every device is synced) ----"; fi; \
	fi
	$(call sort_database_file,$(DATABASE_PATH)/db_sync.txt)
	$(ECHO) "cawk database_sync_add done ----"

database_sync_update:
	touch $(DATABASE_PATH)/db_sync.txt; \
	if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error: audit= must be set (usage: $(GMAKE) <target> audit=<name>, list the audits with: $(GMAKE) list_audit) ----"; \
	elif [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error: audit $(audit) does not exist (create it with: $(GMAKE) create_audit audit=$(audit), list the audits with: $(GMAKE) list_audit) ----"; \
	elif [ -z "$(dir)" ]; then \
		$(ECHO) "cawk error: dir=SYNC_PATH_DIR must be set ----"; \
	elif [ -z "$(regexinventory)" ]; then \
		$(ECHO) "cawk error: regexinventory=REGEX_PATTERN/.* must be set ----"; \
	elif [ -z "$(scope)" ]; then \
		$(ECHO) "cawk error: scope=SCOPE_FILE/none must be set ----"; \
	elif [ -z "$(regexos)" ]; then \
		$(ECHO) "cawk error: regexos=REGEX_PATTERN_OS/.* must be set ----"; \
	elif [ -z "$(regexpathexclude)" ]; then \
		$(ECHO) "cawk error: regexpathexclude=REGEX_PATTERN_PATH_EXCLUDE/none must be set ----"; \
	elif [ -z "$(regexinventoryexclude)" ]; then \
		$(ECHO) "cawk error: regexinventoryexclude=REGEX_PATTERN_INVENTORY_EXCLUDE/none must be set ----"; \
	else \
		$(ECHO) "cawk update $(DATABASE_PATH)/db_sync.txt"; \
		sed -i "/^$(audit) /d" $(DATABASE_PATH)/db_sync.txt; \
		$(ECHO) "$(audit) $(dir) $(regexinventory) $(scope) $(regexos) $(regexpathexclude) $(regexinventoryexclude)" >> $(DATABASE_PATH)/db_sync.txt; \
		if [ "$(scope)" != "none" ] && [ ! -e "$(scope)" ]; then mkdir -p "$$(dirname "$(scope)")" && : > "$(scope)" && $(ECHO) "cawk empty scope file $(scope) created (an empty scope file is no scope: every device is synced) ----"; fi; \
	fi
	$(call sort_database_file,$(DATABASE_PATH)/db_sync.txt)
	$(ECHO) "cawk database_sync_update done ----"

database_sync_del:
	touch $(DATABASE_PATH)/db_sync.txt; \
	if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error: audit= must be set (usage: $(GMAKE) <target> audit=<name>, list the audits with: $(GMAKE) list_audit) ----"; \
	elif [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error: audit $(audit) does not exist (create it with: $(GMAKE) create_audit audit=$(audit), list the audits with: $(GMAKE) list_audit) ----"; \
	else \
		$(ECHO) "cawk update $(DATABASE_PATH)/db_sync.txt"; \
		sed -i "/^$(audit) /d" $(DATABASE_PATH)/db_sync.txt; \
	fi
	$(call sort_database_file,$(DATABASE_PATH)/db_sync.txt)
	$(ECHO) "cawk database_sync_del done ----"

database_postaudit_add:
	touch $(DATABASE_PATH)/db_postaudit.txt; \
	if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error: audit= must be set (usage: $(GMAKE) <target> audit=<name>, list the audits with: $(GMAKE) list_audit) ----"; exit 1; \
	elif [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error: audit $(audit) does not exist (create it with: $(GMAKE) create_audit audit=$(audit), list the audits with: $(GMAKE) list_audit) ----"; exit 1; \
	elif grep -Eq "^$(audit)$$" $(DATABASE_PATH)/db_postaudit.txt; then \
		$(ECHO) "cawk error: audit=$(audit) already in db_postaudit.txt, use update ----"; exit 1; \
	else \
		$(ECHO) "cawk update $(DATABASE_PATH)/db_postaudit.txt"; \
		$(ECHO) "$(audit)" >> $(DATABASE_PATH)/db_postaudit.txt; \
	fi
	$(call sort_database_file,$(DATABASE_PATH)/db_postaudit.txt)
	$(ECHO) "cawk database_postaudit_add done ----"

database_postaudit_update:
	touch $(DATABASE_PATH)/db_postaudit.txt; \
	if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error: audit= must be set (usage: $(GMAKE) <target> audit=<name>, list the audits with: $(GMAKE) list_audit) ----"; \
	elif [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error: audit $(audit) does not exist (create it with: $(GMAKE) create_audit audit=$(audit), list the audits with: $(GMAKE) list_audit) ----"; \
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
		$(ECHO) "cawk error: audit= must be set (usage: $(GMAKE) <target> audit=<name>, list the audits with: $(GMAKE) list_audit) ----"; \
	elif [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error: audit $(audit) does not exist (create it with: $(GMAKE) create_audit audit=$(audit), list the audits with: $(GMAKE) list_audit) ----"; \
	else \
		$(ECHO) "cawk update $(DATABASE_PATH)/db_postaudit.txt"; \
		sed -i "/^$(audit)$$/d" $(DATABASE_PATH)/db_postaudit.txt; \
	fi
	$(call sort_database_file,$(DATABASE_PATH)/db_postaudit.txt)
	$(ECHO) "cawk database_postaudit_del done ----"

database_email_add:
	touch $(DATABASE_PATH)/db_email.txt; \
	if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error: audit= must be set (usage: $(GMAKE) <target> audit=<name>, list the audits with: $(GMAKE) list_audit) ----"; exit 1; \
	elif [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error: audit $(audit) does not exist (create it with: $(GMAKE) create_audit audit=$(audit), list the audits with: $(GMAKE) list_audit) ----"; exit 1; \
	elif [ -z "$(dst)" ]; then \
		$(ECHO) "cawk error: dst=RECIPIENT_EMAIL must be set ----"; exit 1; \
	elif grep -Eq "^$(audit) " $(DATABASE_PATH)/db_email.txt; then \
		$(ECHO) "cawk error: audit=$(audit) already in db_email.txt, use update ----"; exit 1; \
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
		$(ECHO) "cawk error: audit= must be set (usage: $(GMAKE) <target> audit=<name>, list the audits with: $(GMAKE) list_audit) ----"; \
	elif [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error: audit $(audit) does not exist (create it with: $(GMAKE) create_audit audit=$(audit), list the audits with: $(GMAKE) list_audit) ----"; \
	elif [ -z "$(dst)" ]; then \
		$(ECHO) "cawk error: dst=RECIPIENT_EMAIL must be set ----"; \
	else \
		cc=$(strip $(cc)); \
		if [ -z "$$cc" ]; then cc=none; fi; \
		$(ECHO) "cawk update $(DATABASE_PATH)/db_email.txt"; \
		sed -i "/^$(audit) /d" $(DATABASE_PATH)/db_email.txt; \
		$(ECHO) "$(audit) $(dst) $$cc" >> $(DATABASE_PATH)/db_email.txt; \
	fi
	$(call sort_database_file,$(DATABASE_PATH)/db_email.txt)
	$(ECHO) "cawk database_email_update done ----"

database_email_del:
	touch $(DATABASE_PATH)/db_email.txt
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error: audit= must be set (usage: $(GMAKE) <target> audit=<name>, list the audits with: $(GMAKE) list_audit) ----"
else
	$(ECHO) "cawk update $(DATABASE_PATH)/db_email.txt"
	sed -i "/^${audit} /d" $(DATABASE_PATH)/db_email.txt
	$(call sort_database_file,$(DATABASE_PATH)/db_email.txt)
endif
	$(ECHO) "cawk database_email_del done ----"
