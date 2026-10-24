# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

.PHONY: \
  view_repo view_repo_error view_run view_run_error


# supplier= keeps only the lines of the tests of this supplier (same filter as view_*_error)
VIEW_FILTER = $(if $(strip $(supplier)),| { $(EGREP) "\.$(supplier)\.gawk" || true; },)

view_repo: check_supplier
	$(ECHO) "------------------------------------"
	$(ECHO) "---- Assessment all devices" ;\
	$(ECHO) "------------------------------------"
	if [ -f $(REPORT_PATH)/repo/assessment.all$(CSV_EXT) ]; then \
		cat $(REPORT_PATH)/repo/assessment.all$(CSV_EXT) $(VIEW_FILTER); \
	else \
		$(ECHO) "cawk warning: $(REPORT_PATH)/repo/assessment.all$(CSV_EXT) not found, launch <$(GMAKE) check_repo> first ----"; \
	fi
	$(ECHO) "-------------------------"
	$(ECHO) "---- Summary all"
	$(ECHO) "-------------------------"
	if [ -f $(REPORT_PATH)/repo/assessment.all.summary.txt ]; then \
		cat $(REPORT_PATH)/repo/assessment.all.summary.txt; \
	else \
		$(ECHO) "cawk warning: $(REPORT_PATH)/repo/assessment.all.summary.txt not found, launch <$(GMAKE) check_repo> first ----"; \
	fi
	$(ECHO) "cawk view_repo done ----"

view_run: check_supplier
ifeq ($(strip $(audit)),)
	$(ECHO) "------------------------------------"
	$(ECHO) "---- Assessment all devices"
	$(ECHO) "------------------------------------"
	if [ -f $(REPORT_PATH)/run/assessment.all$(CSV_EXT) ]; then \
	cat $(REPORT_PATH)/run/assessment.all$(CSV_EXT) $(VIEW_FILTER); \
	fi; \
	$(ECHO) "-------------------------"
	$(ECHO) "---- Summary all"
	$(ECHO) "-------------------------"
	if [ -f $(REPORT_PATH)/run/assessment.all.summary.txt ]; then \
		cat $(REPORT_PATH)/run/assessment.all.summary.txt; \
	fi
else
ifeq ($(wildcard $(REPORT_PATH)/run_$(audit)/.),)
	$(ECHO) "cawk error audit=$(audit) do not exist ----"
	exit 1
endif
	$(ECHO) "------------------------------------"
	$(ECHO) "---- Assessment $(audit) all devices"
	$(ECHO) "------------------------------------"
	if [ -f $(REPORT_PATH)/run_$(audit)/assessment.all$(CSV_EXT) ]; then \
		cat $(REPORT_PATH)/run_$(audit)/assessment.all$(CSV_EXT) $(VIEW_FILTER) ;\
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
	if [ -f $(REPORT_PATH)/repo/assessment.all$(CSV_EXT) ]; then \
		$(EGREP) ";error" $(REPORT_PATH)/repo/assessment.all$(CSV_EXT); \
	fi
else
	if [ -f $(REPORT_PATH)/repo/assessment.all$(CSV_EXT) ]; then \
		$(EGREP) ";error" $(REPORT_PATH)/repo/assessment.all$(CSV_EXT) | $(EGREP) "\.$(supplier)\.gawk"; \
	fi
endif
	$(ECHO) "cawk view_repo_error done ----"

view_run_error: check_supplier
	$(ECHO) "------------------------------------"
	$(ECHO) "---- Assessment errors"
	$(ECHO) "------------------------------------"
ifeq ($(strip $(audit)),)
ifeq ($(strip $(supplier)),)
	if [ -f $(REPORT_PATH)/run/assessment.all$(CSV_EXT) ]; then \
		$(EGREP) ";error" $(REPORT_PATH)/run/assessment.all$(CSV_EXT); \
	fi
else
	if [ -f $(REPORT_PATH)/run/assessment.all$(CSV_EXT) ]; then \
		$(EGREP) ";error" $(REPORT_PATH)/run/assessment.all$(CSV_EXT) | $(EGREP) "\.$(supplier)\.gawk"; \
	fi
endif
else
ifeq ($(strip $(supplier)),)
	if [ -f $(REPORT_PATH)/run_$(audit)/assessment.all$(CSV_EXT) ]; then \
		$(EGREP) ";error" $(REPORT_PATH)/run_$(audit)/assessment.all$(CSV_EXT); \
	fi
else
	if [ -f $(REPORT_PATH)/run_$(audit)/assessment.all$(CSV_EXT) ]; then \
		$(EGREP) ";error" $(REPORT_PATH)/run_$(audit)/assessment.all$(CSV_EXT) | $(EGREP) "\.$(supplier)\.gawk"; \
	fi
endif
endif
	$(ECHO) "cawk view_run_error done ----"

