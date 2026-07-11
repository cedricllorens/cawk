# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

.PHONY: \
  view_repo view_repo_error view_run view_run_error


view_repo: check_supplier
	$(ECHO) "------------------------------------"
	$(ECHO) "---- Assessment all devices" ;\
	$(ECHO) "------------------------------------"
	cat $(REPORT_PATH)/repo/assessment.all.csv
	$(ECHO) "-------------------------"
	$(ECHO) "---- Summary all"
	$(ECHO) "-------------------------"
	cat $(REPORT_PATH)/repo/assessment.all.summary.txt
	$(ECHO) "cawk view_repo done ----"

view_run: check_supplier
ifeq ($(strip $(audit)),)
	$(ECHO) "------------------------------------"
	$(ECHO) "---- Assessment all devices"
	$(ECHO) "------------------------------------"
	if [ -f $(REPORT_PATH)/run/assessment.all.csv ]; then \
	cat $(REPORT_PATH)/run/assessment.all.csv; \
	fi; \
	$(ECHO) "-------------------------"
	$(ECHO) "---- Summary all"
	$(ECHO) "-------------------------"
	if [ -f $(REPORT_PATH)/run/assessment.all.summary.txt ]; then \
		cat $(REPORT_PATH)/run/assessment.all.summary.txt; \
	fi
else
ifeq ($(wildcard $(REPORT_PATH)/run_$(audit)/.),)
	$(ECHO) "cawk error audit=$(audit) do not exist  ----"
	exit 0
endif
	$(ECHO) "------------------------------------"
	$(ECHO) "---- Assessment $(audit) all devices"
	$(ECHO) "------------------------------------"
	if [ -f $(REPORT_PATH)/run_$(audit)/assessment.all.csv ]; then \
		cat $(REPORT_PATH)/run_$(audit)/assessment.all.csv ;\
	fi
	$(ECHO) "---------------------------------"
	$(ECHO) "---- Summary $(audit) all"
	$(ECHO) "---------------------------------"
	if [ -f $(REPORT_PATH)/run_$(audit)/assessment.all.summary.txt ]; then \
		cat $(REPORT_PATH)/run_$(audit)/assessment.all.summary.txt ;\
	fi
endif
	$(ECHO) "cawk view_run done ----"

view_repo_error: check_supplier
	$(ECHO) "------------------------------------"
	$(ECHO) "---- Assessment errors"
	$(ECHO) "------------------------------------"
ifeq ($(strip $(supplier)),)
	if [ -f $(REPORT_PATH)/repo/assessment.all.csv ]; then \
		cat $(REPORT_PATH)/repo/assessment.all.csv | $(EGREP) ";error"; \
	fi
else
	if [ -f $(REPORT_PATH)/repo/assessment.all.csv ]; then \
		cat $(REPORT_PATH)/repo/assessment.all.csv | $(EGREP) ";error" | $(EGREP) "|$(supplier)|"; \
	fi
endif
	$(ECHO) "cawk view_repo_error done ----"

view_run_error: check_supplier
	$(ECHO) "------------------------------------"
	$(ECHO) "---- Assessment errors"
	$(ECHO) "------------------------------------"
ifeq ($(strip $(audit)),)
ifeq ($(strip $(supplier)),)
	if [ -f $(REPORT_PATH)/run/assessment.all.csv ]; then \
		cat $(REPORT_PATH)/run/assessment.all.csv | $(EGREP) ";error"; \
	fi
else
	if [ -f $(REPORT_PATH)/run/assessment.all.csv ]; then \
		cat $(REPORT_PATH)/run/assessment.all.csv | $(EGREP) ";error" | $(EGREP) "|$(supplier)|"; \
	fi
endif
else
ifeq ($(strip $(supplier)),)
	if [ -f $(REPORT_PATH)/run_$(audit)/assessment.all.csv ]; then \
		cat $(REPORT_PATH)/run_$(audit)/assessment.all.csv | $(EGREP) ";error"; \
	fi
else
	if [ -f $(REPORT_PATH)/run_$(audit)/assessment.all.csv ]; then \
		cat $(REPORT_PATH)/run_$(audit)/assessment.all.csv | $(EGREP) ";error" | $(EGREP) "|$(supplier)|"; \
	fi
endif
endif
	$(ECHO) "cawk view_run_error done ----"

