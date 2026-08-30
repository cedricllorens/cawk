# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

.PHONY: \
  backup_run backup_run_audit migrate restore_run  \
  restore_run_audit

backup_run: clean
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
	$(ECHO) "cawk backup_run done ----"
else
	$(RM) -f backup/run_audit_$(audit)_$(shell date +%Y-%m-%d).tar.gz backup/run_audit_$(audit)_$(shell date +%Y-%m-%d).tar
	find confs/run_$(audit) -type l -exec rm {} \; 2>/dev/null || true
	find confs/run_$(audit) logs/run_$(audit) tests/run_$(audit) exceptions/run_$(audit) reports/run_$(audit) -type f -print0 | tar cvf backup/run_audit_$(audit)_$(shell date +%Y-%m-%d).tar --null -T - >/dev/null 2>&1
	gzip backup/run_audit_$(audit)_$(shell date +%Y-%m-%d).tar
	$(ECHO) "cawk backup_run_audit $(audit) done in backup/run_audit_$(audit)_$(shell date +%Y-%m-%d).tar.gz ----"
endif

backup_run_audit: clean
	$(RM) -f backup/run_audit_$(shell date +%Y-%m-%d).tar backup/run_audit_$(shell date +%Y-%m-%d).tar.gz
	find confs/run_* -type l -exec rm {} \; 2>/dev/null || true
	find $(DATABASE_PATH)/* logs/run_* confs/run_* tests/run_* exceptions/run_* reports/run_* -type f -print0 | tar cvf backup/run_audit_$(shell date +%Y-%m-%d).tar --null -T - >/dev/null 2>&1
	gzip backup/run_audit_$(shell date +%Y-%m-%d).tar
	$(GMAKE) list_audit
	$(ECHO) "cawk backup_run_audit all audits done in backup/run_audit_$(shell date +%Y-%m-%d).tar.gz ----"

restore_run: clean
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME and file=BACKUP_PATH_FILE must be set ----"
	$(ECHO) "cawk restore_run done ----"
else
ifeq ($(strip $(file)),)
	$(ECHO) "cawk error audit=AUDIT_NAME and file=BACKUP_PATH_FILE must be set ----"
	$(ECHO) "cawk restore_run done ----"
else
	if [ -f $(file) ]; then \
		tar -xzvf $(file) >/dev/null 2>&1; \
		$(ECHO) "cawk restore_run $(audit) done ----"; \
	else \
		$(ECHO) "cawk error: file $(file) does not exist ----"; \
	fi
endif
endif
	mkdir -p confs/run_$(audit) 2>/dev/null || true
	$(ECHO) "cawk creates audit confs directory (empty case): confs/run_$(audit)"

restore_run_audit: clean
ifeq ($(strip $(file)),)
	$(ECHO) "cawk error file=BACKUP_PATH_FILE must be set ----"
	$(ECHO) "cawk restore_run_audit done ----"
else
	if [ -f $(file) ]; then \
		tar -xzvf $(file) >/dev/null 2>&1; \
		$(ECHO) "cawk restore_run_audit done ----"; \
	else \
		$(ECHO) "cawk error: file $(file) does not exist ----"; \
	fi
endif
	@for dir in $$(find -L tests -name '*run_*' -type d | grep -o 'run_[^/]*'); do \
		mkdir -p confs/$$dir 2>/dev/null || true; \
		$(ECHO) "cawk creates audit directory (empty case): confs/$$dir"; \
	done

migrate:
ifeq ($(strip $(file)),)
	$(ECHO) "cawk error file=BACKUP_PATH_FILE must be set ----"
	exit 0
endif
	cp $(file) backup/
	$(GMAKE) restore_run_audit file=backup/$(notdir $(file))
	$(GMAKE) tests_run_audit_copy
	$(GMAKE) exceptions_run_audit_copy
	$(GMAKE) catalog_build
	$(GMAKE) exceptions_build
