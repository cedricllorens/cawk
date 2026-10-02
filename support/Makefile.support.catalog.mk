# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

.PHONY: \
  catalog_build catalog_build_repo catalog_build_run catalog_exceptions_repo  \
  catalog_exceptions_run catalog_nist_mappings catalog_repo catalog_run  \
  nist_coverage_official nist_coverage_repo nist_coverage_run

catalog_build_repo: tests_target_common
	if [ -d tests/repo ]; then \
		find tests/repo -type f \( -name "*.m4" -o -name "*.template" -o -name "*.include" \) | sort | while read file; do common/catalog_build_db.gawk repo "$$file"; done ;\
	else \
		$(ECHO) "cawk error: tests/repo directory does not exist ----" ;\
	fi
	$(ECHO) "cawk catalog_build_repo done ----"

catalog_build_run: tests_target_common
ifeq ($(strip $(audit)),)
	if [ -d tests/run ]; then \
		find tests/run -type f \( -name "*.m4" -o -name "*.template" -o -name "*.include" \) | sort | while read file; do common/catalog_build_db.gawk run "$$file"; done ;\
	else \
		$(ECHO) "cawk error: tests/run directory does not exist ----" ;\
	fi
	$(ECHO) "cawk catalog_build_run done ----"
else
	if [ -d tests/run_$(audit) ]; then \
		find tests/run_$(audit) -type f \( -name "*.m4" -o -name "*.template" -o -name "*.include" \) | sort | while read file; do common/catalog_build_db.gawk $(audit) "$$file"; done ;\
	else \
		$(ECHO) "cawk error: tests/run_$(audit) directory does not exist ----" ;\
	fi
	$(ECHO) "cawk catalog_build_run $(audit) done ----"
endif

catalog_build: tests_target_common
	$(RM) -f $(DATABASE_PATH)/db_info.txt
	touch $(DATABASE_PATH)/db_info.txt
	$(GMAKE) catalog_build_repo
	$(GMAKE) catalog_build_run audit=
	@count=$$($(RUN_DIRS_FIND) | wc -l); \
	if [ "$$count" -eq 0 ]; then \
		$(ECHO) "cawk catalog_build: no run audits found, skipping catalog_build_run"; \
	else \
		$(RUN_DIRS_FIND) | while read -r audit; do \
			$(GMAKE) catalog_build_run audit=$$audit; \
		done; \
	fi
	$(GMAKE) catalog_nist_mappings
	$(ECHO) "cawk catalog_build done ----"

catalog_nist_mappings:
	$(TESTS_COMMON_PATH)/catalog_nist_mappings.gawk $(DATABASE_PATH)/db_info.txt > $(DATABASE_PATH)/db_nist_mappings.json
	$(ECHO) "cawk catalog_nist_mappings done - generated $(DATABASE_PATH)/db_nist_mappings.json"

catalog_repo: tests_target_common
	@for supplier in $(shell find confs/repo -maxdepth 1 -type d -name "confs.*" | sed 's|.*/confs\.||' | sort | xargs); do \
		$(ECHO) ""; \
		common/catalog_info.gawk repo $$supplier; \
	done
	$(ECHO) "cawk catalog_repo done ----"

catalog_run: tests_target_common
ifeq ($(strip $(audit)),)
	@for supplier in $(shell find confs/run -maxdepth 1 -type d -name "confs.*" | sed 's|.*/confs\.||' | sort | xargs); do \
		common/catalog_info.gawk run $$supplier; \
	done
	$(ECHO) "cawk catalog_run done ----"
else
	@for supplier in $(shell find confs/run_$(audit) -maxdepth 1 -type d -name "confs.*" | sed 's|.*/confs\.||' | sort | xargs); do \
		common/catalog_info.gawk $(audit) $$supplier; \
	done
	$(ECHO) "cawk catalog_run $(audit) done ----"
endif

