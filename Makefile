# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# Makefile
#
# - gmake clean : clean all 
# - gmake tests : build all tests
# - gmake check : assess the confs with tests
# - gmake catalog : build the tests descipriton catalog
# ------------------------------------------------------------

CAWK_RELEASE = v1.0.0

# --------------- TO UPDATE TO A TARGET SYSTEM

COMMON_PATH = common\/common.gawk
GAWK_PATH = !\/usr\/bin\/gawk -f

# --------------- STD CAWK VARS

CONFIGURATION_CISCO_IOS_PATH = conf/conf.cisco-ios
TESTS_CISCO_IOS_REPO_PATH = tests/tests.cisco-ios/repo
TESTS_CISCO_IOS_RUN_PATH = tests/tests.cisco-ios/run
TESTS_CISCO_IOS_REPO_TEMPLATE = $(wildcard $(TESTS_CISCO_IOS_REPO_PATH)/*.template)
TESTS_CISCO_IOS = $(wildcard $(TESTS_CISCO_IOS_REPO_PATH)/*.gawk)
TESTS_CISCO_IOS_RUN = $(wildcard $(TESTS_CISCO_IOS_RUN_PATH)/*.gawk)

CONFIGURATION_JUNIPER_JUNOS_PATH = conf/conf.juniper-junos
TESTS_JUNIPER_JUNOS_REPO_PATH = tests/tests.juniper-junos/repo
TESTS_JUNIPER_JUNOS_RUN_PATH = tests/tests.juniper-junos/run
TESTS_JUNIPER_JUNOS_REPO_TEMPLATE = $(wildcard $(TESTS_JUNIPER_JUNOS_REPO_PATH)/*.template)
TESTS_JUNIPER_JUNOS = $(wildcard $(TESTS_JUNIPER_JUNOS_REPO_PATH)/*.gawk)
TESTS_JUNIPER_JUNOS_RUN = $(wildcard $(TESTS_JUNIPER_JUNOS_RUN_PATH)/*.gawk)

CONFIGURATION_HUAWEI_PATH = conf/conf.huawei
TESTS_HUAWEI_REPO_PATH = tests/tests.huawei/repo
TESTS_HUAWEI_RUN_PATH = tests/tests.huawei/run
TESTS_HUAWEI_PATH = tests/tests.huawei/run
TESTS_HUAWEI_REPO_TEMPLATE = $(wildcard $(TESTS_HUAWEI_REPO_PATH)/*.template)
TESTS_HUAWEI = $(wildcard $(TESTS_HUAWEI_REPO_PATH)/*.gawk)
TESTS_HUAWEI_RUN = $(wildcard $(TESTS_HUAWEI_RUN_PATH)/*.gawk)

TESTS_REPORT = report
TESTS_CATALOG = $(TESTS_CISCO_IOS_REPO_PATH) \
		$(TESTS_JUNIPER_JUNOS_REPO_PATH) \
		$(TESTS_HUAWEI_REPO_PATH)
TESTS_CATALOG_RUN = $(TESTS_CISCO_IOS_RUN_PATH) \
		$(TESTS_JUNIPER_JUNOS_RUN_PATH) \
		$(TESTS_HUAWEI_RUN_PATH)

# --------------- TO BUILD TESTS IN REPO AND RUN

%: $(TESTS_CISCO_IOS_REPO_PATH)/%.template
	sed -e 's/INCLUDE_PATH/"$(COMMON_PATH)"/g' -e 's/GAWK_PATH/$(GAWK_PATH)/g' -f support/tests.sed $< > $(TESTS_CISCO_IOS_REPO_PATH)/$@ || true
	chmod 750 $(TESTS_CISCO_IOS_REPO_PATH)/$@

%: $(TESTS_CISCO_IOS_RUN_PATH)/%.template
	sed -e 's/INCLUDE_PATH/"$(COMMON_PATH)"/g' -e 's/GAWK_PATH/$(GAWK_PATH)/g' -f support/tests.sed $< > $(TESTS_CISCO_IOS_RUN_PATH)/$@ || true
	chmod 750 $(TESTS_CISCO_IOS_RUN_PATH)/$@

%: $(TESTS_JUNIPER_JUNOS_REPO_PATH)/%.template
	sed -e 's/INCLUDE_PATH/"$(COMMON_PATH)"/g' -e 's/GAWK_PATH/$(GAWK_PATH)/g' -f support/tests.sed $< > $(TESTS_JUNIPER_JUNOS_REPO_PATH)/$@ || true
	chmod 750 $(TESTS_JUNIPER_JUNOS_REPO_PATH)/$@

%: $(TESTS_JUNIPER_JUNOS_RUN_PATH)/%.template
	sed -e 's/INCLUDE_PATH/"$(COMMON_PATH)"/g' -e 's/GAWK_PATH/$(GAWK_PATH)/g' -f support/tests.sed $< > $(TESTS_JUNIPER_JUNOS_RUN_PATH)/$@ || true
	chmod 750 $(TESTS_JUNIPER_JUNOS_RUN_PATH)/$@

%: $(TESTS_HUAWEI_REPO_PATH)/%.template
	sed -e 's/INCLUDE_PATH/"$(COMMON_PATH)"/g' -e 's/GAWK_PATH/$(GAWK_PATH)/g' -f support/tests.sed $< > $(TESTS_HUAWEI_REPO_PATH)/$@ || true
	chmod 750 $(TESTS_HUAWEI_REPO_PATH)/$@

%: $(TESTS_HUAWEI_RUN_PATH)/%.template
	sed -e 's/INCLUDE_PATH/"$(COMMON_PATH)"/g' -e 's/GAWK_PATH/$(GAWK_PATH)/g' -f support/tests.sed $< > $(TESTS_HUAWEI_RUN_PATH)/$@ || true
	chmod 750 $(TESTS_HUAWEI_RUN_PATH)/$@

# --------------- GNU MAKE TARGETS

.phony: all check_repo check_run tests clean clean_report catalog git

all:
	# --------------------------------------------------------
	# to clean : gmake clean
	# to build tests : gmake clean tests
	# to launch <repo> tests over configurations directory : gmake check_repo
	# to launch <run> tests over configurations directory : gmake check_run
	# --------------------------------------------------------

tests: 	$(TESTS_CISCO_IOS_REPO_TEMPLATE:$(TESTS_CISCO_IOS_REPO_PATH)/%.template=%) \
	$(TESTS_CISCO_IOS_REPO_TEMPLATE:$(TESTS_CISCO_IOS_RUN_PATH)/%.template=%) \
	$(TESTS_JUNIPER_JUNOS_REPO_TEMPLATE:$(TESTS_JUNIPER_JUNOS_REPO_PATH)/%.template=%) \
	$(TESTS_JUNIPER_JUNOS_REPO_TEMPLATE:$(TESTS_JUNIPER_JUNOS_RUN_PATH)/%.template=%) \
	$(TESTS_HUAWEI_REPO_TEMPLATE:$(TESTS_HUAWEI_REPO_PATH)/%.template=%) \
	$(TESTS_HUAWEI_REPO_TEMPLATE:$(TESTS_HUAWEI_RUN_PATH)/%.template=%)

check_repo: clean_report

	echo "---- Launch <repo> tests ----"

	@touch $(TESTS_REPORT)/assessment.cisco-ios.csv
	@echo "---- Assessment cisco-ios devices ----"
	@$(foreach test,$(TESTS_CISCO_IOS),\
		find $(CONFIGURATION_CISCO_IOS_PATH) -type f -exec ./$(test) {} \; >> $(TESTS_REPORT)/assessment.cisco-ios.csv ;\
	)
	@cat $(TESTS_REPORT)/assessment.cisco-ios.csv

	@echo "---- Assessment juniper-junos devices ----"
	@touch $(TESTS_REPORT)/assessment.juniper-junos.csv
	@$(foreach test,$(TESTS_JUNIPER_JUNOS),\
		find $(CONFIGURATION_JUNIPER_JUNOS_PATH) -type f -exec ./$(test) {} \; >> $(TESTS_REPORT)/assessment.juniper-junos.csv ;\
	)
	@cat $(TESTS_REPORT)/assessment.juniper-junos.csv

	@echo "---- Assessment huawei devices ----"
	@touch $(TESTS_REPORT)/assessment.huawei.csv
	@$(foreach test,$(TESTS_HUAWEI),\
		find $(CONFIGURATION_HUAWEI_PATH) -type f -exec ./$(test) {} \; >> $(TESTS_REPORT)/assessment.huawei.csv ;\
	)
	@cat $(TESTS_REPORT)/assessment.huawei.csv

check_run: clean_report

	echo "---- Launch <run> tests ----"

	@touch $(TESTS_REPORT)/assessment.cisco-ios.csv
	@echo "---- Assessment cisco-ios devices ----"
	@$(foreach test,$(TESTS_CISCO_IOS_RUN),\
		find $(CONFIGURATION_CISCO_IOS_PATH) -type f -exec ./$(test) {} \; >> $(TESTS_REPORT)/assessment.cisco-ios.csv ;\
	)
	@cat $(TESTS_REPORT)/assessment.cisco-ios.csv || true

	@echo "---- Assessment juniper-junos devices ----"
	@touch $(TESTS_REPORT)/assessment.juniper-junos.csv
	@$(foreach test,$(TESTS_JUNIPER_JUNOS_RUN),\
		find $(CONFIGURATION_JUNIPER_JUNOS_PATH) -type f -exec ./$(test) {} \; >> $(TESTS_REPORT)/assessment.juniper-junos.csv ;\
	)
	@cat $(TESTS_REPORT)/assessment.juniper-junos.csv || true

	@echo "---- Assessment huawei devices ----"
	@touch $(TESTS_REPORT)/assessment.huawei.csv 
	@$(foreach test,$(TESTS_HUAWEI_RUN),\
		find $(CONFIGURATION_HUAWEI_PATH) -type f -exec ./$(test) {} \; >> $(TESTS_REPORT)/assessment.huawei.csv ;\
	)
	@cat $(TESTS_REPORT)/assessment.huawei.csv || true

clean: clean_report
	$(foreach test,$(TESTS_CISCO_IOS),\
		rm -f $(test);\
	)

	$(foreach test,$(TESTS_JUNIPER_JUNOS),\
		rm -f $(test);\
	)

	$(foreach test,$(TESTS_HUAWEI),\
		rm -f $(test);\
	)

clean_report:
	@rm -f $(TESTS_REPORT)/*

catalog:
	echo "---- Tests <repo> catalog ----"
	@$(foreach id,$(TESTS_CATALOG),\
		grep -H purpose $(id)/*template;\
	)

	echo "---- Tests <run> catalog ----"
	@$(foreach id,$(TESTS_CATALOG_RUN),\
		grep -H purpose $(id)/*template || true;\
	)

git:
	# regular update
	#      git add .
	#      git commit -m "Mettre son msg"
	# push of a new version
	#      git tag -a $(CAWK_RELEASE) -m "$(CAWK_RELEASE)"
	#      git push https://github.com/cedricllorens/cawk.git $(CAWK_RELEASE)
