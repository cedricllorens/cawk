# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

.PHONY: \
  sync_exceptionstoconfs_run sync_exceptionstoconfs_run_audit sync_psirt sync_run  \
  sync_run_audit sync_teststoconfs_run sync_teststoconfs_run_audit

sync_run: clean_tmp tests_target_common database_target_sh
	if [ ! -f $(DATABASE_SH_PATH)/database_sync.script ]; then \
		$(ECHO) "cawk error: $(DATABASE_SH_PATH)/database_sync.script does not exist, execution skipped ----"; \
	else \
		$(ECHO) "cawk $(DATABASE_SH_PATH)/database_sync.script execution ----"; \
		$(DATABASE_SH_PATH)/database_sync.script $(audit); \
	fi
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
	$(ECHO) "cawk sync_run done ----"
else
	$(ECHO) "cawk cleaning local configurations before sync : $(CONFS_PATH)/run_$(audit) "
	$(RM) -f -r $(CONFS_PATH)/run_$(audit) || true
	mkdir -p $(CONFS_PATH)/run_$(audit) || true
	$(ECHO) "cawk sync files from $(DATABASE_PATH)/db_sync.txt"
	$(EGREP) "^$(audit) " $(DATABASE_PATH)/db_sync.txt | while read line; do \
		paths=$$($(ECHO) "$$line" | gawk '{print $$2}'); \
		if [ "$$paths" != "none" ]; then \
			regex=$$($(ECHO) "$$line" | gawk '{print $$3}'); \
			scope=$$($(ECHO) "$$line" | gawk '{if ( $$4 == "") { print "none"; } else { print $$4; }}'); \
			regexos=$$($(ECHO) "$$line" | gawk '{if ( $$5 == "") { print "none"; } else { print $$5; }}'); \
			regexpathexclude=$$($(ECHO) "$$line" | gawk '{if ( $$6 == "") { print "none"; } else { print $$6; }}'); \
			cd $(CONFS_PATH)/run_$(audit) && ../../$(COMMON_PATH)/sync_cawk_conf.gawk "$$paths" "$$regex" "../../$$scope" "$$regexos" "$$regexpathexclude" && cd ../.. ; \
		else \
			$(ECHO) "cawk error: $(DATABASE_PATH)/db_sync.txt audit $$($(ECHO) "$$line" | gawk '{print $$1}') path does not exist, execution skipped ----"; \
		fi \
	done
	$(ECHO) "cawk sync_run_audit $(audit) done ----"
endif

sync_run_audit:
	cat $(DATABASE_PATH)/db_sync.txt | while read line; do \
		audit=$$($(ECHO) "$$line" | gawk '{print $$1}'); \
		$(GMAKE) sync_run audit=$$audit; \
	done
	$(GMAKE) list_audit
	$(ECHO) "cawk you may launch <$(GMAKE) sync_teststoconfs_run_audit> to sync tests supplier scope to tests supplier scope ----"
	$(ECHO) "cawk sync_run_audit all audit done ----"

sync_psirt:
	if [ ! -f $(DATABASE_SH_PATH)/database_sync_psirt.script ]; then \
		$(ECHO) "cawk error: $(DATABASE_SH_PATH)/database_sync_psirt.script does not exist, execution skipped ----"; \
	else \
		$(ECHO) "cawk $(DATABASE_SH_PATH)/database_sync_psirt.script execution ----"; \
		$(DATABASE_SH_PATH)/database_sync_psirt.script $(audit); \
	fi
	$(ECHO) "cawk sync_psirt done ----"

sync_teststoconfs_run:
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
	$(ECHO) "cawk sync_teststoconfs_run done ----"