nist_coverage_official:
	@$(ECHO) "NIST 800-53 Coverage Analysis (Official)"
	@$(ECHO) "=========================================="
	@total=$$(wc -l < $(DATABASE_PATH)/db_nist800-53.txt); total=$$(($$total - 1)); \
	$(ECHO) "Total NIST 800-53 controls in official benchmark: $$total"; \
	covered=$$(cut -d';' -f7 $(DATABASE_PATH)/db_info.txt | grep -v "to be defined" | grep -v "nist800-53_ref" | cut -d'|' -f1 | sort -u | wc -l); \
	$(ECHO) "NIST 800-53 controls covered by tests: $$covered"; \
	if [ $$total -gt 0 ]; then \
		percent=$$(($$covered * 100 / $$total)); \
		$(ECHO) "Coverage percentage: $$percent%"; \
	fi

nist_coverage_repo: nist_coverage_official
	@$(ECHO) ""
	@$(ECHO) "NIST 800-53 Coverage by Supplier (repo):"
	@$(ECHO) "========================================"
	@for supplier in $(SUPPLIER_SCOPE); do \
		covered=$$(awk -F';' -v s="$$supplier" '$$1=="repo" && $$2==s' $(DATABASE_PATH)/db_info.txt | cut -d';' -f7 | grep -v "to be defined" | sort -u | wc -l); \
		if [ $$covered -gt 0 ]; then \
			$(ECHO) "$$supplier: $$covered controls"; \
		fi \
	done

nist_coverage_run: nist_coverage_official
ifeq ($(strip $(audit)),)
	@$(ECHO) ""
	@$(ECHO) "NIST 800-53 Coverage by Supplier (run):"
	@$(ECHO) "========================================"
	@for supplier in $(SUPPLIER_SCOPE); do \
		covered=$$(awk -F';' -v s="$$supplier" '$$1=="run" && $$2==s' $(DATABASE_PATH)/db_info.txt | cut -d';' -f7 | grep -v "to be defined" | sort -u | wc -l); \
		if [ $$covered -gt 0 ]; then \
			$(ECHO) "$$supplier: $$covered controls"; \
		fi \
	done
else
	@$(ECHO) ""
	@$(ECHO) "NIST 800-53 Coverage by Supplier (run_$(audit)):"
	@$(ECHO) "================================================"
	@for supplier in $(SUPPLIER_SCOPE); do \
		covered=$$(awk -F';' -v s="$$supplier" -v a="$(audit)" '$$1==a && $$2==s' $(DATABASE_PATH)/db_info.txt | cut -d';' -f7 | grep -v "to be defined" | sort -u | wc -l); \
		if [ $$covered -gt 0 ]; then \
			$(ECHO) "$$supplier: $$covered controls"; \
		fi \
	done
endif

catalog_exceptions_repo: tests_target_common
	@first=1; for supplier in $(shell find confs/repo -maxdepth 1 -type d -name "confs.*" | sed 's|.*/confs\.||' | sort | xargs); do \
		if [ $$first -eq 0 ]; then $(ECHO) ""; fi; \
		common/catalog_exceptions_info.gawk repo $$supplier; \
		first=0; \
	done
	$(ECHO) "cawk catalog_exceptions_repo done ----"

catalog_exceptions_run: tests_target_common
ifeq ($(strip $(audit)),)
	@for supplier in $(shell find confs/run -maxdepth 1 -type d -name "confs.*" | sed 's|.*/confs\.||' | sort | xargs); do \
		common/catalog_exceptions_info.gawk run $$supplier; \
	done
	$(ECHO) "cawk catalog_exceptions_run done ----"
else
	@for supplier in $(shell find confs/run_$(audit) -maxdepth 1 -type d -name "confs.*" | sed 's|.*/confs\.||' | sort | xargs); do \
		common/catalog_exceptions_info.gawk $(audit) $$supplier; \
	done
	$(ECHO) "cawk catalog_exceptions_run $(audit) done ----"
endif


