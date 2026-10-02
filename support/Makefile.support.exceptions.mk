# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

.PHONY: \
  exceptions_build exceptions_build_repo exceptions_build_run exceptions_repo  \
  exceptions_run exceptions_run_audit exceptions_run_audit_copy exceptions_run_copy

exceptions_repo:
	mkdir -p $(LOGS_PATH)/repo
	: > $(LOGS_PATH)/repo/exceptions.repo.err
	$(call cawk_exceptions_compile,$(EXCEPTION_PATH)/repo,$(LOGS_PATH)/repo/exceptions.repo.err)
	@if [ -s $(LOGS_PATH)/repo/exceptions.repo.err ]; then \
		$(ECHO) "cawk error: exceptions_repo failed (see $(LOGS_PATH)/repo/exceptions.repo.err) ----"; \
		exit 1; \
	fi
	$(ECHO) "cawk exceptions_repo done ----"

exceptions_run:
ifeq ($(strip $(audit)),)
	mkdir -p $(LOGS_PATH)/run
	: > $(LOGS_PATH)/run/exceptions.run.err
	$(call cawk_exceptions_compile,$(EXCEPTION_PATH)/run,$(LOGS_PATH)/run/exceptions.run.err)
	@if [ -s $(LOGS_PATH)/run/exceptions.run.err ]; then \
		$(ECHO) "cawk error: exceptions_run failed (see $(LOGS_PATH)/run/exceptions.run.err) ----"; \
		exit 1; \
	fi
else
	mkdir -p $(LOGS_PATH)/run_$(audit)
	: > $(LOGS_PATH)/run_$(audit)/exceptions.$(audit).err
	$(call cawk_exceptions_compile,$(EXCEPTION_PATH)/run_$(audit),$(LOGS_PATH)/run_$(audit)/exceptions.$(audit).err)
	@if [ -s $(LOGS_PATH)/run_$(audit)/exceptions.$(audit).err ]; then \
		$(ECHO) "cawk error: exceptions_run failed for $(audit) (see $(LOGS_PATH)/run_$(audit)/exceptions.$(audit).err) ----"; \
		exit 1; \
	fi
endif
	$(ECHO) "cawk exceptions_run done ----"

exceptions_run_audit:
	$(RUN_DIRS_FIND) | while read -r audit; do \
		$(GMAKE) exceptions_run audit=$$audit; \
	done
	$(ECHO) "cawk exceptions_run_audit done ----"

exceptions_build_repo: tests_target_common
	if [ -d exceptions/repo ]; then \
		find exceptions/repo -type f -name "*.m4" | sort | while read file; do common/catalog_build_exceptions_db.gawk repo "$$file"; done ;\
	else \
		$(ECHO) "cawk error: exceptions/repo directory does not exist ----" ;\
	fi
	$(ECHO) "cawk exceptions_build_repo done ----"

exceptions_build_run: tests_target_common
ifeq ($(strip $(audit)),)
	if [ -d exceptions/run ]; then \
		find exceptions/run -type f -name "*.m4" | sort | while read file; do common/catalog_build_exceptions_db.gawk run "$$file"; done ;\
	else \
		$(ECHO) "cawk error: exceptions/run directory does not exist ----" ;\
	fi
	$(ECHO) "cawk exceptions_build_run done ----"
else
	if [ -d exceptions/run_$(audit) ]; then \
		find exceptions/run_$(audit) -type f -name "*.m4" | sort | while read file; do common/catalog_build_exceptions_db.gawk $(audit) "$$file"; done ;\
	else \
		$(ECHO) "cawk error: exceptions/run_$(audit) directory does not exist ----" ;\
	fi
	$(ECHO) "cawk exceptions_build_run $(audit) done ----"
endif

exceptions_build: tests_target_common
	$(RM) -f $(DATABASE_PATH)/db_exception.txt
	touch $(DATABASE_PATH)/db_exception.txt
	$(GMAKE) exceptions_build_repo
	$(GMAKE) exceptions_build_run audit=
	@count=$$(find -L exceptions -name '*run_*' -type d 2>/dev/null | wc -l); \
	if [ "$$count" -eq 0 ]; then \
		$(ECHO) "cawk exceptions_build: no run audits found, skipping exceptions_build_run"; \
	else \
		find -L exceptions -name '*run_*' -type d 2>/dev/null | awk -F'run_' '{print $$NF}' | sort -u | while read -r audit; do \
			$(GMAKE) exceptions_build_run audit=$$audit; \
		done; \
	fi
	$(ECHO) "cawk exceptions_build done ----"

# -----
# NO OVERWRITE : if exceptions exist at target, exceptions are not copied
# -----
exceptions_run_copy:
	@RUN_TARGET="$(EXCEPTION_PATH)/run"; \
	if [ -n "$(audit)" ]; then RUN_TARGET="$(EXCEPTION_PATH)/run_$(audit)"; fi; \
	$(ECHO) "cawk exceptions_run_copy to $$RUN_TARGET start ----"; \
	mkdir -p $$RUN_TARGET || true; \
	for file in $(EXCEPTION_PATH)/repo/*.m4; do \
		if [ ! -f "$$RUN_TARGET/$$(basename $$file)" ]; then \
			cp -v $$file $$RUN_TARGET/ 2>/dev/null || true; \
		else \
			$(ECHO) "cawk skip $$(basename $$file) already exist in $$RUN_TARGET ----"; \
		fi; \
	done; \
	$(ECHO) "cawk exceptions_run_copy to $$RUN_TARGET done ----"

exceptions_run_audit_copy:
	$(RUN_DIRS_FIND) | while read -r dir; do \
		$(GMAKE) exceptions_run_copy audit=$$dir; \
	done
	$(ECHO) "cawk exceptions_run_audit_copy done ----"