else
	$(ECHO) "\ncawk sync_teststoconfs_run: processing audit $(audit) ----"
	if [ ! -d "$(CONFS_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk sync_teststoconfs_run: confs/run_$(audit) not found, skip ----"; \
		exit 0; \
	fi; \
	find "$(TESTS_PATH)/run_$(audit)" -maxdepth 1 -name "zz.sync.save.*" -type d | sort -r | tail -n +4 | xargs -r rm -rf; \
	keep=""; \
	for s in $(SUPPLIER_SCOPE); do \
		if [ -d "$(CONFS_PATH)/run_$(audit)/confs.$$s" ]; then \
			keep="$$keep $$s"; \
		fi; \
	done; \
	if [ -z "$$keep" ]; then \
		$(ECHO) "cawk sync_teststoconfs_run: no suppliers found in confs/run_$(audit), skip ----"; \
		exit 0; \
	fi; \
	for t in $(TESTS_PATH)/run_$(audit)/tests.*; do \
		if [ ! -e "$$t" ]; then continue; fi; \
		name=$$(basename $$t); \
		sup=$$(echo $$name | sed -e 's/^tests\.//' -e 's/\.psirt$$//' ); \
		found=no; \
		for ks in $$keep; do \
			if [ "$$ks" = "$$sup" ]; then found=yes; break; fi; \
		done; \
		if [ "$$found" = "no" ]; then \
			mv "$$t" "$$(dirname "$$t")/zz.sync.save.$$(basename "$$t").$(shell date +%Y-%m-%d)" || true; \
			$(ECHO) "cawk sync_teststoconfs_run: renamed $$t to $$(dirname "$$t")/zz.sync.save.$$(basename "$$t").$(shell date +%Y-%m-%d) ----"; \
		else \
			$(ECHO) "cawk sync_teststoconfs_run: keep $$t (supplier=$$sup)"; \
		fi; \
	done; \
	$(ECHO) "cawk sync_teststoconfs_run $(audit) done ----"
endif
	$(ECHO) "cawk sync_teststoconfs_run done ----"

sync_teststoconfs_run_audit:
	@for audit in $(RUN_DIRS); do \
		$(GMAKE) sync_teststoconfs_run audit=$$audit; \
	done; \
	$(ECHO) "cawk sync_teststoconfs_run_audit done ----"

sync_exceptionstoconfs_run:
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
	$(ECHO) "cawk sync_exceptionstoconfs_run done ----"
else
	$(ECHO) "\ncawk sync_exceptionstoconfs_run: processing audit $(audit) ----"
	if [ ! -d "$(CONFS_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk sync_exceptionstoconfs_run: confs/run_$(audit) not found, skip ----"; \
		exit 0; \
	fi; \
	find "$(EXCEPTION_PATH)/run_$(audit)" -maxdepth 1 -name "zz.sync.save.*" -type f | sort -r | tail -n +4 | xargs -r rm -f; \
	keep=""; \
	for s in $(SUPPLIER_SCOPE); do \
		if [ -d "$(CONFS_PATH)/run_$(audit)/confs.$$s" ]; then \
			keep="$$keep $$s"; \
		fi; \
	done; \
	if [ -z "$$keep" ]; then \
		$(ECHO) "cawk sync_exceptionstoconfs_run: no suppliers found in confs/run_$(audit), skip ----"; \
		exit 0; \
	fi; \
	for e in $(EXCEPTION_PATH)/run_$(audit)/exceptions.*; do \
		if [ ! -e "$$e" ]; then continue; fi; \
		name=$$(basename $$e); \
		sup=$$(echo $$name | sed -e 's/^exceptions\.//' -e 's/\.m4$$//' ); \
		found=no; \
		for ks in $$keep; do \
			if [ "$$ks" = "$$sup" ]; then found=yes; break; fi; \
		done; \
		if [ "$$found" = "no" ]; then \
			mv "$$e" "$$(dirname "$$e")/zz.sync.save.$$(basename "$$e").$(shell date +%Y-%m-%d)" || true; \
			$(ECHO) "cawk sync_exceptionstoconfs_run: renamed $$e to $$(dirname "$$e")/zz.sync.save.$$(basename "$$e").$(shell date +%Y-%m-%d) ----"; \
		else \
			$(ECHO) "cawk sync_exceptionstoconfs_run: keep $$e (supplier=$$sup)"; \
		fi; \
	done; \
	$(ECHO) "cawk sync_exceptionstoconfs_run $(audit) done ----"
endif
	$(ECHO) "cawk sync_exceptionstoconfs_run done ----"

sync_exceptionstoconfs_run_audit:
	@for audit in $(RUN_DIRS); do \
		$(GMAKE) sync_exceptionstoconfs_run audit=$$audit; \
	done; \
	$(ECHO) "cawk sync_exceptionstoconfs_run_audit done ----"