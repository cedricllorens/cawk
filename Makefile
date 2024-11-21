# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024 by Cedric Llorens
# ------------------------------------------------------------
# cawk main Makefile
# define all the cawk commands
# ------------------------------------------------------------

# ---------------

include Makefile.support.mk

# ---------------

CONFS_PATH = confs

TESTS_COMMON_PATH = common
TESTS_PATH = tests
TESTS_COMMON_TEMPLATE = $(wildcard $(TESTS_COMMON_PATH)/*.template)
TESTS_SYSTEM = system
TESTS_TMP = tmp

EXCEPTION_PATH = exceptions
EXCEPTION_M4 = $(wildcard $(EXCEPTION_PATH)/repo/*.m4) $(wildcard $(EXCEPTION_PATH)/run*/*.m4)

REPORT_PATH = reports

SUPPLIER_SCOPE = cisco-ios cisco-viptela cisco-cedge juniper-junos huawei-vrp fortinet-fortios nokia-sros paloalto-panos research

# --------------- CISCO-IOS

ifeq ($(strip $(audit)),)
	CONFIGURATION_cisco-ios_REPO_PATH = $(CONFS_PATH)/repo/confs.cisco-ios
	CONFIGURATION_cisco-ios_RUN_PATH = $(CONFS_PATH)/run/confs.cisco-ios
else
	CONFIGURATION_cisco-ios_RUN_PATH = $(CONFS_PATH)/run_${audit}/confs.cisco-ios
endif
TESTS_cisco-ios_REPO_PATH = $(TESTS_PATH)/repo/tests.cisco-ios
ifeq ($(strip $(audit)),)
	TESTS_cisco-ios_RUN_PATH = $(TESTS_PATH)/run/tests.cisco-ios
else
	TESTS_cisco-ios_RUN_PATH = $(TESTS_PATH)/run_${audit}/tests.cisco-ios
