# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

# Optional configuration collectors (database/collectors/<name>.collector.sh).
#
# A collector is an external script (scp, rsync, local : cawk itself still needs only gawk, gmake and m4)
# fetching the confs from a central unix/linux system, it only fills confs/collect_<audit>. The sync links it into confs/run_<audit> : the sync_paths
# field of db_sync.txt must reference ../collect_<audit>/ (sync=yes or database_collect_sync does it).
#
#   collector --> confs/collect_<audit>/<device> <--(sync_paths)-- sync_run --> confs/run_<audit>/confs.<supplier>/<device>
#
# db_collect.txt : "<audit> <collector> <args>", args = comma-separated key=value pairs without space ("none" if empty).

.PHONY: check_collect collect_run collect_run_audit database_collect_add database_collect_del \
  database_collect_sync database_collect_update

check_collect:
	sh validate/collect/run.sh
	$(ECHO) "cawk check_collect done ----"

database_collect_add:
	touch $(DATABASE_PATH)/db_collect.txt; \
	if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"; \
		exit 1; \
	elif [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error audit=$(audit) do not exist ----"; \
		exit 1; \
	elif [ -z "$(collector)" ]; then \
		$(ECHO) "cawk error collector=COLLECTOR_NAME must be set ----"; \
		exit 1; \
	elif [ "$(collector)" != "none" ] && [ ! -f "$(COLLECTORS_PATH)/$(collector).collector.sh" ]; then \
		$(ECHO) "cawk error collector=$(collector) is unknown ($(COLLECTORS_PATH)/$(collector).collector.sh does not exist) ----"; \
		exit 1; \
	elif printf '%s' "$(args)" | grep -q '[[:space:]]'; then \
		$(ECHO) "cawk error args must not contain a space ----"; \
		exit 1; \
	elif $(EGREP) "^$(audit) " $(DATABASE_PATH)/db_collect.txt | grep -qv "^$(audit) none "; then \
		$(ECHO) "cawk error audit=$(audit) already has a collector, use database_collect_update ----"; \
		exit 1; \
	else \
		sed -i "/^$(audit) none /d" $(DATABASE_PATH)/db_collect.txt; \
		$(ECHO) "$(audit) $(collector) $(if $(strip $(args)),$(strip $(args)),none)" >> $(DATABASE_PATH)/db_collect.txt; \
	fi
	$(call sort_database_file,$(DATABASE_PATH)/db_collect.txt)
	$(if $(filter yes,$(strip $(sync))),$(GMAKE) database_collect_sync audit=$(audit))
	$(ECHO) "cawk database_collect_add done ----"

database_collect_update:
	touch $(DATABASE_PATH)/db_collect.txt; \
	if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"; \
		exit 1; \
	elif [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error audit=$(audit) do not exist ----"; \
		exit 1; \
	elif [ -z "$(collector)" ]; then \
		$(ECHO) "cawk error collector=COLLECTOR_NAME must be set ----"; \
		exit 1; \
	elif [ "$(collector)" != "none" ] && [ ! -f "$(COLLECTORS_PATH)/$(collector).collector.sh" ]; then \
		$(ECHO) "cawk error collector=$(collector) is unknown ($(COLLECTORS_PATH)/$(collector).collector.sh does not exist) ----"; \
		exit 1; \
	elif printf '%s' "$(args)" | grep -q '[[:space:]]'; then \
		$(ECHO) "cawk error args must not contain a space ----"; \
		exit 1; \
	else \
		$(ECHO) "cawk update $(DATABASE_PATH)/db_collect.txt"; \
		sed -i "/^$(audit) /d" $(DATABASE_PATH)/db_collect.txt; \
		$(ECHO) "$(audit) $(collector) $(if $(strip $(args)),$(strip $(args)),none)" >> $(DATABASE_PATH)/db_collect.txt; \
	fi
	$(call sort_database_file,$(DATABASE_PATH)/db_collect.txt)
	$(if $(filter yes,$(strip $(sync))),$(GMAKE) database_collect_sync audit=$(audit))
	$(ECHO) "cawk database_collect_update done ----"

