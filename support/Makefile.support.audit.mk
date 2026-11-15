# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

.PHONY: \
  create_audit delete_audit list_audit check_audit status

# first prerequisite of the audit= targets running a heavy chain: fail before any clean, build or scan
check_audit:
	@if [ -n "$(strip $(audit))" ] && [ ! -d "$(REPORT_PATH)/run_$(strip $(audit))" ]; then \
		$(ECHO) "cawk error: audit $(audit) does not exist (create it with: $(GMAKE) create_audit audit=$(audit), list the audits with: $(GMAKE) list_audit) ----"; \
		exit 1; \
	fi

create_audit:
	if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error: audit= must be set (usage: $(GMAKE) <target> audit=<name>, list the audits with: $(GMAKE) list_audit) ----"; \
		exit 1; \
	elif [ -z "$(supplier)" ]; then \
		if [ -d "$(REPORT_PATH)/run_$(audit)" ]; then \
			$(ECHO) "cawk error: audit=$(audit) already exists ----"; \
			exit 1; \
		else \
			cp -r $(TESTS_PATH)/repo $(TESTS_PATH)/run_$(audit); \
			cp -r $(EXCEPTION_PATH)/repo exceptions/run_$(audit); \
			cp -r $(CONFS_PATH)/repo $(CONFS_PATH)/run_$(audit); \
			mkdir $(REPORT_PATH)/run_$(audit); \
			mkdir $(REPORT_PATH)/run_$(audit)/archives; \
			mkdir $(LOGS_PATH)/run_$(audit); \
		fi; \
	else \
		if [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
			$(ECHO) "cawk error: audit $(audit) does not exist (create it with: $(GMAKE) create_audit audit=$(audit), list the audits with: $(GMAKE) list_audit) ----"; \
			exit 1; \
		else \
			[ -d "$(TESTS_PATH)/repo/tests.$(supplier)" ] && [ ! -d "$(TESTS_PATH)/run_$(audit)/tests.$(supplier)" ] && cp -r "$(TESTS_PATH)/repo/tests.$(supplier)" "$(TESTS_PATH)/run_$(audit)/" || true; \
			[ -d "$(TESTS_PATH)/repo/tests.$(supplier).psirt" ] && [ ! -d "$(TESTS_PATH)/run_$(audit)/tests.$(supplier).psirt" ] && cp -r "$(TESTS_PATH)/repo/tests.$(supplier).psirt" "$(TESTS_PATH)/run_$(audit)/" || true; \
			[ -d "$(CONFS_PATH)/repo/confs.$(supplier)" ] && [ ! -d "$(CONFS_PATH)/run_$(audit)/confs.$(supplier)" ] && cp -r "$(CONFS_PATH)/repo/confs.$(supplier)" "$(CONFS_PATH)/run_$(audit)/" || true; \
			[ -f "$(EXCEPTION_PATH)/repo/exceptions.$(supplier).m4" ] && [ ! -f "$(EXCEPTION_PATH)/run_$(audit)/exceptions.$(supplier).m4" ] && cp "$(EXCEPTION_PATH)/repo/exceptions.$(supplier).m4" "$(EXCEPTION_PATH)/run_$(audit)/" || true; \
		fi; \
	fi
ifeq ($(strip $(supplier)),)
	$(EGREP) -q "^$(audit)$$" $(DATABASE_PATH)/db_postaudit.txt 2>/dev/null || $(GMAKE) database_postaudit_add audit=$(audit)
	$(EGREP) -q "^$(audit) " $(DATABASE_PATH)/db_email.txt 2>/dev/null || $(GMAKE) database_email_add audit=$(audit) dst=none cc=none
	$(EGREP) -q "^$(audit) " $(DATABASE_PATH)/db_collect.txt 2>/dev/null || $(GMAKE) database_collect_add audit=$(audit) collector=none args=none
	$(EGREP) -q "^$(audit) " $(DATABASE_PATH)/db_sync.txt 2>/dev/null || { mkdir -p $(DATABASE_PATH)/sync_scopes && { [ -f $(DATABASE_PATH)/sync_scopes/$(audit)_inventory_sync_scope.txt ] || : > $(DATABASE_PATH)/sync_scopes/$(audit)_inventory_sync_scope.txt; } && $(GMAKE) database_sync_add audit=$(audit) dir=none regexinventory=.* scope=$(DATABASE_PATH)/sync_scopes/$(audit)_inventory_sync_scope.txt regexos=.* regexpathexclude=none regexinventoryexclude=none; }