endif
TESTS_cisco-ios_REPO_TEMPLATE = $(wildcard $(TESTS_cisco-ios_REPO_PATH)/*.template)
TESTS_cisco-ios_REPO_M4 = $(wildcard $(TESTS_cisco-ios_REPO_PATH)/*.m4)
TESTS_cisco-ios_RUN_TEMPLATE = $(wildcard $(TESTS_cisco-ios_RUN_PATH)/*.template)
TESTS_cisco-ios_RUN_M4 = $(wildcard $(TESTS_cisco-ios_RUN_PATH)/*.m4)

# --------------- JUNIPER-JUNOS

ifeq ($(strip $(audit)),)
	CONFIGURATION_juniper-junos_REPO_PATH = $(CONFS_PATH)/repo/confs.juniper-junos
	CONFIGURATION_juniper-junos_RUN_PATH = $(CONFS_PATH)/run/confs.juniper-junos
else
	CONFIGURATION_juniper-junos_RUN_PATH = $(CONFS_PATH)/run_${audit}/confs.juniper-junos
endif
TESTS_juniper-junos_REPO_PATH = $(TESTS_PATH)/repo/tests.juniper-junos
ifeq ($(strip $(audit)),)
	TESTS_juniper-junos_RUN_PATH = $(TESTS_PATH)/run/tests.juniper-junos
else
	TESTS_juniper-junos_RUN_PATH = $(TESTS_PATH)/run_${audit}/tests.juniper-junos
endif
TESTS_juniper-junos_REPO_TEMPLATE = $(wildcard $(TESTS_juniper-junos_REPO_PATH)/*.template)
TESTS_juniper-junos_REPO_M4 = $(wildcard $(TESTS_juniper-junos_REPO_PATH)/*.m4)
TESTS_juniper-junos_RUN_TEMPLATE = $(wildcard $(TESTS_juniper-junos_RUN_PATH)/*.template)
TESTS_juniper-junos_RUN_M4 = $(wildcard $(TESTS_juniper-junos_RUN_PATH)/*.m4)

# --------------- HUAWEI-VRP

ifeq ($(strip $(audit)),)
	CONFIGURATION_huawei-vrp_REPO_PATH = $(CONFS_PATH)/repo/confs.huawei-vrp
	CONFIGURATION_huawei-vrp_RUN_PATH = $(CONFS_PATH)/run/confs.huawei-vrp
else
	CONFIGURATION_huawei-vrp_RUN_PATH = $(CONFS_PATH)/run_${audit}/confs.huawei-vrp
endif
TESTS_huawei-vrp_REPO_PATH = $(TESTS_PATH)/repo/tests.huawei-vrp
ifeq ($(strip $(audit)),)
	TESTS_huawei-vrp_RUN_PATH = $(TESTS_PATH)/run/tests.huawei-vrp
else
	TESTS_huawei-vrp_RUN_PATH = $(TESTS_PATH)/run_${audit}/tests.huawei-vrp
endif
TESTS_huawei-vrp_REPO_TEMPLATE = $(wildcard $(TESTS_huawei-vrp_REPO_PATH)/*.template)
TESTS_huawei-vrp_REPO_M4 = $(wildcard $(TESTS_huawei-vrp_REPO_PATH)/*.m4)
TESTS_huawei-vrp_RUN_TEMPLATE = $(wildcard $(TESTS_huawei-vrp_RUN_PATH)/*.template)
TESTS_huawei-vrp_RUN_M4 = $(wildcard $(TESTS_huawei-vrp_RUN_PATH)/*.m4)

# --------------- FORTINET-FORTIOS

ifeq ($(strip $(audit)),)
	CONFIGURATION_fortinet-fortios_REPO_PATH = $(CONFS_PATH)/repo/confs.fortinet-fortios
	CONFIGURATION_fortinet-fortios_RUN_PATH = $(CONFS_PATH)/run/confs.fortinet-fortios
else
	CONFIGURATION_fortinet-fortios_RUN_PATH = $(CONFS_PATH)/run_${audit}/confs.fortinet-fortios
endif
TESTS_fortinet-fortios_REPO_PATH = $(TESTS_PATH)/repo/tests.fortinet-fortios
ifeq ($(strip $(audit)),)
	TESTS_fortinet-fortios_RUN_PATH = $(TESTS_PATH)/run/tests.fortinet-fortios
else
	TESTS_fortinet-fortios_RUN_PATH = $(TESTS_PATH)/run_${audit}/tests.fortinet-fortios
endif
TESTS_fortinet-fortios_REPO_TEMPLATE = $(wildcard $(TESTS_fortinet-fortios_REPO_PATH)/*.template)
TESTS_fortinet-fortios_REPO_M4 = $(wildcard $(TESTS_fortinet-fortios_REPO_PATH)/*.m4)
TESTS_fortinet-fortios_RUN_TEMPLATE = $(wildcard $(TESTS_fortinet-fortios_RUN_PATH)/*.template)
TESTS_fortinet-fortios_RUN_M4 = $(wildcard $(TESTS_fortinet-fortios_RUN_PATH)/*.m4)

# --------------- NOKIA-SROS

ifeq ($(strip $(audit)),)
	CONFIGURATION_nokia-sros_REPO_PATH = $(CONFS_PATH)/repo/confs.nokia-sros
	CONFIGURATION_nokia-sros_RUN_PATH = $(CONFS_PATH)/run/confs.nokia-sros
else
	CONFIGURATION_nokia-sros_RUN_PATH = $(CONFS_PATH)/run_${audit}/confs.nokia-sros
endif
TESTS_nokia-sros_REPO_PATH = $(TESTS_PATH)/repo/tests.nokia-sros
ifeq ($(strip $(audit)),)
	TESTS_nokia-sros_RUN_PATH = $(TESTS_PATH)/run/tests.nokia-sros
else
	TESTS_nokia-sros_RUN_PATH = $(TESTS_PATH)/run_${audit}/tests.nokia-sros
endif
TESTS_nokia-sros_REPO_TEMPLATE = $(wildcard $(TESTS_nokia-sros_REPO_PATH)/*.template)
TESTS_nokia-sros_REPO_M4 = $(wildcard $(TESTS_nokia-sros_REPO_PATH)/*.m4)
TESTS_nokia-sros_RUN_TEMPLATE = $(wildcard $(TESTS_nokia-sros_RUN_PATH)/*.template)
TESTS_nokia-sros_RUN_M4 = $(wildcard $(TESTS_nokia-sros_RUN_PATH)/*.m4)

# --------------- PALOALTO-PANOS

ifeq ($(strip $(audit)),)
	CONFIGURATION_paloalto-panos_REPO_PATH = $(CONFS_PATH)/repo/confs.paloalto-panos
	CONFIGURATION_paloalto-panos_RUN_PATH = $(CONFS_PATH)/run/confs.paloalto-panos
else
	CONFIGURATION_paloalto-panos_RUN_PATH = $(CONFS_PATH)/run_${audit}/confs.paloalto-panos
endif
TESTS_paloalto-panos_REPO_PATH = $(TESTS_PATH)/repo/tests.paloalto-panos
ifeq ($(strip $(audit)),)
	TESTS_paloalto-panos_RUN_PATH = $(TESTS_PATH)/run/tests.paloalto-panos
else
	TESTS_paloalto-panos_RUN_PATH = $(TESTS_PATH)/run_${audit}/tests.paloalto-panos
endif
TESTS_paloalto-panos_REPO_TEMPLATE = $(wildcard $(TESTS_paloalto-panos_REPO_PATH)/*.template)
TESTS_paloalto-panos_REPO_M4 = $(wildcard $(TESTS_paloalto-panos_REPO_PATH)/*.m4)
TESTS_paloalto-panos_RUN_TEMPLATE = $(wildcard $(TESTS_paloalto-panos_RUN_PATH)/*.template)
TESTS_paloalto-panos_RUN_M4 = $(wildcard $(TESTS_paloalto-panos_RUN_PATH)/*.m4)

# --------------- CISCO-VIPTELA

ifeq ($(strip $(audit)),)
	CONFIGURATION_cisco-viptela_REPO_PATH = $(CONFS_PATH)/repo/confs.cisco-viptela
	CONFIGURATION_cisco-viptela_RUN_PATH = $(CONFS_PATH)/run/confs.cisco-viptela
else
	CONFIGURATION_cisco-viptela_RUN_PATH = $(CONFS_PATH)/run_${audit}/confs.cisco-viptela
endif
TESTS_cisco-viptela_REPO_PATH = $(TESTS_PATH)/repo/tests.cisco-viptela
ifeq ($(strip $(audit)),)
	TESTS_cisco-viptela_RUN_PATH = $(TESTS_PATH)/run/tests.cisco-viptela
else
	TESTS_cisco-viptela_RUN_PATH = $(TESTS_PATH)/run_${audit}/tests.cisco-viptela
endif
TESTS_cisco-viptela_REPO_TEMPLATE = $(wildcard $(TESTS_cisco-viptela_REPO_PATH)/*.template)
TESTS_cisco-viptela_REPO_M4 = $(wildcard $(TESTS_cisco-viptela_REPO_PATH)/*.m4)
TESTS_cisco-viptela_RUN_TEMPLATE = $(wildcard $(TESTS_cisco-viptela_RUN_PATH)/*.template)
TESTS_cisco-viptela_RUN_M4 = $(wildcard $(TESTS_cisco-viptela_RUN_PATH)/*.m4)

# --------------- CISCO-CEDGE

ifeq ($(strip $(audit)),)
	CONFIGURATION_cisco-cedge_REPO_PATH = $(CONFS_PATH)/repo/confs.cisco-cedge
	CONFIGURATION_cisco-cedge_RUN_PATH = $(CONFS_PATH)/run/confs.cisco-cedge
else
	CONFIGURATION_cisco-cedge_RUN_PATH = $(CONFS_PATH)/run_${audit}/confs.cisco-cedge
endif
TESTS_cisco-cedge_REPO_PATH = $(TESTS_PATH)/repo/tests.cisco-cedge
ifeq ($(strip $(audit)),)
	TESTS_cisco-cedge_RUN_PATH = $(TESTS_PATH)/run/tests.cisco-cedge
else
	TESTS_cisco-cedge_RUN_PATH = $(TESTS_PATH)/run_${audit}/tests.cisco-cedge
endif
TESTS_cisco-cedge_REPO_TEMPLATE = $(wildcard $(TESTS_cisco-cedge_REPO_PATH)/*.template)
TESTS_cisco-cedge_REPO_M4 = $(wildcard $(TESTS_cisco-cedge_REPO_PATH)/*.m4)
TESTS_cisco-cedge_RUN_TEMPLATE = $(wildcard $(TESTS_cisco-cedge_RUN_PATH)/*.template)
TESTS_cisco-cedge_RUN_M4 = $(wildcard $(TESTS_cisco-cedge_RUN_PATH)/*.m4)

# --------------- RESEARCH

ifeq ($(strip $(audit)),)
	CONFIGURATION_research_REPO_PATH = $(CONFS_PATH)/repo/confs.research
	CONFIGURATION_research_RUN_PATH = $(CONFS_PATH)/run/confs.research
else
	CONFIGURATION_research_RUN_PATH = $(CONFS_PATH)/run_${audit}/confs.research
endif
TESTS_research_REPO_PATH = $(TESTS_PATH)/repo/tests.research
ifeq ($(strip $(audit)),)
	TESTS_research_RUN_PATH = $(TESTS_PATH)/run/tests.research
else
	TESTS_research_RUN_PATH = $(TESTS_PATH)/run_${audit}/tests.research
endif
TESTS_research_REPO_TEMPLATE = $(wildcard $(TESTS_research_REPO_PATH)/*.template)
TESTS_research_REPO_M4 = $(wildcard $(TESTS_research_REPO_PATH)/*.m4)
TESTS_research_RUN_TEMPLATE = $(wildcard $(TESTS_research_RUN_PATH)/*.template)
TESTS_research_RUN_M4 = $(wildcard $(TESTS_research_RUN_PATH)/*.m4)

# ---------------

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

# --------------- GNU MAKE TARGETS

.PHONY: all check_repo check_run tests tests_target view_repo view_run view_repo_error view_run_error clean_report clean_tmp clean catalog git gitpush supplier check_supplier system common create_audit delete_audit list_audit check check_update

all:
	@echo "# -----------------------------------------------------------------------------------------------------------------------------"
	@echo "# CAWK COMMAND REF"
	@echo "# note that you can have several targets for a same gmake call like : gmake clean check_repo view_repo"
	@echo "# note : <repo> is the original cawk repository of coded tests, test's confs and exceptions"
	@echo "# note : <run> is an empty repository used for your own tests/checks"
	@echo "# note : <run_AUDIT_NAME> are repositories for all of your contexts or for your customers"
	@echo "# -----------------------------------------------------------------------------------------------------------------------------"
	@echo "# CAWK MAIN"
	@echo "# gmake          : provide information on cawk running"
	@echo "# gmake check    : allow to run a cawk compliance check (result must be OK only after the first installation)"
	@echo "# gmake system   : allow to know if the system can run cawk"
	@echo "# gmake supplier : provide the suppliers supported by cawk"
	@echo "# gmake common   : provide the list of functions available in the common directory"
	@echo "# gmake clean    : clean all"
	@echo "# -----------------------------------------------------------------------------------------------------------------------------"
	@echo "# CAWK BUILD TESTS"
	@echo "# gmake tests_repo                 : build tests associated to repo directory"
	@echo "# gmake tests_run                  : build tests associated to run directory"
	@echo "# gmake tests_run audit=AUDIT_NAME : build tests associated to AUDIT_NAME directory"
	@echo "# -----------------------------------------------------------------------------------------------------------------------------"
	@echo "# CAWK CREATE ASSESSMENTS"
	@echo "# gmake create_audit audit=AUDIT_NAME : create AUDIT_NAME tests, exceptions, confs directories (ref run_${audit})"
	@echo "# gmake delete_audit audit=AUDIT_NAME : delete AUDIT_NAME tests, exceptions, confs directories (ref run_${audit})"
	@echo "# gmake list_audit                    : list all the AUDIT_NAMEs"
	@echo "# -----------------------------------------------------------------------------------------------------------------------------"
	@echo "# CAWK ASSESSMENTS"
	@echo "# gmake check_repo : assess the confs with <repo> tests (build tests if not)"
	@echo "#   or gmake clean check_repo (run all suppliers)"
	@echo "#   or gmake clean check_repo supplier=cisco-ios (or view_juniper-junos, etc.)"
	@echo "# gmake check_run  : assess the confs with <run> tests (build tests if not)"
	@echo "#   For run assessment ----"
	@echo "#   or gmake check_run (run all suppliers)"
	@echo "#   or gmake check_run supplier=cisco-ios (or view_juniper-junos, etc.)"
	@echo "#   For special assessment ----"
	@echo "#   or gmake check_run audit=AUDIT_NAME (run all suppliers)"
	@echo "#   or gmake check_run supplier=cisco-ios audit=AUDIT_NAME (or view_juniper-junos, etc.)"
	@echo "# -----------------------------------------------------------------------------------------------------------------------------"
	@echo "# CAWK VIEW ASSESSMENTS"
	@echo "# gmake view_repo : view the repo reports (all in report/repo directory)"
	@echo "#   or gmake view_repo supplier=cisco-ios (or juniper-junos, etc.)"
	@echo "# gmake view_run  : view the run reports (all in report/run directory)"
	@echo "#   or gmake view_run supplier=cisco-ios (or juniper-junos, etc.)"
	@echo "#   or gmake view_run supplier=cisco-ios audit=AUDIT_NAME (or juniper-junos, etc.)"
	@echo "# -----------------------------------------------------------------------------------------------------------------------------"
	@echo "# CAWK VIEW ERROR ASSESSMENTS"
	@echo "# gmake view_repo_error : view the repo assessment reports errors (all in report/repo directory)"
	@echo "#   or gmake view_repo_error supplier=cisco-ios (or juniper-junos, etc.)"
	@echo "# gmake view_run_error  : view the run assessment reports errors (all in report/run directory)"
	@echo "#   or gmake view_run_error audit=AUDIT_NAME (all in report/repo directory)"
	@echo "#   or gmake view_run_error supplier=cisco-ios audit=AUDIT_NAME (or juniper-junos, etc.)"
	@echo "# -----------------------------------------------------------------------------------------------------------------------------"
	@echo "# CAWK TEST CATALOG"
	@echo "# gmake catalog : build the tests description catalog"
	@echo "# -----------------------------------------------------------------------------------------------------------------------------"

# --------------------------------

create_audit:
ifeq ($(strip $(audit)),)
	@echo "cawk error: audit=AUDIT_NAME must be set ----"
else
ifneq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	@echo "cawk error: audit=${audit} already exist ----"
else
	@cp -r $(TESTS_PATH)/repo $(TESTS_PATH)/run_${audit}
	@cp -r $(EXCEPTION_PATH)/repo exceptions/run_${audit}
	@cp -r $(CONFS_PATH)/repo $(CONFS_PATH)/run_${audit} 
	@mkdir $(REPORT_PATH)/run_${audit}
endif
endif
	@echo "cawk create_audit end ----"

delete_audit:
ifeq ($(strip $(audit)),)
	@echo "cawk error: audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	@echo "cawk error: audit=${audit} do not exist  ----"
else
	@rm -f -r $(TESTS_PATH)/run_${audit}
	@rm -f -r $(CONFS_PATH)/run_${audit}
	@rm -f -r $(EXCEPTION_PATH)/run_${audit}
	@rm -f -r $(REPORT_PATH)/run_${audit}
endif
endif
	@echo "cawk delete_audit end ----"

list_audit:
	@find tests -name '*run_*' -type d | awk -F'run_' '{print $$NF}' | sort | uniq
	@echo "cawk list_audit end ----"

# --------------------------------

check_supplier:
ifneq ($(strip $(supplier)),)
ifneq ($(findstring $(supplier),$(SUPPLIER_SCOPE)),$(supplier))
	@echo "cawk error: ($(supplier)) is not the list of suppliers covered by cawk ($(SUPPLIER_SCOPE)) ----"
	@exit 1
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

%.gawk: %.gawk.template
	@sed -f support/tests.sed $< > $@ || true
	@chmod 750 $@

%.gawk: %.gawk.m4
	@m4 -I m4 $< | sed -f support/tests.sed > $@ || true
	@chmod 750 $@

%: %.m4
	@m4 -I m4 $< | sed '/^$$/d' > $@ || true
	@chmod 650 $@

# --------------------------------

check_repo: tests_repo check_supplier
ifneq ($(strip $(audit)),)
	@echo "cawk error: the use of <audit=AUDIT_NAME> can only be used with check_run target ----"
	@exit 1
else
ifeq ($(strip $(supplier)),)
ifeq ($(strip $(MAKE_PARALLEL)),no)
	@$(foreach scope,$(SUPPLIER_SCOPE),\
		echo "cawk compute $(scope) devices ----" ;\
		touch $(REPORT_PATH)/repo/assessment.$(scope).csv.swap ;\
		$(foreach test,$(shell find $(TESTS_$(scope)_REPO_PATH) -name '*.gawk' -type f 2>/dev/null),\
			find $(CONFIGURATION_$(scope)_REPO_PATH) -type f -exec ./$(test) {} \; >> $(REPORT_PATH)/repo/assessment.$(scope).csv.swap ;\
		) \
		egrep -v -f $(EXCEPTION_PATH)/repo/exceptions.$(scope) $(REPORT_PATH)/repo/assessment.$(scope).csv.swap | sort | uniq > $(REPORT_PATH)/repo/assessment.$(scope).csv || true ;\
		egrep -f $(EXCEPTION_PATH)/repo/exceptions.$(scope) $(REPORT_PATH)/repo/assessment.$(scope).csv.swap | sort | uniq > $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv || true ;\
		rm -f $(REPORT_PATH)/repo/assessment.$(scope).csv.swap ;\
		$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/repo/assessment.$(scope).csv > $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
	)
else
	@$(foreach scope,$(SUPPLIER_SCOPE),\
		echo "cawk compute $(scope) devices ----" ;\
		touch $(REPORT_PATH)/repo/assessment.$(scope).csv.swap ;\
		find $(CONFIGURATION_$(scope)_REPO_PATH) -type f > $(TESTS_TMP)/conf_list_files.repo.$(scope) 2>/dev/null ;\
		find $(TESTS_$(scope)_REPO_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.repo.$(scope) 2>/dev/null ;\
		$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk $(TESTS_TMP)/conf_list_files.repo.$(scope) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.repo.$(scope) > \
		$(TESTS_TMP)/Makefile.repo.$(scope) ;\
		gmake -f $(TESTS_TMP)/Makefile.repo.$(scope) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(REPORT_PATH)/repo/assessment.$(scope).csv.swap ;\
		egrep -v -f $(EXCEPTION_PATH)/repo/exceptions.$(scope) $(REPORT_PATH)/repo/assessment.$(scope).csv.swap | sort | uniq > \
		$(REPORT_PATH)/repo/assessment.$(scope).csv || true ;\
		egrep -f $(EXCEPTION_PATH)/repo/exceptions.$(scope) $(REPORT_PATH)/repo/assessment.$(scope).csv.swap | sort | uniq > $(REPORT_PATH)/repo/assessment.$(scope).exceptions.csv || true ;\
		rm -f $(REPORT_PATH)/repo/assessment.$(scope).csv.swap ;\
		$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/repo/assessment.$(scope).csv > $(REPORT_PATH)/repo/assessment.$(scope).summary.txt ;\
	)
endif
else
ifeq ($(strip $(MAKE_PARALLEL)),no)
	@echo "cawk compute $(supplier) devices ----"
	@touch $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap
	@$(foreach test,$(shell find $(TESTS_$(supplier)_REPO_PATH) -name '*.gawk' -type f 2>/dev/null),\
		find $(CONFIGURATION_$(supplier)_REPO_PATH) -type f -exec ./$(test) {} \; >> $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap ;\
	)
	@egrep -v -f $(EXCEPTION_PATH)/repo/exceptions.$(supplier) $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap | sort | uniq > $(REPORT_PATH)/repo/assessment.$(supplier).csv || true
	@egrep -f $(EXCEPTION_PATH)/repo/exceptions.$(supplier) $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap | sort | uniq > $(REPORT_PATH)/repo/assessment.$(supplier).exceptions.csv || true
	@rm -f $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap
	@$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/repo/assessment.$(supplier).csv > $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
else
	@echo "cawk compute $(supplier) devices ----"
	@touch $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap
	@find $(CONFIGURATION_$(supplier)_REPO_PATH) -type f > $(TESTS_TMP)/conf_list_files.repo.$(supplier) 2>/dev/null
	@find $(TESTS_$(supplier)_REPO_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.repo.$(supplier) 2>/dev/null
	@$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk $(TESTS_TMP)/conf_list_files.repo.$(supplier) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.repo.$(supplier) > \
	$(TESTS_TMP)/Makefile.repo.$(supplier)
	@gmake -f $(TESTS_TMP)/Makefile.repo.$(supplier) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap
	@egrep -v -f $(EXCEPTION_PATH)/repo/exceptions.$(supplier) $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap | sort | uniq > $(REPORT_PATH)/repo/assessment.$(supplier).csv || true
	@egrep -f $(EXCEPTION_PATH)/repo/exceptions.$(supplier) $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap | sort | uniq > $(REPORT_PATH)/repo/assessment.$(supplier).exceptions.csv || true
	@rm -f $(REPORT_PATH)/repo/assessment.$(supplier).csv.swap
	@$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/repo/assessment.$(supplier).csv > $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
endif
endif
endif
	@echo "cawk check_repo done ----"

# ------------------------------------

check_run: tests_run check_supplier
ifeq ($(strip $(supplier)),)
ifeq ($(strip $(MAKE_PARALLEL)),no)
ifeq ($(strip $(audit)),)
	@$(foreach scope,$(SUPPLIER_SCOPE),\
		echo "cawk compute $(scope) devices ----" ;\
		touch $(REPORT_PATH)/run/assessment.$(scope).csv.swap ;\
		$(foreach test,$(shell find $(TESTS_$(scope)_RUN_PATH) -name '*.gawk' -type f 2>/dev/null),\
			find $(CONFIGURATION_$(scope)_RUN_PATH) -type f -exec ./$(test) {} \; >> $(REPORT_PATH)/run/assessment.$(scope).csv.swap ;\
		) \
		egrep -v -f $(EXCEPTION_PATH)/run/exceptions.$(scope) $(REPORT_PATH)/run/assessment.$(scope).csv.swap | sort | uniq > \
		$(REPORT_PATH)/run/assessment.$(scope).csv || true ;\
		egrep -f $(EXCEPTION_PATH)/run/exceptions.$(scope) $(REPORT_PATH)/run/assessment.$(scope).csv.swap | sort | uniq > \
		$(REPORT_PATH)/run/assessment.$(scope).exceptions.csv || true ;\
		rm -f $(REPORT_PATH)/run/assessment.$(scope).csv.swap ;\
		$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run/assessment.$(scope).csv > $(REPORT_PATH)/run/assessment.$(scope).summary.txt ;\
	)
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	@echo "cawk error: audit=${audit} do not exist  ----"
	@exit 1
endif
	@$(foreach scope,$(SUPPLIER_SCOPE),\
		echo "cawk compute ${audit} $(scope) devices ----" ;\
		touch $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap ;\
		$(foreach test,$(shell find $(TESTS_$(scope)_RUN_PATH) -name '*.gawk' -type f 2>/dev/null),\
			find $(CONFIGURATION_$(scope)_RUN_PATH) -type f -exec ./$(test) {} \; >> $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap ;\
		) \
		egrep -v -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(scope) $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap | sort | uniq > \
		$(REPORT_PATH)/run_${audit}/assessment.$(scope).csv || true ;\
		egrep -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(scope) $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap | sort | uniq > \
		$(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv || true ;\
		rm -f $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap ;\
		$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv > $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt ;\
	)
endif
else
ifeq ($(strip $(audit)),)
	@$(foreach scope,$(SUPPLIER_SCOPE),\
		echo "cawk compute $(scope) devices ----" ;\
		touch $(REPORT_PATH)/run/assessment.$(scope).csv.swap ;\
		find $(CONFIGURATION_$(scope)_RUN_PATH) -type f > $(TESTS_TMP)/conf_list_files.run.$(scope) 2>/dev/null ;\
		find $(TESTS_$(scope)_RUN_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.run.$(scope) 2>/dev/null ;\
		$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk \
		$(TESTS_TMP)/conf_list_files.run.$(scope) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.run.$(scope) > \
		$(TESTS_TMP)/Makefile.run.$(scope) ;\
		gmake -f $(TESTS_TMP)/Makefile.run.$(scope) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(REPORT_PATH)/run/assessment.$(scope).csv.swap ;\
		egrep -v -f $(EXCEPTION_PATH)/run/exceptions.$(scope) $(REPORT_PATH)/run/assessment.$(scope).csv.swap | sort | uniq > \
		$(REPORT_PATH)/run/assessment.$(scope).csv || true ;\
		egrep -f $(EXCEPTION_PATH)/run/exceptions.$(scope) $(REPORT_PATH)/run/assessment.$(scope).csv.swap | sort | uniq > \
		$(REPORT_PATH)/run/assessment.$(scope).exceptions.csv || true ;\
		rm -f $(REPORT_PATH)/run/assessment.$(scope).csv.swap ;\
		$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run/assessment.$(scope).csv > $(REPORT_PATH)/run/assessment.$(scope).summary.txt ;\
	)
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	@echo "cawk error: audit=${audit} do not exist  ----"
	@exit 1
endif
	@$(foreach scope,$(SUPPLIER_SCOPE),\
		echo "cawk compute ${audit} $(scope) devices ----" ;\
		touch $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap ;\
		find $(CONFIGURATION_$(scope)_RUN_PATH) -type f > $(TESTS_TMP)/conf_list_files.${audit}.$(scope) 2>/dev/null ;\
		find $(TESTS_$(scope)_RUN_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.${audit}.$(scope) 2>/dev/null ;\
		$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk \
		$(TESTS_TMP)/conf_list_files.${audit}.$(scope) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.${audit}.$(scope) > \
		$(TESTS_TMP)/Makefile.${audit}.$(scope) ;\
		gmake -f $(TESTS_TMP)/Makefile.${audit}.$(scope) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap ;\
		egrep -v -f $(EXCEPTION_PATH)/run_${audit}//exceptions.$(scope) $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap | sort | uniq > \
		$(REPORT_PATH)/run_${audit}/assessment.$(scope).csv || true ;\
		egrep -f $(EXCEPTION_PATH)/run_${audit}//exceptions.$(scope) $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap | sort | uniq > \
		$(REPORT_PATH)/run_${audit}/assessment.$(scope).exceptions.csv || true ;\
		rm -f $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv.swap ;\
		$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run_${audit}/assessment.$(scope).csv > $(REPORT_PATH)/run_${audit}/assessment.$(scope).summary.txt ;\
	)
endif
endif
else
ifeq ($(strip $(MAKE_PARALLEL)),no)
ifeq ($(strip $(audit)),)
	@echo "cawk compute $(supplier) devices ----"
	@touch $(REPORT_PATH)/run/assessment.$(supplier).csv.swap
	@$(foreach test,$(shell find  $(TESTS_$(supplier)_RUN_PATH) -name '*.gawk' -type f 2>/dev/null),\
		find $(CONFIGURATION_$(supplier)_RUN_PATH) -type f -exec ./$(test) {} \; >> $(REPORT_PATH)/run/assessment.$(supplier).csv.swap ;\
	)
	@egrep -v -f $(EXCEPTION_PATH)/run/exceptions.$(supplier) $(REPORT_PATH)/run/assessment.$(supplier).csv.swap | sort | uniq > \
	$(REPORT_PATH)/run/assessment.$(supplier).csv || true
	@egrep -f $(EXCEPTION_PATH)/run/exceptions.$(supplier) $(REPORT_PATH)/run/assessment.$(supplier).csv.swap | sort | uniq > \
	$(REPORT_PATH)/run/assessment.$(supplier).exceptions.csv || true
	@rm -f $(REPORT_PATH)/run/assessment.$(supplier).csv.swap
	@$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run/assessment.$(supplier).csv > $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	@echo "cawk error: audit=${audit} do not exist  ----"
	@exit 1
endif
	@echo "cawk compute ${audit} $(supplier) devices ----"
	@touch $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap
	@$(foreach test,$(shell find  $(TESTS_$(supplier)_RUN_PATH) -name '*.gawk' -type f 2>/dev/null),\
		find $(CONFIGURATION_$(supplier)_RUN_PATH) -type f -exec ./$(test) {} \; >> $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap ;\
	)
	@egrep -v -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(supplier) $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap | sort | uniq > \
	$(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv || true
	@egrep -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(supplier) $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap | sort | uniq > \
	$(REPORT_PATH)/run_${audit}/assessment.$(supplier).exceptions.csv || true
	@rm -f $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap
	@$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt
endif
else
ifeq ($(strip $(audit)),)
	@echo "cawk compute $(supplier) devices ----"
	@touch $(REPORT_PATH)/run/assessment.$(supplier).csv.swap
	@find $(CONFIGURATION_$(supplier)_RUN_PATH) -type f > $(TESTS_TMP)/conf_list_files.run.$(supplier) 2>/dev/null
	@find $(TESTS_$(supplier)_RUN_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.run.$(supplier) 2>/dev/null
	@$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk $(TESTS_TMP)/conf_list_files.run.$(supplier) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.run.$(supplier) > \
	$(TESTS_TMP)/Makefile.run.$(supplier)
	@gmake -f $(TESTS_TMP)/Makefile.run.$(supplier) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(REPORT_PATH)/run/assessment.$(supplier).csv.swap
	@egrep -v -f $(EXCEPTION_PATH)/run/exceptions.$(supplier) $(REPORT_PATH)/run/assessment.$(supplier).csv.swap | sort | uniq > $(REPORT_PATH)/run/assessment.$(supplier).csv || true
	@egrep -f $(EXCEPTION_PATH)/run/exceptions.$(supplier) $(REPORT_PATH)/run/assessment.$(supplier).csv.swap | sort | uniq > $(REPORT_PATH)/run/assessment.$(supplier).exceptions.csv || true
	@rm -f $(REPORT_PATH)/run/assessment.$(supplier).csv.swap
	@$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run/assessment.$(supplier).csv > $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	@echo "cawk error: audit=${audit} do not exist  ----"
	@exit 1
endif
	@echo "cawk compute ${audit} $(supplier) devices ----"
	@touch $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap
	@find $(CONFIGURATION_$(supplier)_RUN_PATH) -type f > $(TESTS_TMP)/conf_list_files.${audit}.$(supplier) 2>/dev/null
	@find $(TESTS_$(supplier)_RUN_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.${audit}.$(supplier) 2>/dev/null
	@$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk \
	$(TESTS_TMP)/conf_list_files.${audit}.$(supplier) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.${audit}.$(supplier) > \
	$(TESTS_TMP)/Makefile.${audit}.$(supplier)
	@gmake -f $(TESTS_TMP)/Makefile.${audit}.$(supplier) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap
	@egrep -v -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(supplier) $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap | sort | uniq > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv || true
	@egrep -f $(EXCEPTION_PATH)/run_${audit}/exceptions.$(supplier) $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap | sort | uniq > \
	$(REPORT_PATH)/run_${audit}/assessment.$(supplier).exceptions.csv || true
	@rm -f $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv.swap
	@$(TESTS_COMMON_PATH)/report.gawk $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv > $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt
endif
endif
endif
	@echo "cawk check_run done ----"

# --------------------------------

view_repo: check_supplier
ifeq ($(strip $(supplier)),)
	@$(foreach test,$(SUPPLIER_SCOPE),\
		echo "------------------------------------" ;\
		echo "---- Assessment $(test) devices" ;\
		echo "------------------------------------" ;\
		cat $(REPORT_PATH)/repo/assessment.$(test).csv ;\
		echo "-------------------------" ;\
		echo "---- Summary $(test)" ;\
		echo "-------------------------" ;\
		cat $(REPORT_PATH)/repo/assessment.$(test).summary.txt ;\
	)
else
	@echo "------------------------------------"
	@echo "---- Assessment ${audit} $(supplier) devices"
	@echo "------------------------------------"
	@cat $(REPORT_PATH)/repo/assessment.$(supplier).csv
	@echo "------------------------------"
	@echo " ---- Summary ${audit} $(supplier)"
	@echo "------------------------------"
	@cat $(REPORT_PATH)/repo/assessment.$(supplier).summary.txt
endif
	@echo "cawk view_repo done ----"

# --------------------------------

view_run: check_supplier
ifeq ($(strip $(supplier)),)
ifeq ($(strip $(audit)),)
	@$(foreach test,$(SUPPLIER_SCOPE),\
		echo "------------------------------------" ;\
		echo "---- Assessment $(test) devices" ;\
		echo "------------------------------------" ;\
		cat $(REPORT_PATH)/run/assessment.$(test).csv ;\
		echo "-------------------------" ;\
		echo "---- Summary $(test)" ;\
		echo "-------------------------" ;\
		cat $(REPORT_PATH)/run/assessment.$(test).summary.txt ;\
	)
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	@echo "cawk error: audit=${audit} do not exist  ----"
	@exit 1
endif
	@$(foreach test,$(SUPPLIER_SCOPE),\
		echo "------------------------------------" ;\
		echo "---- Assessment ${audit} $(test) devices" ;\
		echo "------------------------------------" ;\
		cat $(REPORT_PATH)/run_${audit}/assessment.$(test).csv ;\
		echo "---------------------------------" ;\
		echo "---- Summary ${audit} $(test)" ;\
		echo "---------------------------------" ;\
		cat $(REPORT_PATH)/run_${audit}/assessment.$(test).summary.txt ;\
	)
endif
else
ifeq ($(strip $(audit)),)
	@echo "--------------------------------------"
	@echo "---- Assessment $(supplier) devices"
	@echo "--------------------------------------"
	@cat $(REPORT_PATH)/run/assessment.$(supplier).csv
	@echo "------------------------------"
	@echo " ---- Summary $(supplier)"
	@echo "------------------------------"
	@cat $(REPORT_PATH)/run/assessment.$(supplier).summary.txt
else
ifeq ($(wildcard $(REPORT_PATH)/run_${audit}/.),)
	@echo "cawk error: audit=${audit} do not exist  ----"
	@exit 1
endif
	@echo "-----------------------------------------------"
	@echo "---- Assessment ${audit} $(supplier) devices"
	@echo "-----------------------------------------------"
	@cat $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv
	@echo "-------------------------------------"
	@echo " ---- Summary ${audit} $(supplier)"
	@echo "-------------------------------------"
	@cat $(REPORT_PATH)/run_${audit}/assessment.$(supplier).summary.txt
endif
endif
	@echo "cawk view_run done ----"

# --------------------------------

view_repo_error: check_supplier
ifeq ($(strip $(supplier)),)
	@$(foreach test,$(SUPPLIER_SCOPE),\
		cat $(REPORT_PATH)/repo/assessment.$(test).csv | grep ";error" | sort | uniq || true ;\
	)
else
	@cat $(REPORT_PATH)/repo/assessment.$(supplier).csv | grep ";error" | sort | uniq || true
endif
	@echo "cawk view_repo_error done ----"

# --------------------------------

view_run_error: check_supplier
ifeq ($(strip $(audit)),)
ifeq ($(strip $(supplier)),)
	@$(foreach test,$(SUPPLIER_SCOPE),\
		cat $(REPORT_PATH)/run/assessment.$(test).csv | grep ";error" | sort | uniq || true ;\
	)
else
	@cat $(REPORT_PATH)/run/assessment.$(supplier).csv | grep ";error" | sort | uniq || true
endif
else
ifeq ($(strip $(supplier)),)
	@$(foreach test,$(SUPPLIER_SCOPE),\
		cat $(REPORT_PATH)/run_${audit}/assessment.$(test).csv | grep ";error" | sort | uniq || true ;\
	)
else
	@cat $(REPORT_PATH)/run_${audit}/assessment.$(supplier).csv | grep ";error" | sort | uniq || true
endif
endif
	@echo "cawk view_run_error done ----"

# --------------------------------

clean: clean_report clean_tmp
	@rm -f $(TESTS_COMMON_PATH)/*.gawk
	@$(foreach scope,$(SUPPLIER_SCOPE),\
		rm -f $(EXCEPTION_PATH)/*/*.$(scope) ;\
	)
	@rm -f $(TESTS_PATH)/repo/*/*.gawk
	@rm -f $(TESTS_PATH)/run/*/*.gawk
	@rm -f $(TESTS_PATH)/run_*/*/*.gawk
	@echo "cawk clean done ----"

clean_report:
	@rm -f $(REPORT_PATH)/repo/*
	@rm -f $(REPORT_PATH)/run/*
	@rm -f $(REPORT_PATH)/run_*/*

