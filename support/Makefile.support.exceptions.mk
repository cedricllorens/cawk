# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

.PHONY: \
  exceptions_build exceptions_build_repo exceptions_build_run exceptions_repo  \
  exceptions_run exceptions_run_audit_copy exceptions_run_copy

exceptions_repo:
	$(foreach exc,$(wildcard $(EXCEPTION_PATH)/repo/*.m4),m4 -I m4 $(exc) | sed '/^$$/d' > $(basename $(exc)) || true ; chmod 650 $(basename $(exc)) ;)
	$(ECHO) "cawk exceptions_repo done ----"

exceptions_run:
ifeq ($(strip $(audit)),)
	$(foreach exc,$(wildcard $(EXCEPTION_PATH)/run/*.m4),m4 -I m4 $(exc) | sed '/^$$/d' > $(basename $(exc)) || true ; chmod 650 $(basename $(exc)) ;)
else
	$(foreach exc,$(wildcard $(EXCEPTION_PATH)/run_$(audit)/*.m4),m4 -I m4 $(exc) | sed '/^$$/d' > $(basename $(exc)) || true ; chmod 650 $(basename $(exc)) ;)
endif
	$(ECHO) "cawk exceptions_run done ----"

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
	@RUN_DIRS="$$(find -L exceptions -name '*run_*' -type d 2>/dev/null | awk -F'run_' '{print $$NF}' | sort -u || echo '')"; \
	if [ -z "$$RUN_DIRS" ]; then \
		$(ECHO) "cawk exceptions_build: no run audits found, skipping exceptions_build_run"; \
	else \
		for audit in $$RUN_DIRS; do \
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
	for dir in $(RUN_DIRS); do \
		$(GMAKE) exceptions_run_copy audit=$$dir; \
	done
	$(ECHO) "cawk exceptions_run_audit_copy done ----"