database_collect_del:
	touch $(DATABASE_PATH)/db_collect.txt; \
	if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"; \
		exit 1; \
	else \
		$(ECHO) "cawk update $(DATABASE_PATH)/db_collect.txt"; \
		sed -i "/^$(audit) /d" $(DATABASE_PATH)/db_collect.txt; \
	fi
	$(call sort_database_file,$(DATABASE_PATH)/db_collect.txt)
	$(ECHO) "cawk database_collect_del done ----"

# Adds ../collect_<audit>/ to the sync_paths (field 2) of the audit in db_sync.txt, once.
database_collect_sync:
	@if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"; \
		exit 1; \
	elif ! $(EGREP) -q "^$(audit) " $(DATABASE_PATH)/db_sync.txt 2>/dev/null; then \
		$(ECHO) "cawk error: no $(DATABASE_PATH)/db_sync.txt entry for audit=$(audit) (create_audit adds it) ----"; \
		exit 1; \
	else \
		mkdir -p $(TESTS_TMP); \
		gawk -v audit="$(audit)" -v link="../collect_$(audit)/" '$$1 == audit { n = split($$2, p, ","); found = 0; for (i = 1; i <= n; i++) if (p[i] == link) found = 1; if (!found) $$2 = ($$2 == "none" ? link : $$2 "," link) } { print }' $(DATABASE_PATH)/db_sync.txt > $(TESTS_TMP)/db_sync.collect.$(audit) \
			&& cat $(TESTS_TMP)/db_sync.collect.$(audit) > $(DATABASE_PATH)/db_sync.txt; \
		rm -f $(TESTS_TMP)/db_sync.collect.$(audit); \
	fi
	$(ECHO) "cawk database_collect_sync done ----"

collect_run:
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
	exit 1
else
	mkdir -p $(LOGS_PATH)/run_$(audit)
	@line=$$($(EGREP) "^$(audit) " $(DATABASE_PATH)/db_collect.txt 2>/dev/null || true); \
	collector=$$($(ECHO) "$$line" | gawk '{print $$2}'); \
	if [ -z "$$line" ] || [ "$$collector" = "none" ]; then \
		$(ECHO) "cawk no collector configured for audit=$(audit) in $(DATABASE_PATH)/db_collect.txt, skip ----"; \
	else \
		args=$$($(ECHO) "$$line" | gawk '{if ($$3 == "") { print "none"; } else { print $$3; }}'); \
		script=$(COLLECTORS_PATH)/$$collector.collector.sh; \
		dest=$(CONFS_PATH)/collect_$(audit); \
		paths=$$($(EGREP) "^$(audit) " $(DATABASE_PATH)/db_sync.txt 2>/dev/null | gawk '{print $$2}'); \
		case ",$$paths," in \
			*"collect_$(audit)/,"*|*"collect_$(audit),"*) ;; \
			*) $(ECHO) "cawk error: $(DATABASE_PATH)/db_sync.txt audit=$(audit) sync_paths does not reference ../collect_$(audit)/, the collected configurations will not be synced (run: $(GMAKE) database_collect_sync audit=$(audit)) ----" ;; \
		esac; \
		if [ ! -f "$$script" ]; then \
			$(ECHO) "cawk error: $$script does not exist ----"; \
			exit 1; \
		fi; \
		$(ECHO) "cawk $$script execution ----"; \
		mkdir -p $$dest; \
		sh $$script $(audit) $$dest "$$args" 2>$(LOGS_PATH)/run_$(audit)/collect.$(audit).err || { $(ECHO) "cawk error: collector $$collector failed for $(audit), the previous configurations are kept (see $(LOGS_PATH)/run_$(audit)/collect.$(audit).err) ----"; exit 1; }; \
	fi
	$(ECHO) "cawk collect_run $(audit) done ----"
endif

collect_run_audit:
	@rc=0; \
	touch $(DATABASE_PATH)/db_collect.txt; \
	while read -r audit rest; do \
		[ -n "$$audit" ] || continue; \
		$(GMAKE) collect_run audit=$$audit || rc=1; \
	done < $(DATABASE_PATH)/db_collect.txt; \
	$(ECHO) "cawk collect_run_audit done ----"; \
	exit $$rc
