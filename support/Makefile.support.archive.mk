# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

.PHONY: \
  archive_repo archive_run

archive_repo:
	@if [ -n "$$(find reports/repo -name '*.csv' -o -name '*.txt')" ]; then \
		tar -czf reports/repo/archives/repo_$(shell date +%Y-%m-%d).tar.gz $$(find reports/repo -name '*.csv' -o -name '*.txt') || true ;\
		$(ECHO) "cawk build archive in reports/repo/archives/repo_$(shell date +%Y-%m-%d).tar.gz"; \
	else \
		$(ECHO) "cawk no files *.csv and *.txt found in reports/repo, skip the archive ----" ;\
	fi	
	$(ECHO) "cawk archive_repo done ----"

archive_run:
	@if [ -z "$(audit)" ]; then \
		if [ -n "$$(find reports/run -name '*.csv' -o -name '*.txt')" ]; then \
			tar -czf reports/run/archives/run_$(shell date +%Y-%m-%d).tar.gz $$(find reports/run -name '*.csv' -o -name '*.txt') || true; \
			$(ECHO) "cawk build archive in reports/run/archives/run_$(shell date +%Y-%m-%d).tar.gz"; \
		else \
			$(ECHO) "cawk no files *.csv and *.txt found in reports/run, skip the archive ----"; \
		fi; \
	else \
		if [ -n "$$(find reports/run_$(audit) -name '*.csv' -o -name '*.txt')" ]; then \
			tar -czf reports/run_$(audit)/archives/run_$(audit)_$(shell date +%Y-%m-%d).tar.gz $$(find reports/run_$(audit) -name '*.csv' -o -name '*.txt') || true; \
			$(ECHO) "cawk build archive in reports/run_$(audit)/archives/run_$(audit)_$(shell date +%Y-%m-%d).tar.gz"; \
		else \
			$(ECHO) "cawk no files *.csv and *.txt found in reports/run_$(audit), skip the archive ----"; \
		fi; \
	fi
	$(ECHO) "cawk archive_run done ----"
