# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# cawk is Copyright (C) 2024 by Cedric Llorens
# ------------------------------------------------------------
#
# Makefile
# - gmake 		: print all the possible targets
# - gmake clean 	: clean all 
# - gmake tests_repo 	: build all <repo> tests
# - gmake tests_run 	: build all <run> tests
# - gmake check_repo 	: assess the confs with <repo> tests
# - gmake check_run 	: assess the confs with <run> tests
# - gmake view 		: view the assessment reports (and summary)
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

CONFIGURATION_huawei_PATH = conf/conf.huawei
TESTS_huawei_REPO_PATH = tests/tests.huawei/repo
TESTS_huawei_RUN_PATH = tests/tests.huawei/run
TESTS_huawei_REPO_TEMPLATE = $(wildcard $(TESTS_huawei_REPO_PATH)/*.template)
TESTS_huawei_RUN_TEMPLATE = $(wildcard $(TESTS_huawei_RUN_PATH)/*.template)

CONFIGURATION_fortinet_PATH = conf/conf.fortinet
TESTS_fortinet_REPO_PATH = tests/tests.fortinet/repo
TESTS_fortinet_RUN_PATH = tests/tests.fortinet/run
TESTS_fortinet_REPO_TEMPLATE = $(wildcard $(TESTS_fortinet_REPO_PATH)/*.template)
TESTS_fortinet_RUN_TEMPLATE = $(wildcard $(TESTS_fortinet_RUN_PATH)/*.template)

TESTS_REPORT = report

TESTS_SCOPE = cisco-ios juniper-junos huawei fortinet

TESTS_CATALOG = $(TESTS_cisco-ios_REPO_PATH) \
		$(TESTS_juniper-junos_REPO_PATH) \
		$(TESTS_huawei_REPO_PATH) \
		$(TESTS_fortinet_REPO_PATH)
TESTS_CATALOG_RUN = $(TESTS_cisco-ios_RUN_PATH) \
		$(TESTS_juniper-junos_RUN_PATH) \
		$(TESTS_huawei_RUN_PATH) \
		$(TESTS_fortinet_RUN_PATH)

# --------------- TESTS BUILDING BY SED CHANGE

%.gawk: %.gawk.template
	sed -f support/tests.sed $< > $@ || true
	chmod 750 $@

# --------------- GNU MAKE TARGETS

.phony: all check_repo check_run tests view clean_report clean catalog git

all:
	# ------------------------------------------------------------
	# - gmake 		: print all the possible targets
	# - gmake clean 	: clean all 
	# - gmake tests_repo 	: build all <repo> tests
	# - gmake tests_run 	: build all <run> tests
	# - gmake check_repo 	: assess the confs with <repo> tests
	# - gmake check_run 	: assess the confs with <run> tests
	# - gmake view		: view the reports and the summary
	# - gmake catalog 	: build the tests description catalog
	# ------------------------------------------------------------

tests_repo: $(TESTS_COMMON_TEMPLATE:.gawk.template=.gawk) $(TESTS_cisco-ios_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_juniper-junos_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_huawei_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_fortinet_REPO_TEMPLATE:.gawk.template=.gawk)
	@echo "cawk tests_repo done ----"

tests_run: $(TESTS_COMMON_TEMPLATE:.gawk.template=.gawk) $(TESTS_cisco-ios_RUN_TEMPLATE:.gawk.template=.gawk) $(TESTS_juniper-junos_RUN_TEMPLATE:.gawk.template=.gawk) $(TESTS_huawei_RUN_TEMPLATE:.gawk.template=.gawk) $(TESTS_fortinet_RUN_TEMPLATE:.gawk.template=.gawk)
	@echo "cawk tests_run done ----"

check_repo: clean_report $(TESTS_COMMON_TEMPLATE:.gawk.template=.gawk) $(TESTS_cisco-ios_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_juniper-junos_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_huawei_REPO_TEMPLATE:.gawk.template=.gawk) $(TESTS_fortinet_REPO_TEMPLATE:.gawk.template=.gawk)
	@$(foreach scope,$(TESTS_SCOPE),\
		echo "Compute $(scope) devices ----" ;\
		touch $(TESTS_REPORT)/assessment.$(scope).csv ;\
		$(foreach test,$(TESTS_$(scope)_REPO_TEMPLATE:.gawk.template=.gawk),\
			find $(CONFIGURATION_$(scope)_PATH) -type f -exec ./$(test) {} \; >> $(TESTS_REPORT)/assessment.$(scope).csv ;\
		) \
		$(TESTS_COMMON_PATH)/report.gawk $(TESTS_REPORT)/assessment.$(scope).csv > $(TESTS_REPORT)/assessment.$(scope).summary.txt ;\
	)
	@echo "cawk check_repo done ----"

check_run: clean_report $(TESTS_COMMON_TEMPLATE:.gawk.template=.gawk) $(TESTS_cisco-ios_RUN_TEMPLATE:.gawk.template=.gawk) $(TESTS_juniper-junos_RUN_TEMPLATE:.gawk.template=.gawk) $(TESTS_huawei_RUN_TEMPLATE:.gawk.template=.gawk) $(TESTS_fortinet_RUN_TEMPLATE:.gawk.template=.gawk)
	@$(foreach scope,$(TESTS_SCOPE),\
		echo "Compute $(scope) devices ----" ;\
		touch $(TESTS_REPORT)/assessment.$(scope).csv ;\
		$(foreach test,$(TESTS_$(scope)_RUN_TEMPLATE:.gawk.template=.gawk),\
			find $(CONFIGURATION_$(scope)_PATH) -type f -exec ./$(test) {} \; >> $(TESTS_REPORT)/assessment.$(scope).csv ;\
		) \
		$(TESTS_COMMON_PATH)/report.gawk $(TESTS_REPORT)/assessment.$(scope).csv > $(TESTS_REPORT)/assessment.$(scope).summary.txt ;\
	)
	@echo "cawk check_run done ----"

view:
	@$(foreach test,$(TESTS_SCOPE),\
		echo "---- Assessment $(test) devices ----" ;\
		cat $(TESTS_REPORT)/assessment.$(test).csv ;\
		echo "summary ----" ;\
		cat $(TESTS_REPORT)/assessment.$(test).summary.txt ;\
	)
	@echo "cawk view done ----"

clean: clean_report
	@rm -f $(TESTS_COMMON_PATH)/*.gawk
	@$(foreach scope,$(TESTS_SCOPE),\
		rm -f $(TESTS_$(scope)_REPO_PATH)/*.gawk $(TESTS_$(scope)_RUN_PATH)/*.gawk ;\
	)
	@echo "cawk clean done ----"

clean_report:
	@rm -f $(TESTS_REPORT)/*

catalog:
	@echo "---- Tests <repo> catalog ----"
	@$(foreach id,$(TESTS_CATALOG),\
		grep -H purpose $(id)/*template | sed -e 's/# purpose ://g' || true;\
	)

	@echo "---- Tests <run> catalog ----"
	@$(foreach id,$(TESTS_CATALOG_RUN),\
		grep -H purpose $(id)/*template | sed -e 's/# purpose ://g' || true;\
	)
	@echo "cawk catalog done ----"

git:
	# --------
	# regular update
	#      git add .
	#      git commit -m "msg"
	# --------
	# push of a new version
	#      git push https://github.com/cedricllorens/cawk.git master
	# build a release directly at github level
