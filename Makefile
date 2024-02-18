# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# cawk is Copyright (C) 2024 by Cedric Llorens
# ------------------------------------------------------------
#
# Makefile
# - gmake 		: provide information on cawk running
# - gmake supplier 	: provide the suppliers covered by cawk
# - gmake clean 	: clean all 
# - gmake tests_repo 	: build all <repo> tests
# - gmake tests_run 	: build all <run> tests
# - gmake check_repo 	: assess the confs with <repo> tests
#   or gmake check_repo supplier=cisco-ios (or juniper-junos, etc.)
# - gmake check_run 	: assess the confs with <run> tests
#   or gmake check_run supplier=cisco-ios (or juniper-junos, etc.)
# - gmake view 		: view the assessment reports (and summary)
#   or gmake view supplier=cisco-ios (or juniper-junos, etc.)
# - gmake catalog 	: build the tests description catalog
# ------------------------------------------------------------

CAWK_RELEASE = v1.0.0

# --------------- CAWK VARS

TESTS_COMMON_PATH = common
TESTS_COMMON_TEMPLATE = $(wildcard $(TESTS_COMMON_PATH)/*.template)

CONFIGURATION_cisco-ios_PATH = conf/conf.cisco-ios
TESTS_cisco-ios_REPO_PATH = tests/tests.cisco-ios/repo
TESTS_cisco-ios_RUN_PATH = tests/tests.cisco-ios/run
TESTS_cisco-ios_REPO_TEMPLATE = $(wildcard $(TESTS_cisco-ios_REPO_PATH)/*.template)
TESTS_cisco-ios_RUN_TEMPLATE = $(wildcard $(TESTS_cisco-ios_RUN_PATH)/*.template)

CONFIGURATION_juniper-junos_PATH = conf/conf.juniper-junos
TESTS_juniper-junos_REPO_PATH = tests/tests.juniper-junos/repo
TESTS_juniper-junos_RUN_PATH = tests/tests.juniper-junos/run
TESTS_juniper-junos_REPO_TEMPLATE = $(wildcard $(TESTS_juniper-junos_REPO_PATH)/*.template)
TESTS_juniper-junos_RUN_TEMPLATE = $(wildcard $(TESTS_juniper-junos_RUN_PATH)/*.template)

CONFIGURATION_huawei-vrp_PATH = conf/conf.huawei-vrp
TESTS_huawei-vrp_REPO_PATH = tests/tests.huawei-vrp/repo
TESTS_huawei-vrp_RUN_PATH = tests/tests.huawei-vrp/run
TESTS_huawei-vrp_REPO_TEMPLATE = $(wildcard $(TESTS_huawei-vrp_REPO_PATH)/*.template)
TESTS_huawei-vrp_RUN_TEMPLATE = $(wildcard $(TESTS_huawei-vrp_RUN_PATH)/*.template)

CONFIGURATION_fortinet-fortios_PATH = conf/conf.fortinet-fortios
TESTS_fortinet-fortios_REPO_PATH = tests/tests.fortinet-fortios/repo
TESTS_fortinet-fortios_RUN_PATH = tests/tests.fortinet-fortios/run
TESTS_fortinet-fortios_REPO_TEMPLATE = $(wildcard $(TESTS_fortinet-fortios_REPO_PATH)/*.template)
TESTS_fortinet-fortios_RUN_TEMPLATE = $(wildcard $(TESTS_fortinet-fortios_RUN_PATH)/*.template)

TESTS_REPORT = report

SUPPLIER_SCOPE = cisco-ios juniper-junos huawei-vrp fortinet-fortios

TESTS_CATALOG = $(TESTS_cisco-ios_REPO_PATH) \
		$(TESTS_juniper-junos_REPO_PATH) \
		$(TESTS_huawei-vrp_REPO_PATH) \
		$(TESTS_fortinet-fortios_REPO_PATH)
TESTS_CATALOG_RUN = $(TESTS_cisco-ios_RUN_PATH) \
		$(TESTS_juniper-junos_RUN_PATH) \
		$(TESTS_huawei-vrp_RUN_PATH) \
		$(TESTS_fortinet-fortios_RUN_PATH)

# --------------- TESTS BUILDING BY SED CHANGE

%.gawk: %.gawk.template
	sed -f support/tests.sed $< > $@ || true
	chmod 750 $@

# --------------- GNU MAKE TARGETS

.phony: all check_repo check_run tests view clean_report clean catalog git supplier check_supplier

all:
	# ------------------------------------------------------------
	# - gmake 		: provide information on cawk running
	# - gmake supplier 	: provide the suppliers supported by cawk
	# - gmake clean 	: clean all 
	# - gmake tests_repo 	: build all <repo> tests
	# - gmake tests_run 	: build all <run> tests
	# - gmake check_repo 	: assess the confs with <repo> tests
	#   or gmake check_repo supplier=cisco-ios (or view_juniper-junos, etc.)
	# - gmake check_run 	: assess the confs with <run> tests
	#   or gmake check_run supplier=cisco-ios (or view_juniper-junos, etc.)
	# - gmake view		: view the reports and the summary
	#   or gmake view supplier=cisco-ios (or view_juniper-junos, etc.)
	# - gmake catalog 	: build the tests description catalog
	# ------------------------------------------------------------

# --------------------------------

check_supplier:
ifneq ($(strip $(supplier)),)
ifneq ($(findstring $(supplier),$(SUPPLIER_SCOPE)),$(supplier))
	@$(error supplier : ($(supplier)) is not the list of suppliers covered by cawk ($(SUPPLIER_SCOPE)))
endif
endif

supplier:
	@echo "cawk supplier start ----"
	@echo "cawk --- the list of suppliers supported by cawk is:"
	@echo $(SUPPLIER_SCOPE)
	@echo "cawk supplier done ----"

# --------------------------------

tests_repo: $(TESTS_COMMON_TEMPLATE:.gawk.template=.gawk) $(TESTS_cisco-ios_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_juniper-junos_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_huawei-vrp_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_fortinet-fortios_REPO_TEMPLATE:.gawk.template=.gawk)
	@echo "cawk tests_repo done ----"

tests_run: $(TESTS_COMMON_TEMPLATE:.gawk.template=.gawk) $(TESTS_cisco-ios_RUN_TEMPLATE:.gawk.template=.gawk) $(TESTS_juniper-junos_RUN_TEMPLATE:.gawk.template=.gawk) $(TESTS_huawei-vrp_RUN_TEMPLATE:.gawk.template=.gawk) $(TESTS_fortinet-fortios_RUN_TEMPLATE:.gawk.template=.gawk)
	@echo "cawk tests_run done ----"

# --------------------------------

check_repo: clean_report $(TESTS_COMMON_TEMPLATE:.gawk.template=.gawk) $(TESTS_cisco-ios_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_juniper-junos_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_huawei-vrp_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_fortinet-fortios_REPO_TEMPLATE:.gawk.template=.gawk) check_supplier
	@echo "cawk check_repo start ----"
ifeq ($(strip $(supplier)),)
	@$(foreach scope,$(SUPPLIER_SCOPE),\
		echo "cawk ---- compute $(scope) devices ----" ;\
		touch $(TESTS_REPORT)/assessment.$(scope).csv ;\
		$(foreach test,$(TESTS_$(scope)_REPO_TEMPLATE:.gawk.template=.gawk),\
			find $(CONFIGURATION_$(scope)_PATH) -type f -exec ./$(test) {} \; >> $(TESTS_REPORT)/assessment.$(scope).csv ;\
		) \
		$(TESTS_COMMON_PATH)/report.gawk $(TESTS_REPORT)/assessment.$(scope).csv > $(TESTS_REPORT)/assessment.$(scope).summary.txt ;\
	)
else
	@echo "cawk ---- compute $(supplier) devices ----"
	@touch $(TESTS_REPORT)/assessment.$(supplier).csv
	@$(foreach test,$(TESTS_$(supplier)_REPO_TEMPLATE:.gawk.template=.gawk),\
		find $(CONFIGURATION_$(supplier)_PATH) -type f -exec ./$(test) {} \; >> $(TESTS_REPORT)/assessment.$(supplier).csv ;\
	)
	$(TESTS_COMMON_PATH)/report.gawk $(TESTS_REPORT)/assessment.$(supplier).csv > $(TESTS_REPORT)/assessment.$(supplier).summary.txt
endif
	@echo "cawk check_repo done ----"

check_run: clean_report $(TESTS_COMMON_TEMPLATE:.gawk.template=.gawk) $(TESTS_cisco-ios_RUN_TEMPLATE:.gawk.template=.gawk) $(TESTS_juniper-junos_RUN_TEMPLATE:.gawk.template=.gawk) $(TESTS_huawei-vrp_RUN_TEMPLATE:.gawk.template=.gawk) $(TESTS_fortinet-fortios_RUN_TEMPLATE:.gawk.template=.gawk) check_supplier
	@echo "cawk check_run start ----"
ifeq ($(strip $(supplier)),)
	@$(foreach scope,$(SUPPLIER_SCOPE),\
		echo "cawk ---- compute $(scope) devices ----" ;\
		touch $(TESTS_REPORT)/assessment.$(scope).csv ;\
		$(foreach test,$(TESTS_$(scope)_RUN_TEMPLATE:.gawk.template=.gawk),\
			find $(CONFIGURATION_$(scope)_PATH) -type f -exec ./$(test) {} \; >> $(TESTS_REPORT)/assessment.$(scope).csv ;\
		)
		$(TESTS_COMMON_PATH)/report.gawk $(TESTS_REPORT)/assessment.$(scope).csv > $(TESTS_REPORT)/assessment.$(scope).summary.txt ;\
	)
else
	@echo "cawk ---- compute $(supplier) devices ----"
	@touch $(TESTS_REPORT)/assessment.$(supplier).csv
	@$(foreach test,$(TESTS_$(supllier)_RUN_TEMPLATE:.gawk.template=.gawk),\
		find $(CONFIGURATION_$(supplier)_PATH) -type f -exec ./$(test) {} \; >> $(TESTS_REPORT)/assessment.$(supplier).csv ;\
	) \
	$(TESTS_COMMON_PATH)/report.gawk $(TESTS_REPORT)/assessment.$(supplier).csv > $(TESTS_REPORT)/assessment.$(supplier).summary.txt
endif
	@echo "cawk check_run done ----"

# --------------------------------

check_supplier:
ifneq ($(findstring $(supplier),$(SUPPLIER_SCOPE)),$(supplier))
	@$(error supplier : ($(supplier)) is not the list of suppliers covered by cawk ($(SUPPLIER_SCOPE)))
endif

view: check_supplier
	@echo "cawk view start ----"
ifeq ($(strip $(supplier)),)
	@$(foreach test,$(SUPPLIER_SCOPE),\
		echo "---- Assessment $(test) devices ----" ;\
		cat $(TESTS_REPORT)/assessment.$(test).csv ;\
		echo "---- summary ----" ;\
		cat $(TESTS_REPORT)/assessment.$(test).summary.txt ;\
	)
else
	@echo "cawk ---- Assessment $(supplier) devices ----"
	@cat $(TESTS_REPORT)/assessment.$(supplier).csv
	@echo "cawk ---- summary ----"
	@cat $(TESTS_REPORT)/assessment.$(supplier).summary.txt
endif
	@echo "cawk view done ----"

# --------------------------------

clean: clean_report
	@echo "cawk clean start ----"
	rm -f $(TESTS_COMMON_PATH)/*.gawk
	$(foreach scope,$(SUPPLIER_SCOPE),\
		rm -f $(TESTS_$(scope)_REPO_PATH)/*.gawk $(TESTS_$(scope)_RUN_PATH)/*.gawk ;\
	)
	@echo "cawk clean done ----"

clean_report:
	@rm -f $(TESTS_REPORT)/*

# --------------------------------

catalog:
	@echo "cawk start done ----"
	@echo "---- Tests <repo> catalog ----"
	@$(foreach id,$(TESTS_CATALOG),\
		grep -H purpose $(id)/*template | sed -e 's/# purpose ://g' || true;\
	)

	@echo "---- Tests <run> catalog ----"
	@$(foreach id,$(TESTS_CATALOG_RUN),\
		grep -H purpose $(id)/*template | sed -e 's/# purpose ://g' || true;\
	)
	@echo "cawk catalog done ----"

# --------------------------------

git:
	# --------
	# regular update
	#      git add .
	#      git commit -m "msg"
	# --------
	# push of a new version
	#      	git push https://github.com/cedricllorens/cawk.git master
	# build a release directly at github level
	#	git pull https://github.com/cedricllorens/cawk.git master --rebase