clean_tmp:
	@rm -f $(TESTS_TMP)/tmp*
	@rm -f $(TESTS_TMP)/conf_*
	@rm -f $(TESTS_TMP)/Makefile*

# --------------------------------

catalog: tests_repo tests_run
	@$(foreach dir,$(wildcard tests/repo),\
		echo "\n******************************";\
		echo "******************************";\
		echo "---- Tests <run> $(dir) catalog";\
		echo "******************************";\
		echo "******************************";\
		for file in $(wildcard $(dir)/*/*.m4) $(wildcard $(dir)/*/*.template); do \
			grep -H purpose $$file | sed -e 's/# purpose ://g' -e 's/tests\/tests\.//g' || true;\
		done;\
	)
	@$(foreach dir,$(wildcard tests/run),\
		echo "\n******************************";\
		echo "******************************";\
		echo "---- Tests <run> $(dir) catalog";\
		echo "******************************";\
		echo "******************************";\
		for file in $(wildcard $(dir)/*/*.m4) $(wildcard $(dir)/*/*.template); do \
			grep -H purpose $$file | sed -e 's/# purpose ://g' -e 's/tests\/tests\.//g' || true;\
		done;\
	)
	@$(foreach dir,$(wildcard tests/run_*),\
		echo "\n******************************";\
		echo "******************************";\
		echo "---- Tests <run> $(dir) catalog";\
		echo "******************************";\
		echo "******************************";\
		for file in $(wildcard $(dir)/*/*.m4) $(wildcard $(dir)/*/*.template); do \
			grep -H purpose $$file | sed -e 's/# purpose ://g' -e 's/tests\/tests\.//g' || true;\
		done;\
	)
	@echo "cawk catalog done ----"

