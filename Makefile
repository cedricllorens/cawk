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
# - gmake common        : provide the list of functions available in the common directory
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
# - gmake view_error 	: view the assessment reports errors
#   or gmake clean check_repo view_error supplier=cisco-ios (or juniper-junos, etc.)
#   or gmake clean check_run view_error supplier=cisco-ios (or juniper-junos, etc.)
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
TESTS_cisco-ios_REPO_M4 = $(wildcard $(TESTS_cisco-ios_REPO_PATH)/*.m4)
TESTS_cisco-ios_RUN_TEMPLATE = $(wildcard $(TESTS_cisco-ios_RUN_PATH)/*.template)
TESTS_cisco-ios_RUN_M4 = $(wildcard $(TESTS_cisco-ios_RUN_PATH)/*.m4)

CONFIGURATION_juniper-junos_PATH = conf/conf.juniper-junos
TESTS_juniper-junos_REPO_PATH = tests/tests.juniper-junos/repo
TESTS_juniper-junos_RUN_PATH = tests/tests.juniper-junos/run
TESTS_juniper-junos_REPO_TEMPLATE = $(wildcard $(TESTS_juniper-junos_REPO_PATH)/*.template)
TESTS_juniper-junos_REPO_M4 = $(wildcard $(TESTS_juniper-junos_REPO_PATH)/*.m4)
TESTS_juniper-junos_RUN_TEMPLATE = $(wildcard $(TESTS_juniper-junos_RUN_PATH)/*.template)
TESTS_juniper-junos_RUN_M4 = $(wildcard $(TESTS_juniper-junos_RUN_PATH)/*.m4)

CONFIGURATION_huawei-vrp_PATH = conf/conf.huawei-vrp
TESTS_huawei-vrp_REPO_PATH = tests/tests.huawei-vrp/repo
TESTS_huawei-vrp_RUN_PATH = tests/tests.huawei-vrp/run
TESTS_huawei-vrp_REPO_TEMPLATE = $(wildcard $(TESTS_huawei-vrp_REPO_PATH)/*.template)
TESTS_huawei-vrp_REPO_M4 = $(wildcard $(TESTS_huawei-vrp_REPO_PATH)/*.m4)
TESTS_huawei-vrp_RUN_TEMPLATE = $(wildcard $(TESTS_huawei-vrp_RUN_PATH)/*.template)
TESTS_huawei-vrp_RUN_M4 = $(wildcard $(TESTS_huawei-vrp_RUN_PATH)/*.m4)

CONFIGURATION_fortinet-fortios_PATH = conf/conf.fortinet-fortios
TESTS_fortinet-fortios_REPO_PATH = tests/tests.fortinet-fortios/repo
TESTS_fortinet-fortios_RUN_PATH = tests/tests.fortinet-fortios/run
TESTS_fortinet-fortios_REPO_TEMPLATE = $(wildcard $(TESTS_fortinet-fortios_REPO_PATH)/*.template)
TESTS_fortinet-fortios_REPO_M4 = $(wildcard $(TESTS_fortinet-fortios_REPO_PATH)/*.m4)
TESTS_fortinet-fortios_RUN_TEMPLATE = $(wildcard $(TESTS_fortinet-fortios_RUN_PATH)/*.template)
TESTS_fortinet-fortios_RUN_M4 = $(wildcard $(TESTS_fortinet-fortios_RUN_PATH)/*.m4)

CONFIGURATION_nokia-sros_PATH = conf/conf.nokia-sros
TESTS_nokia-sros_REPO_PATH = tests/tests.nokia-sros/repo
TESTS_nokia-sros_RUN_PATH = tests/tests.nokia-sros/run
TESTS_nokia-sros_REPO_TEMPLATE = $(wildcard $(TESTS_nokia-sros_REPO_PATH)/*.template)
TESTS_nokia-sros_REPO_M4 = $(wildcard $(TESTS_nokia-sros_REPO_PATH)/*.m4)
TESTS_nokia-sros_RUN_TEMPLATE = $(wildcard $(TESTS_nokia-sros_RUN_PATH)/*.template)
TESTS_nokia-sros_RUN_M4 = $(wildcard $(TESTS_nokia-sros_RUN_PATH)/*.m4)

CONFIGURATION_paloalto-panos_PATH = conf/conf.paloalto-panos
TESTS_paloalto-panos_REPO_PATH = tests/tests.paloalto-panos/repo
TESTS_paloalto-panos_RUN_PATH = tests/tests.paloalto-panos/run
TESTS_paloalto-panos_REPO_TEMPLATE = $(wildcard $(TESTS_paloalto-panos_REPO_PATH)/*.template)
TESTS_paloalto-panos_REPO_M4 = $(wildcard $(TESTS_paloalto-panos_REPO_PATH)/*.m4)
TESTS_paloalto-panos_RUN_TEMPLATE = $(wildcard $(TESTS_paloalto-panos_RUN_PATH)/*.template)
TESTS_paloalto-panos_RUN_M4 = $(wildcard $(TESTS_paloalto-panos_RUN_PATH)/*.m4)

CONFIGURATION_cisco-viptela_PATH = conf/conf.cisco-viptela
TESTS_cisco-viptela_REPO_PATH = tests/tests.cisco-viptela/repo
TESTS_cisco-viptela_RUN_PATH = tests/tests.cisco-viptela/run
TESTS_cisco-viptela_REPO_TEMPLATE = $(wildcard $(TESTS_cisco-viptela_REPO_PATH)/*.template)
TESTS_cisco-viptela_REPO_M4 = $(wildcard $(TESTS_cisco-viptela_REPO_PATH)/*.m4)
TESTS_cisco-viptela_RUN_TEMPLATE = $(wildcard $(TESTS_cisco-viptela_RUN_PATH)/*.template)
TESTS_cisco-viptela_RUN_M4 = $(wildcard $(TESTS_cisco-viptela_RUN_PATH)/*.m4)

CONFIGURATION_cisco-cedge_PATH = conf/conf.cisco-cedge
TESTS_cisco-cedge_REPO_PATH = tests/tests.cisco-cedge/repo
TESTS_cisco-cedge_RUN_PATH = tests/tests.cisco-cedge/run
TESTS_cisco-cedge_REPO_TEMPLATE = $(wildcard $(TESTS_cisco-cedge_REPO_PATH)/*.template)
TESTS_cisco-cedge_REPO_M4 = $(wildcard $(TESTS_cisco-cedge_REPO_PATH)/*.m4)
TESTS_cisco-cedge_RUN_TEMPLATE = $(wildcard $(TESTS_cisco-cedge_RUN_PATH)/*.template)
TESTS_cisco-cedge_RUN_M4 = $(wildcard $(TESTS_cisco-cedge_RUN_PATH)/*.m4)

CONFIGURATION_research_PATH = conf/conf.research
TESTS_research_REPO_PATH = tests/tests.research/repo
TESTS_research_RUN_PATH = tests/tests.research/run
TESTS_research_REPO_TEMPLATE = $(wildcard $(TESTS_research_REPO_PATH)/*.template)
TESTS_research_REPO_M4 = $(wildcard $(TESTS_research_REPO_PATH)/*.m4)
TESTS_research_RUN_TEMPLATE = $(wildcard $(TESTS_research_RUN_PATH)/*.template)
TESTS_research_RUN_M4 = $(wildcard $(TESTS_research_RUN_PATH)/*.m4)

TESTS_REPORT = report

TESTS_SYSTEM = system

TESTS_TMP = tmp

SUPPLIER_SCOPE = cisco-ios cisco-viptela cisco-cedge juniper-junos huawei-vrp fortinet-fortios nokia-sros paloalto-panos research

TESTS_CATALOG = $(TESTS_cisco-ios_REPO_PATH) \
		$(TESTS_cisco-viptela_REPO_PATH) \
		$(TESTS_cisco-cedge_REPO_PATH) \
		$(TESTS_juniper-junos_REPO_PATH) \
		$(TESTS_huawei-vrp_REPO_PATH) \
		$(TESTS_fortinet-fortios_REPO_PATH) \
		$(TESTS_nokia-sros_REPO_PATH) \
		$(TESTS_paloalto-panos_REPO_PATH) \
		$(TESTS_research_REPO_PATH)

TESTS_CATALOG_RUN = $(TESTS_cisco-ios_RUN_PATH) \
		$(TESTS_cisco-viptela_RUN_PATH) \
		$(TESTS_cisco-cedge_RUN_PATH) \
		$(TESTS_juniper-junos_RUN_PATH) \
		$(TESTS_huawei-vrp_RUN_PATH) \
		$(TESTS_fortinet-fortios_RUN_PATH) \
		$(TESTS_nokia-sros_RUN_PATH) \
		$(TESTS_paloalto-panos_RUN_PATH) \
		$(TESTS_research_RUN_PATH)

EXCEPTION_PATH = exceptions
EXCEPTION_M4 = $(wildcard $(EXCEPTION_PATH)/*.m4)

# --------------- TESTS BUILDING BY SED CHANGE

%.gawk: %.gawk.template
	@sed -f support/tests.sed $< > $@ || true
	@chmod 750 $@

%.gawk: %.gawk.m4
	@m4 -I m4 $< | sed -f support/tests.sed > $@ || true
	@chmod 750 $@

%: %.m4
	@m4 -I m4 $< | sed '/^$$/d' > $@ || true
	@chmod 650 $@

# --------------- GNU MAKE TARGETS

.PHONY: all check_repo check_run tests tests_target view view_error clean_report clean_tmp clean catalog git gitpush supplier check_supplier system common

all:
	# ------------------------------------------------------------
	# - gmake 		: provide information on cawk running
	# - gmake system	: allow to know if the system can run cawk
	# - gmake supplier 	: provide the suppliers supported by cawk
	# - gmake common        : provide the list of functions available in the common directory
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
	# - gmake view_error 	: view the assessment reports errors
	#   or gmake clean check_repo view_error supplier=cisco-ios (or juniper-junos, etc.)
	#   or gmake clean check_run view_error supplier=cisco-ios (or juniper-junos, etc.)
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

common:
	grep purpose common/*.template

# --------------------------------

tests_target_repo : $(TESTS_COMMON_TEMPLATE:.gawk.template=.gawk) $(TESTS_cisco-ios_REPO_M4:.gawk.m4=.gawk) $(TESTS_cisco-ios_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_cisco-viptela_REPO_M4:.gawk.m4=.gawk) $(TESTS_cisco-viptela_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_cisco-ios_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_cisco-cedge_REPO_M4:.gawk.m4=.gawk) $(TESTS_cisco-cedge_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_juniper-junos_REPO_M4:.gawk.m4=.gawk) $(TESTS_juniper-junos_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_huawei-vrp_REPO_M4:.gawk.m4=.gawk) $(TESTS_huawei-vrp_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_fortinet-fortios_REPO_M4:.gawk.m4=.gawk) $(TESTS_fortinet-fortios_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_nokia-sros_REPO_M4:.gawk.m4=.gawk) $(TESTS_nokia-sros_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_paloalto-panos_REPO_M4:.gawk.m4=.gawk) $(TESTS_paloalto-panos_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_research_REPO_M4:.gawk.m4=.gawk) $(TESTS_research_REPO_TEMPLATE:.gawk.template=.gawk) $(EXCEPTION_M4:.m4=)

tests_target_run : $(TESTS_COMMON_TEMPLATE:.gawk.template=.gawk) $(TESTS_cisco-ios_RUN_M4:.gawk.m4=.gawk) $(TESTS_cisco-ios_RUN_TEMPLATE:.gawk.template=.gawk) $(TESTS_cisco-viptela_RUN_M4:.gawk.m4=.gawk) $(TESTS_cisco-viptela_RUN_TEMPLATE:.gawk.template=.gawk) $(TESTS_cisco-cedge_RUN_M4:.gawk.m4=.gawk) $(TESTS_cisco-cedge_RUN_TEMPLATE:.gawk.template=.gawk) $(TESTS_juniper-junos_RUN_M4:.gawk.m4=.gawk) $(TESTS_juniper-junos_RUN_TEMPLATE:.gawk.template=.gawk) $(TESTS_huawei-vrp_RUN_M4:.gawk.m4=.gawk) $(TESTS_huawei-vrp_RUN_TEMPLATE:.gawk.template=.gawk) $(TESTS_fortinet-fortios_RUN_M4:.gawk.m4=.gawk) $(TESTS_fortinet-fortios_RUN_TEMPLATE:.gawk.template=.gawk) $(TESTS_nokia-sros_RUN_M4:.gawk.m4=.gawk) $(TESTS_nokia-sros_RUN_TEMPLATE:.gawk.template=.gawk) $(TESTS_paloalto-panos_RUN_M4:.gawk.m4=.gawk) $(TESTS_paloalto-panos_RUN_TEMPLATE:.gawk.template=.gawk) $(TESTS_research_RUN_M4:.gawk.m4=.gawk) $(TESTS_research_RUN_TEMPLATE:.gawk.template=.gawk) $(EXCEPTION_M4:.m4=)

tests_repo: tests_target_repo
	@echo "cawk tests_repo done ----"

tests_run: tests_target_run
	@echo "cawk tests_run done ----"

# --------------------------------

check_repo: clean tests_target_repo check_supplier
ifeq ($(strip $(supplier)),)
ifeq ($(strip $(MAKE_PARALLEL)),no)
	@$(foreach scope,$(SUPPLIER_SCOPE),\
		echo "cawk ---- compute $(scope) devices ----" ;\
		touch $(TESTS_REPORT)/assessment.$(scope).csv ;\
		$(foreach test,$(shell find $(TESTS_$(scope)_REPO_PATH) -name '*.gawk' -type f),\
			find $(CONFIGURATION_$(scope)_PATH) -type f -exec ./$(test) {} \; >> $(TESTS_REPORT)/assessment.$(scope).csv.swap ;\
		) \
		touch $(TESTS_REPORT)/assessment.$(scope).csv.swap; \
		egrep -v -f $(EXCEPTION_PATH)/exceptions.$(scope) $(TESTS_REPORT)/assessment.$(scope).csv.swap | sort | uniq > \
		$(TESTS_REPORT)/assessment.$(scope).csv || true ;\
		egrep -f $(EXCEPTION_PATH)/exceptions.$(scope) $(TESTS_REPORT)/assessment.$(scope).csv.swap | sort | uniq > \
		$(TESTS_REPORT)/assessment.$(scope).exceptions.csv || true ;\
		rm -f $(TESTS_REPORT)/assessment.$(scope).csv.swap ;\
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
		gmake -s -f $(TESTS_TMP)/Makefile.$(scope) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > \
		$(TESTS_REPORT)/assessment.$(scope).csv.swap ;\
		egrep -v -f $(EXCEPTION_PATH)/exceptions.$(scope) $(TESTS_REPORT)/assessment.$(scope).csv.swap | sort | uniq > \
		$(TESTS_REPORT)/assessment.$(scope).csv || true ;\
		egrep -f $(EXCEPTION_PATH)/exceptions.$(scope) $(TESTS_REPORT)/assessment.$(scope).csv.swap | sort | uniq > \
		$(TESTS_REPORT)/assessment.$(scope).exceptions.csv || true ;\
		rm -f $(TESTS_REPORT)/assessment.$(scope).csv.swap ;\
		$(TESTS_COMMON_PATH)/report.gawk $(TESTS_REPORT)/assessment.$(scope).csv > $(TESTS_REPORT)/assessment.$(scope).summary.txt ;\
	)
endif
else
ifeq ($(strip $(MAKE_PARALLEL)),no)
	@echo "cawk ---- compute $(supplier) devices ----"
	@touch $(TESTS_REPORT)/assessment.$(supplier).csv
	@$(foreach test,$(shell find $(TESTS_$(supplier)_REPO_PATH) -name '*.gawk' -type f),\
		find $(CONFIGURATION_$(supplier)_PATH) -type f -exec ./$(test) {} \; >> $(TESTS_REPORT)/assessment.$(supplier).csv.swap ;\
	)
	@touch $(TESTS_REPORT)/assessment.$(supplier).csv.swap
	@egrep -v -f $(EXCEPTION_PATH)/exceptions.$(supplier) $(TESTS_REPORT)/assessment.$(supplier).csv.swap | sort | uniq > \
	$(TESTS_REPORT)/assessment.$(supplier).csv || true
	@egrep -f $(EXCEPTION_PATH)/exceptions.$(supplier) $(TESTS_REPORT)/assessment.$(supplier).csv.swap | sort | uniq > \
	$(TESTS_REPORT)/assessment.$(supplier).exceptions.csv || true
	@rm -f $(TESTS_REPORT)/assessment.$(supplier).csv.swap
	@$(TESTS_COMMON_PATH)/report.gawk $(TESTS_REPORT)/assessment.$(supplier).csv > $(TESTS_REPORT)/assessment.$(supplier).summary.txt
else
	@echo "cawk ---- compute $(supplier) devices ----"
	@touch $(TESTS_REPORT)/assessment.$(supplier).csv
	@find $(CONFIGURATION_$(supplier)_PATH) -type f > $(TESTS_TMP)/conf_list_files.$(supplier)
	@find $(TESTS_$(supplier)_REPO_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.$(supplier)
	@$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk \
	$(TESTS_TMP)/conf_list_files.$(supplier) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.$(supplier) > \
	$(TESTS_TMP)/Makefile.$(supplier)
	@gmake -s -f $(TESTS_TMP)/Makefile.$(supplier) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(TESTS_REPORT)/assessment.$(supplier).csv.swap
	egrep -v -f $(EXCEPTION_PATH)/exceptions.$(supplier) $(TESTS_REPORT)/assessment.$(supplier).csv.swap | sort | uniq > \
	$(TESTS_REPORT)/assessment.$(supplier).csv || true
	egrep -f $(EXCEPTION_PATH)/exceptions.$(supplier) $(TESTS_REPORT)/assessment.$(supplier).csv.swap | sort | uniq > \
	$(TESTS_REPORT)/assessment.$(supplier).exceptions.csv || true
	rm -f $(TESTS_REPORT)/assessment.$(supplier).csv.swap
	@$(TESTS_COMMON_PATH)/report.gawk $(TESTS_REPORT)/assessment.$(supplier).csv > $(TESTS_REPORT)/assessment.$(supplier).summary.txt
endif
endif
	@echo "cawk check_repo done ----"

check_run: clean tests_target_run check_supplier
ifeq ($(strip $(supplier)),)
ifeq ($(strip $(MAKE_PARALLEL)),no)
	@$(foreach scope,$(SUPPLIER_SCOPE),\
		echo "cawk ---- compute $(scope) devices ----" ;\
		touch $(TESTS_REPORT)/assessment.$(scope).csv ;\
		$(foreach test,$(shell find $(TESTS_$(scope)_RUN_PATH) -name '*.gawk' -type f),\
			find $(CONFIGURATION_$(scope)_PATH) -type f -exec ./$(test) {} \; >> $(TESTS_REPORT)/assessment.$(scope).csv ;\
		) \
		touch $(TESTS_REPORT)/assessment.$(scope).csv.swap; \
		egrep -v -f $(EXCEPTION_PATH)/exceptions.$(scope) $(TESTS_REPORT)/assessment.$(scope).csv.swap > \
		$(TESTS_REPORT)/assessment.$(scope).csv || true ;\
		egrep -f $(EXCEPTION_PATH)/exceptions.$(scope) $(TESTS_REPORT)/assessment.$(scope).csv.swap > \
		$(TESTS_REPORT)/assessment.$(scope).exceptions.csv || true ;\
		rm -f $(TESTS_REPORT)/assessment.$(scope).csv.swap ;\
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
		gmake -s -f $(TESTS_TMP)/Makefile.$(scope) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(TESTS_REPORT)/assessment.$(scope).csv ;\
		egrep -v -f $(EXCEPTION_PATH)/exceptions.$(scope) $(TESTS_REPORT)/assessment.$(scope).csv.swap > \
		$(TESTS_REPORT)/assessment.$(scope).csv || true ;\
		egrep -f $(EXCEPTION_PATH)/exceptions.$(scope) $(TESTS_REPORT)/assessment.$(scope).csv.swap > \
		$(TESTS_REPORT)/assessment.$(scope).exceptions.csv || true ;\
		rm -f $(TESTS_REPORT)/assessment.$(scope).csv.swap ;\
		$(TESTS_COMMON_PATH)/report.gawk $(TESTS_REPORT)/assessment.$(scope).csv > $(TESTS_REPORT)/assessment.$(scope).summary.txt ;\
	)
endif
else
ifeq ($(strip $(MAKE_PARALLEL)),no)
	@echo "cawk ---- compute $(supplier) devices ----"
	@touch $(TESTS_REPORT)/assessment.$(supplier).csv
	@$(foreach test,$(shell find  $(TESTS_$(supplier)_RUN_PATH) -name '*.gawk' -type f),\
		find $(CONFIGURATION_$(supplier)_PATH) -type f -exec ./$(test) {} \; >> $(TESTS_REPORT)/assessment.$(supplier).csv ;\
	)
	@touch $(TESTS_REPORT)/assessment.$(supplier).csv.swap
	@egrep -v -f $(EXCEPTION_PATH)/exceptions.$(supplier) $(TESTS_REPORT)/assessment.$(supplier).csv.swap > \
	$(TESTS_REPORT)/assessment.$(supplier).csv || true
	@egrep -f $(EXCEPTION_PATH)/exceptions.$(supplier) $(TESTS_REPORT)/assessment.$(supplier).csv.swap > \
	$(TESTS_REPORT)/assessment.$(supplier).exceptions.csv || true
	@rm -f $(TESTS_REPORT)/assessment.$(supplier).csv.swap
	@$(TESTS_COMMON_PATH)/report.gawk $(TESTS_REPORT)/assessment.$(supplier).csv > $(TESTS_REPORT)/assessment.$(supplier).summary.txt
else
	@echo "cawk ---- compute $(supplier) devices ----"
	@touch $(TESTS_REPORT)/assessment.$(supplier).csv
	@find $(CONFIGURATION_$(supplier)_PATH) -type f > $(TESTS_TMP)/conf_list_files.$(supplier)
	@find $(TESTS_$(supplier)_RUN_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.$(supplier)
	@$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk \
	$(TESTS_TMP)/conf_list_files.$(supplier) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.$(supplier) > \
	$(TESTS_TMP)/Makefile.$(supplier)
	@gmake -s -f $(TESTS_TMP)/Makefile.$(supplier) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(TESTS_REPORT)/assessment.$(supplier).csv
	egrep -v -f $(EXCEPTION_PATH)/exceptions.$(supplier) $(TESTS_REPORT)/assessment.$(supplier).csv.swap > \
	$(TESTS_REPORT)/assessment.$(supplier).csv || true
	egrep -f $(EXCEPTION_PATH)/exceptions.$(supplier) $(TESTS_REPORT)/assessment.$(supplier).csv.swap > \
	$(TESTS_REPORT)/assessment.$(supplier).exceptions.csv || true
	rm -f $(TESTS_REPORT)/assessment.$(supplier).csv.swap
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

view_error: check_supplier
ifeq ($(strip $(supplier)),)
	@$(foreach test,$(SUPPLIER_SCOPE),\
		cat $(TESTS_REPORT)/assessment.$(test).csv | grep ";error" ;\
	)
else
	@cat $(TESTS_REPORT)/assessment.$(supplier).csv | grep ";error"
endif
	@echo "cawk view_error done ----"

# --------------------------------

clean: clean_report clean_tmp
	@rm -f $(TESTS_COMMON_PATH)/*.gawk
	@$(foreach scope,$(SUPPLIER_SCOPE),\
		rm -f $(TESTS_$(scope)_REPO_PATH)/*.gawk $(TESTS_$(scope)_RUN_PATH)/*.gawk ;\
		rm -f $(EXCEPTION_PATH)/*.$(scope) ;\
	)
	@echo "cawk clean done ----"

clean_report:
	@rm -f $(TESTS_REPORT)/*

clean_tmp:
	@rm -f $(TESTS_TMP)/tmp*
	@rm -f $(TESTS_TMP)/conf_*
	@rm -f $(TESTS_TMP)/Makefile*

# --------------------------------

catalog: tests_repo tests_run
	@echo "******************************"
	@echo "******************************"
	@echo "---- Tests <repo> catalog"
	@echo "******************************"
	@echo "******************************"
	@$(foreach id,$(TESTS_CATALOG),\
		echo " ---------------------------------------------------";\
		echo " ---- "$(id)" ----";\
		echo " ---------------------------------------------------";\
		grep -H purpose $(id)/*gawk | sed -e 's/# purpose ://g' -e 's/tests\/tests\.//g' || true;\
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
		grep -H purpose $(id)/*gawk | sed -e 's/# purpose ://g' -e 's/tests\/tests\.//g' || true;\
	)
	@echo "cawk catalog done ----"

# --------------------------------

git:
	# git add .
	# git commit -m "*$(CAWK_RELEASE) ref ChangeLog"

gitpush:
	# git push https://github.com/cedricllorens/cawk.git master