endif
ifeq ($(strip $(supplier)),)
	$(DATA_SET_SCRIPT) init "$(audit)"
endif
	$(GMAKE) catalog_build_audit audit=$(audit)
	$(GMAKE) exceptions_build
	$(ECHO) "cawk create_audit $(audit) done ----"

delete_audit:
	if [ -z "$(audit)" ]; then \
		$(ECHO) "cawk error: audit= must be set (usage: $(GMAKE) <target> audit=<name>, list the audits with: $(GMAKE) list_audit) ----"; \
		exit 1; \
	elif [ "$(FORCE)" != "yes" ]; then \
		$(ECHO) "cawk error: FORCE=yes must be set to run delete_audit ----"; \
		exit 1; \
	elif [ ! -d "$(REPORT_PATH)/run_$(audit)" ]; then \
		$(ECHO) "cawk error: audit $(audit) does not exist (create it with: $(GMAKE) create_audit audit=$(audit), list the audits with: $(GMAKE) list_audit) ----"; exit 1; \
	elif [ -z "$(supplier)" ]; then \
		$(RM) -f -r $(TESTS_PATH)/run_$(audit); \
		$(RM) -f -r $(CONFS_PATH)/run_$(audit); \
		$(RM) -f -r $(EXCEPTION_PATH)/run_$(audit); \
		$(RM) -f -r $(REPORT_PATH)/run_$(audit); \
		$(RM) -f -r $(REPORT_PATH)/run_$(audit).censored; \
		$(RM) -f -r $(LOGS_PATH)/run_$(audit); \
		$(RM) -f -r $(LOGS_PATH)/run_$(audit).censored; \
		$(RM) -f -r $(CONFS_PATH)/collect_$(audit); \
		$(RM) -f $(DATABASE_PATH)/sync_scopes/collect_$(audit).txt $(DATABASE_PATH)/sync_scopes/$(audit)_inventory_sync_scope.txt; \
		$(RM) -f -r $(DATA_SET_PATH)/run_$(audit); \
		$(EGREP) "^$(audit) " $(DATABASE_PATH)/db_collect.txt > /dev/null 2>&1 && sed -i "/^$(audit) /d" $(DATABASE_PATH)/db_collect.txt || true; \
		$(EGREP) "^$(audit) " $(DATABASE_PATH)/db_sync.txt > /dev/null && sed -i "/^$(audit) /d" $(DATABASE_PATH)/db_sync.txt || true; \
		$(EGREP) "^$(audit)$$" $(DATABASE_PATH)/db_postaudit.txt > /dev/null && sed -i "/^$(audit)$$/d" $(DATABASE_PATH)/db_postaudit.txt || true; \
		$(EGREP) "^$(audit) " $(DATABASE_PATH)/db_email.txt > /dev/null && sed -i "/^$(audit) /d" $(DATABASE_PATH)/db_email.txt || true; \
	else \
		$(RM) -f -r "$(TESTS_PATH)/run_$(audit)/tests.$(supplier)"; \
		$(RM) -f -r "$(TESTS_PATH)/run_$(audit)/tests.$(supplier).psirt"; \
		$(RM) -f -r "$(CONFS_PATH)/run_$(audit)/confs.$(supplier)"; \
		$(RM) -f "$(EXCEPTION_PATH)/run_$(audit)/exceptions.$(supplier).m4"; \
	fi
	$(GMAKE) catalog_build_audit audit=$(audit)
	$(GMAKE) exceptions_build
	$(ECHO) "cawk delete_audit $(audit) done ----"

list_audit:
	$(RUN_DIRS_FIND)
	$(ECHO) "cawk list_audit done ----"

# status : where an audit stands (confs, tests, last assessment, exceptions, censored files) and the next command; without audit= one block per audit
status: check_audit
	@if [ -n "$(strip $(audit))" ]; then sh support/audit_status.sh "$(strip $(audit))"; exit $$?; fi; \
	n=0; bad=0; for d in $(TESTS_PATH)/run_*; do \
		[ -d "$$d" ] || continue; a=$${d#$(TESTS_PATH)/run_}; \
		[ $$n -eq 0 ] || echo; n=$$((n + 1)); \
		sh support/audit_status.sh "$$a" || bad=1; \
	done; \
	if [ $$n -eq 0 ]; then $(ECHO) "cawk status: no audit yet (create one with: $(GMAKE) create_audit audit=<name>) ----"; fi; \
	[ $$bad -eq 0 ] || { $(ECHO) "cawk error: at least one audit is incomplete (see above) ----"; exit 1; }