# --------------------------------

git:
	# git add .
	# git commit -m "*$(CAWK_RELEASE) ref ChangeLog"

gitpush:
	# git push https://github.com/cedricllorens/cawk.git master

# --------------------------------

check:
	@rm -f  checkdiff/checkdiff.new
	@gmake clean check_repo 
	@wc -l reports/*/* >> checkdiff/checkdiff.new
	@gmake clean check_repo supplier=cisco-ios
	@wc -l reports/*/* >> checkdiff/checkdiff.new
	@gmake clean check_run
	@wc -l reports/*/* >> checkdiff/checkdiff.new
	@gmake clean check_run supplier=cisco-ios
	@wc -l reports/*/* >> checkdiff/checkdiff.new
	gmake delete_audit audit=client1_skffqsfqhsf10948494
	gmake create_audit audit=client1_skffqsfqhsf10948494
	@gmake clean check_run audit=client1_skffqsfqhsf10948494
	@wc -l reports/*/* >> checkdiff/checkdiff.new
	@gmake clean check_run audit=client1_skffqsfqhsf10948494 supplier=cisco-ios
	@wc -l reports/*/* >> checkdiff/checkdiff.new
	gmake delete_audit audit=client2_mqsdhqndqqos198440
	gmake create_audit audit=client2_mqsdhqndqqos198440
	@gmake clean check_run audit=client2_mqsdhqndqqos198440
	@wc -l reports/*/* >> checkdiff/checkdiff.new
	@gmake clean check_run audit=client2_mqsdhqndqqos198440 supplier=cisco-ios
	@wc -l reports/*/* >> checkdiff/checkdiff.new
	@gmake clean
	@gmake check_repo
	@gmake check_run
	@gmake check_run audit=client1_skffqsfqhsf10948494
	@gmake check_run audit=client2_mqsdhqndqqos198440
	@wc -l reports/*/* >> checkdiff/checkdiff.new
	@gmake view_repo >> checkdiff/checkdiff.new
	@gmake view_repo_error >> checkdiff/checkdiff.new
	@gmake view_repo supplier=cisco-ios >> checkdiff/checkdiff.new
	@gmake view_run >> checkdiff/checkdiff.new
	@gmake view_run supplier=cisco-ios >> checkdiff/checkdiff.new
	@gmake view_run supplier=cisco-ios audit=client1_skffqsfqhsf10948494 >> checkdiff/checkdiff.new
	@gmake view_run supplier=cisco-ios audit=client2_mqsdhqndqqos198440 >> checkdiff/checkdiff.new
	gmake delete_audit audit=client1_skffqsfqhsf10948494
	gmake delete_audit audit=client2_mqsdhqndqqos198440
	@echo "------------------------------------------------------"
	@echo "------------------------------------------------------"
	@echo "CHECK MUST BE OK -------------------------------------"
	@echo "------------------------------------------------------"
	@diff checkdiff/checkdiff.new checkdiff/checkdiff.old >/dev/null && echo OK || echo NOK
	@echo "------------------------------------------------------"
	@echo "CHECK MUST BE OK -------------------------------------"
	@echo "------------------------------------------------------"
	@echo "------------------------------------------------------"
	@gmake clean
	@echo "cawk check done ----"

check_update: check
	@cp checkdiff/checkdiff.new checkdiff/checkdiff.old
	@echo "cawk check_update done ----"

