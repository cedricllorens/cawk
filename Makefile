# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# cawk is Copyright (C) 2024 by Cedric Llorens
# ------------------------------------------------------------
#
# Makefile
# - gmake 		: provide information on cawk running
# - gmake system	: allow to know if the system can run cawk
# - gmake supplier 	: provide the suppliers covered by cawk
# - gmake clean 	: clean all 
# - gmake tests_repo 	: build all <repo> tests
# - gmake tests_run 	: build all <run> tests
# - gmake check_repo 	: assess the confs with <repo> tests
#   or gmake clean check_repo supplier=cisco-ios (or juniper-junos, etc.)
# - gmake check_run 	: assess the confs with <run> tests
#   or gmake clean check_run supplier=cisco-ios (or juniper-junos, etc.)
# - gmake view 		: view the assessment reports (and summary)
#   or gmake clean check_repo view supplier=cisco-ios (or juniper-junos, etc.)
#   or gmake clean check_run view supplier=cisco-ios (or juniper-junos, etc.)
# - gmake catalog 	: build the tests description catalog
# ------------------------------------------------------------

# ---------------

include Makefile.support.mk

# ---------------

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

CONFIGURATION_nokia-sros_PATH = conf/conf.nokia-sros
TESTS_nokia-sros_REPO_PATH = tests/tests.nokia-sros/repo
TESTS_nokia-sros_RUN_PATH = tests/tests.nokia-sros/run
TESTS_nokia-sros_REPO_TEMPLATE = $(wildcard $(TESTS_nokia-sros_REPO_PATH)/*.template)
TESTS_nokia-sros_RUN_TEMPLATE = $(wildcard $(TESTS_nokia-sros_RUN_PATH)/*.template)

CONFIGURATION_paloalto-panos_PATH = conf/conf.paloalto-panos
TESTS_paloalto-panos_REPO_PATH = tests/tests.paloalto-panos/repo
TESTS_paloalto-panos_RUN_PATH = tests/tests.paloalto-panos/run
TESTS_paloalto-panos_REPO_TEMPLATE = $(wildcard $(TESTS_paloalto-panos_REPO_PATH)/*.template)
TESTS_paloalto-panos_RUN_TEMPLATE = $(wildcard $(TESTS_paloalto-panos_RUN_PATH)/*.template)

CONFIGURATION_cisco-viptela_PATH = conf/conf.cisco-viptela
TESTS_cisco-viptela_REPO_PATH = tests/tests.cisco-viptela/repo
TESTS_cisco-viptela_RUN_PATH = tests/tests.cisco-viptela/run
TESTS_cisco-viptela_REPO_TEMPLATE = $(wildcard $(TESTS_cisco-viptela_REPO_PATH)/*.template)
TESTS_cisco-viptela_RUN_TEMPLATE = $(wildcard $(TESTS_cisco-viptela_RUN_PATH)/*.template)

TESTS_REPORT = report

TESTS_SYSTEM = system

TESTS_TMP = tmp

SUPPLIER_SCOPE = cisco-ios cisco-viptela juniper-junos huawei-vrp fortinet-fortios nokia-sros paloalto-panos

TESTS_CATALOG = $(TESTS_cisco-ios_REPO_PATH) \
		$(TESTS_cisco-viptela_REPO_PATH) \
		$(TESTS_juniper-junos_REPO_PATH) \
		$(TESTS_huawei-vrp_REPO_PATH) \
		$(TESTS_fortinet-fortios_REPO_PATH) \
		$(TESTS_nokia-sros_REPO_PATH) \
		$(TESTS_paloalto-panos_REPO_PATH)

TESTS_CATALOG_RUN = $(TESTS_cisco-ios_RUN_PATH) \
		$(TESTS_cisco-viptela_RUN_PATH) \
		$(TESTS_juniper-junos_RUN_PATH) \
		$(TESTS_huawei-vrp_RUN_PATH) \
		$(TESTS_fortinet-fortios_RUN_PATH) \
		$(TESTS_nokia-sros_RUN_PATH) \
		$(TESTS_paloalto-panos_RUN_PATH)

# --------------- TESTS BUILDING BY SED CHANGE

%.gawk: %.gawk.template
	sed -f support/tests.sed $< > $@ || true
	chmod 750 $@

# --------------- GNU MAKE TARGETS

.PHONY: all check_repo check_run tests tests_target view clean_report clean_tmp clean catalog git supplier check_supplier system

all:
	# ------------------------------------------------------------
	# - gmake 		: provide information on cawk running
	# - gmake system	: allow to know if the system can run cawk
	# - gmake supplier 	: provide the suppliers supported by cawk
	# - gmake clean 	: clean all 
	# - gmake tests_repo 	: build all <repo> tests
	# - gmake tests_run 	: build all <run> tests
	# - gmake check_repo 	: assess the confs with <repo> tests
	#   or gmake clean check_repo supplier=cisco-ios (or view_juniper-junos, etc.)
	# - gmake check_run 	: assess the confs with <run> tests
	#   or gmake clean check_run supplier=cisco-ios (or view_juniper-junos, etc.)
	# - gmake view		: view the reports and the summary
	#   or gmake clean check_repo view supplier=cisco-ios (or view_juniper-junos, etc.)
	#   or gmake clean check_run view supplier=cisco-ios (or view_juniper-junos, etc.)
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
	@echo "cawk --- the list of suppliers supported by cawk is:"
	@echo $(SUPPLIER_SCOPE)
	@echo "cawk supplier done ----"

# --------------------------------

system:
	$(TESTS_SYSTEM)/cawk_check_system

# --------------------------------

tests_target : $(TESTS_COMMON_TEMPLATE:.gawk.template=.gawk) $(TESTS_cisco-ios_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_cisco-viptela_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_juniper-junos_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_huawei-vrp_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_fortinet-fortios_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_nokia-sros_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_paloalto-panos_REPO_TEMPLATE:.gawk.template=.gawk)

tests_repo: tests_target
	@echo "cawk tests_repo done ----"

tests_run: tests_target
	@echo "cawk tests_run done ----"

# --------------------------------

check_repo: clean_report clean_tmp tests_target check_supplier
ifeq ($(strip $(supplier)),)
ifeq ($(strip $(MAKE_PARALLEL)),no)
	@$(foreach scope,$(SUPPLIER_SCOPE),\
		echo "cawk ---- compute $(scope) devices ----" ;\
		touch $(TESTS_REPORT)/assessment.$(scope).csv ;\
		$(foreach test,$(TESTS_$(scope)_REPO_TEMPLATE:.gawk.template=.gawk),\
			find $(CONFIGURATION_$(scope)_PATH) -type f -exec ./$(test) {} \; >> $(TESTS_REPORT)/assessment.$(scope).csv ;\
		) \
		$(TESTS_COMMON_PATH)/report.gawk $(TESTS_REPORT)/assessment.$(scope).csv > $(TESTS_REPORT)/assessment.$(scope).summary.txt ;\
	)
else
	@$(foreach scope,$(SUPPLIER_SCOPE),\
		echo "cawk ---- compute $(scope) devices ----" ;\
		touch $(TESTS_REPORT)/assessment.$(scope).csv ;\
		find $(CONFIGURATION_$(scope)_PATH) -type f > $(TESTS_TMP)/conf_list_files.$(scope) ;\
		find $(TESTS_$(scope)_REPO_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.$(scope) ;\
		$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk \
		$(TESTS_TMP)/conf_list_files.$(scope) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.$(scope) > \
		$(TESTS_TMP)/Makefile.$(scope) ;\
		gmake -f $(TESTS_TMP)/Makefile.$(scope) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(TESTS_REPORT)/assessment.$(scope).csv ;\
		$(TESTS_COMMON_PATH)/report.gawk $(TESTS_REPORT)/assessment.$(scope).csv > $(TESTS_REPORT)/assessment.$(scope).summary.txt ;\
	)
endif
else
ifeq ($(strip $(MAKE_PARALLEL)),no)
	@echo "cawk ---- compute $(supplier) devices ----"
	@touch $(TESTS_REPORT)/assessment.$(supplier).csv
	@$(foreach test,$(TESTS_$(supplier)_REPO_TEMPLATE:.gawk.template=.gawk),\
		find $(CONFIGURATION_$(supplier)_PATH) -type f -exec ./$(test) {} \; >> $(TESTS_REPORT)/assessment.$(supplier).csv ;\
	)
	$(TESTS_COMMON_PATH)/report.gawk $(TESTS_REPORT)/assessment.$(supplier).csv > $(TESTS_REPORT)/assessment.$(supplier).summary.txt
else
	@echo "cawk ---- compute $(supplier) devices ----"
	@touch $(TESTS_REPORT)/assessment.$(supplier).csv
	@find $(CONFIGURATION_$(supplier)_PATH) -type f > $(TESTS_TMP)/conf_list_files.$(supplier)
	@find $(TESTS_$(supplier)_REPO_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.$(supplier)
	@$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk \
	$(TESTS_TMP)/conf_list_files.$(supplier) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.$(supplier) > \
	$(TESTS_TMP)/Makefile.$(supplier)
	@gmake -f $(TESTS_TMP)/Makefile.$(supplier) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(TESTS_REPORT)/assessment.$(supplier).csv
	@$(TESTS_COMMON_PATH)/report.gawk $(TESTS_REPORT)/assessment.$(supplier).csv > $(TESTS_REPORT)/assessment.$(supplier).summary.txt
endif
endif
	@echo "cawk check_repo done ----"

check_run: clean_report clean_tmp tests_target check_supplier
ifeq ($(strip $(supplier)),)
ifeq ($(strip $(MAKE_PARALLEL)),no)
	@$(foreach scope,$(SUPPLIER_SCOPE),\
		echo "cawk ---- compute $(scope) devices ----" ;\
		touch $(TESTS_REPORT)/assessment.$(scope).csv ;\
		$(foreach test,$(TESTS_$(scope)_RUN_TEMPLATE:.gawk.template=.gawk),\
			find $(CONFIGURATION_$(scope)_PATH) -type f -exec ./$(test) {} \; >> $(TESTS_REPORT)/assessment.$(scope).csv ;\
		) \
		$(TESTS_COMMON_PATH)/report.gawk $(TESTS_REPORT)/assessment.$(scope).csv > $(TESTS_REPORT)/assessment.$(scope).summary.txt ;\
	)
else
	@$(foreach scope,$(SUPPLIER_SCOPE),\
		echo "cawk ---- compute $(scope) devices ----" ;\
		touch $(TESTS_REPORT)/assessment.$(scope).csv ;\
		find $(CONFIGURATION_$(scope)_PATH) -type f > $(TESTS_TMP)/conf_list_files.$(scope) ;\
		find $(TESTS_$(scope)_RUN_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.$(scope) ;\
		$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk \
		$(TESTS_TMP)/conf_list_files.$(scope) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.$(scope) > \
		$(TESTS_TMP)/Makefile.$(scope) ;\
		gmake -f $(TESTS_TMP)/Makefile.$(scope) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(TESTS_REPORT)/assessment.$(scope).csv ;\
		$(TESTS_COMMON_PATH)/report.gawk $(TESTS_REPORT)/assessment.$(scope).csv > $(TESTS_REPORT)/assessment.$(scope).summary.txt ;\
	)
endif
else
ifeq ($(strip $(MAKE_PARALLEL)),no)
	@echo "cawk ---- compute $(supplier) devices ----"
	@touch $(TESTS_REPORT)/assessment.$(supplier).csv
	@$(foreach test,$(TESTS_$(supllier)_RUN_TEMPLATE:.gawk.template=.gawk),\
		find $(CONFIGURATION_$(supplier)_PATH) -type f -exec ./$(test) {} \; >> $(TESTS_REPORT)/assessment.$(supplier).csv ;\
	) \
	$(TESTS_COMMON_PATH)/report.gawk $(TESTS_REPORT)/assessment.$(supplier).csv > $(TESTS_REPORT)/assessment.$(supplier).summary.txt
else
	@echo "cawk ---- compute $(supplier) devices ----"
	@touch $(TESTS_REPORT)/assessment.$(supplier).csv
	@find $(CONFIGURATION_$(supplier)_PATH) -type f > $(TESTS_TMP)/conf_list_files.$(supplier)
	@find $(TESTS_$(supplier)_RUN_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.$(supplier)
	@$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk \
	$(TESTS_TMP)/conf_list_files.$(supplier) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.$(supplier) > \
	$(TESTS_TMP)/Makefile.$(supplier)
	@gmake -f $(TESTS_TMP)/Makefile.$(supplier) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(TESTS_REPORT)/assessment.$(supplier).csv
	@$(TESTS_COMMON_PATH)/report.gawk $(TESTS_REPORT)/assessment.$(supplier).csv > $(TESTS_REPORT)/assessment.$(supplier).summary.txt
endif
endif
	@echo "cawk check_run done ----"

# --------------------------------

check_supplier:
ifneq ($(findstring $(supplier),$(SUPPLIER_SCOPE)),$(supplier))
	@$(error supplier : ($(supplier)) is not the list of suppliers covered by cawk ($(SUPPLIER_SCOPE)))
endif

view: check_supplier
ifeq ($(strip $(supplier)),)
	@$(foreach test,$(SUPPLIER_SCOPE),\
		echo "------------------------------------" ;\
		echo "---- Assessment $(test) devices" ;\
		echo "------------------------------------" ;\
		cat $(TESTS_REPORT)/assessment.$(test).csv ;\
		echo "-------------------------" ;\
		echo "---- $(test) summary" ;\
		echo "-------------------------" ;\
		cat $(TESTS_REPORT)/assessment.$(test).summary.txt ;\
	)
else
	@echo "------------------------------------"
	@echo "---- Assessment $(supplier) devices"
	@echo "------------------------------------"
	@cat $(TESTS_REPORT)/assessment.$(supplier).csv
	@echo "------------------------------"
	@echo " ---- $(supplier) summary"
	@echo "------------------------------"
	@cat $(TESTS_REPORT)/assessment.$(supplier).summary.txt
endif
	@echo "cawk view done ----"

# --------------------------------

clean: clean_report clean_tmp
	rm -f $(TESTS_COMMON_PATH)/*.gawk
	$(foreach scope,$(SUPPLIER_SCOPE),\
		rm -f $(TESTS_$(scope)_REPO_PATH)/*.gawk $(TESTS_$(scope)_RUN_PATH)/*.gawk ;\
	)
	@echo "cawk clean done ----"

clean_report:
	rm -f $(TESTS_REPORT)/*

clean_tmp:
	rm -f $(TESTS_TMP)/tmp*
	rm -f $(TESTS_TMP)/conf_*
	rm -f $(TESTS_TMP)/Makefile*

# --------------------------------

catalog:
	@echo "******************************"
	@echo "******************************"
	@echo "---- Tests <repo> catalog"
	@echo "******************************"
	@echo "******************************"
	@$(foreach id,$(TESTS_CATALOG),\
		echo " ---------------------------------------------------";\
		echo " ---- "$(id)" ----";\
		echo " ---------------------------------------------------";\
		grep -H purpose $(id)/*template | sed -e 's/# purpose ://g' -e 's/tests\/tests\.//g' || true;\
	)

	@echo "\n******************************"
	@echo "******************************"
	@echo "---- Tests <run> catalog"
	@echo "******************************"
	@echo "******************************"
	@$(foreach id,$(TESTS_CATALOG_RUN),\
		echo " ¬---------------------------------------------------";\
		echo " ---- "$(id)" ----";\
		echo " ---------------------------------------------------";\
		grep -H purpose $(id)/*template | sed -e 's/# purpose ://g' -e 's/tests\/tests\.//g' || true;\
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
