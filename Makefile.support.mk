# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

# ===============================================================================
# VERSION & CORE SETTINGS
# ===============================================================================

CAWK_RELEASE = v3.7.0
RM ?= rm
GMAKE ?= gmake

# ===============================================================================
# DIRECTORY PATHS
# ===============================================================================

CONFS_PATH = confs
COMMON_PATH = common
BACKUP_PATH = backup
DATABASE_PATH = database
DATABASE_CIS_INFO = $(DATABASE_PATH)/db_info.txt
LOGS_PATH = logs
DATABASE_SH_PATH = $(DATABASE_PATH)/scripts
DATABASE_SH = $(wildcard $(DATABASE_SH_PATH)/*.script.sh)
REPORT_PATH = reports

TESTS_COMMON_PATH = common
TESTS_PATH = tests
TESTS_COMMON_TEMPLATE = $(wildcard $(TESTS_COMMON_PATH)/*.template)
TESTS_COMMON_SH = $(wildcard $(TESTS_COMMON_PATH)/*.script.sh)
TESTS_SYSTEM = system
TESTS_TMP = tmp

EXCEPTION_PATH = exceptions

# ===============================================================================
# AUDIT DISCOVERY (dynamic run_audit directories)
# ===============================================================================

# Deferred (=) on purpose: this find must run only when a target actually reads
# RUN_DIRS (check_run_audit), not at parse time of every (recursive) make invocation.
RUN_DIRS = $(shell find -L tests -name '*run_*' -type d 2>/dev/null | awk -F'run_' '{print $$NF}' | sort -u || echo "")

# ===============================================================================
# Mark temporary files for automatic cleanup
# ===============================================================================
.INTERMEDIATE: $(REPORT_PATH)/repo/*.swap $(REPORT_PATH)/run/*.swap $(REPORT_PATH)/run_*/*.swap

# ===============================================================================
# PATTERN RULES FOR COMPILATION
# ===============================================================================
# NOTE: Pattern rules (not PHONY targets) generate real compiled files.
# Make automatically detects when .template/.m4/.include sources change.
# These rules must NOT be marked .PHONY (they produce actual file artifacts).
# ===============================================================================

%.gawk: %.gawk.template
	sed -f support/tests.sed $< > $@ || true
	@if [ ! -s $@ ]; then \
		$(ECHO) "cawk error: failed to compile $< (empty file in $@)"; \
		rm -f $@; \
		false; \
	elif ! echo "$<" | grep -q "^common/"; then \
		if ! head -1 $@ | grep -q "^#!"; then \
			$(ECHO) "cawk error: failed to compile $< (missing shebang in $@)"; \
			rm -f $@; \
			false; \
		fi; \
	fi
	chmod 750 $@

%.gawk: %.gawk.include
	sed -e 's|CAWK_PSIRT_NAME|$(basename $@).gawk.include|g' -e 's|CAWK_PSIRT_TESTNAME|$(notdir $(basename $@))|g' -e 's|CAWK_PSIRT_OS|os|g' common/test_generic_psirt.gawk.template > $@.swap || true
	sed -f support/tests.sed $@.swap > $@ || true
	@if [ ! -s $@ ]; then \
		$(ECHO) "cawk error: failed to compile $< (empty file in $@)"; \
		rm -f $@ $@.swap; \
		false; \
	elif ! head -1 $@ | grep -q "^#!"; then \
		$(ECHO) "cawk error: failed to compile $< (missing shebang in $@)"; \
		rm -f $@ $@.swap; \
		false; \
	fi
	rm -f $@.swap
	chmod 750 $@

%.gawk: %.gawk.m4
	m4 -I m4 $< | sed -f support/tests.sed > $@ || true
	@if [ ! -s $@ ]; then \
		$(ECHO) "cawk error: failed to compile $< (empty file in $@)"; \
		rm -f $@; \
		false; \
	elif ! echo "$<" | grep -q "^common/"; then \
		if ! head -1 $@ | grep -q "^#!"; then \
			$(ECHO) "cawk error: failed to compile $< (missing shebang in $@)"; \
			rm -f $@; \
			false; \
		fi; \
	fi
	chmod 750 $@

%.script: %.script.sh
	cp $< $@ || true
	chmod 750 $@

%: %.m4
	m4 -I m4 $< | sed '/^$$/d' > $@ || true

checkdiff/scripts/%: checkdiff/scripts/%.sh
	cp $< $@ || true
	chmod 755 $@

# ===============================================================================
# SUPPLIERS/PLATFORMS SCOPE
# ===============================================================================

SUPPLIER_SCOPE = cisco-ios cisco-xr juniper-junos huawei-vrp fortinet-fortios \
                 nokia-sros paloalto-panos cisco-viptela cisco-cedge cisco-xe \
                 packetfilter-fwcli checkpoint-fwcli iptables-fwcli 6wind-linux ekinops-oneos

# ===============================================================================
# TEST FILE COMPILATION LISTS (standard & PSIRT)
# ===============================================================================

# Standard tests compilation targets (template + m4 sources)
SUPPLIER_M4_REPO_FILES = $(foreach supplier,$(SUPPLIER_SCOPE),$(TESTS_$(supplier)_REPO_M4:.gawk.m4=.gawk))
SUPPLIER_TEMPLATE_REPO_FILES = $(foreach supplier,$(SUPPLIER_SCOPE),$(TESTS_$(supplier)_REPO_TEMPLATE:.gawk.template=.gawk))
SUPPLIER_M4_RUN_FILES = $(foreach supplier,$(SUPPLIER_SCOPE),$(TESTS_$(supplier)_RUN_M4:.gawk.m4=.gawk))
SUPPLIER_TEMPLATE_RUN_FILES = $(foreach supplier,$(SUPPLIER_SCOPE),$(TESTS_$(supplier)_RUN_TEMPLATE:.gawk.template=.gawk))

# PSIRT tests compilation targets (template, m4, and include sources)
SUPPLIER_M4_REPO_PSIRT_FILES = $(foreach supplier,$(SUPPLIER_SCOPE),$(TESTS_$(supplier)_REPO_PSIRT_M4:.gawk.m4=.gawk))
SUPPLIER_TEMPLATE_REPO_PSIRT_FILES = $(foreach supplier,$(SUPPLIER_SCOPE),$(TESTS_$(supplier)_REPO_PSIRT_TEMPLATE:.gawk.template=.gawk))
SUPPLIER_INCLUDE_REPO_PSIRT_FILES = $(foreach supplier,$(SUPPLIER_SCOPE),$(TESTS_$(supplier)_REPO_PSIRT_INCLUDE:.gawk.include=.gawk))
SUPPLIER_M4_RUN_PSIRT_FILES = $(foreach supplier,$(SUPPLIER_SCOPE),$(TESTS_$(supplier)_RUN_PSIRT_M4:.gawk.m4=.gawk))
SUPPLIER_TEMPLATE_RUN_PSIRT_FILES = $(foreach supplier,$(SUPPLIER_SCOPE),$(TESTS_$(supplier)_RUN_PSIRT_TEMPLATE:.gawk.template=.gawk))
SUPPLIER_INCLUDE_RUN_PSIRT_FILES = $(foreach supplier,$(SUPPLIER_SCOPE),$(TESTS_$(supplier)_RUN_PSIRT_INCLUDE:.gawk.include=.gawk))

# Configurations paths
define supplier_template

# standard configurations paths
CONFIGURATION_$(1)_REPO_PATH = $$(CONFS_PATH)/repo/confs.$(1)
ifeq ($$(strip $$(audit)),)
	CONFIGURATION_$(1)_RUN_PATH = $$(CONFS_PATH)/run/confs.$(1)
else
	CONFIGURATION_$(1)_RUN_PATH = $$(CONFS_PATH)/run_$${audit}/confs.$(1)
endif

# standard tests paths
TESTS_$(1)_REPO_PATH = $$(TESTS_PATH)/repo/tests.$(1)
ifeq ($$(strip $$(audit)),)
	TESTS_$(1)_RUN_PATH = $$(TESTS_PATH)/run/tests.$(1)
else
	TESTS_$(1)_RUN_PATH = $$(TESTS_PATH)/run_$${audit}/tests.$(1)
endif

# psirt tests directory paths
TESTS_$(1)_REPO_PSIRT_PATH = $$(TESTS_PATH)/repo/tests.$(1).psirt
ifeq ($$(strip $$(audit)),)
	TESTS_$(1)_RUN_PSIRT_PATH = $$(TESTS_PATH)/run/tests.$(1).psirt
else
	TESTS_$(1)_RUN_PSIRT_PATH = $$(TESTS_PATH)/run_$${audit}/tests.$(1).psirt
endif

# standard tests files (template and m4)
TESTS_$(1)_REPO_TEMPLATE = $$(wildcard $$(TESTS_$(1)_REPO_PATH)/*.template)
TESTS_$(1)_REPO_M4 = $$(wildcard $$(TESTS_$(1)_REPO_PATH)/*.m4)
TESTS_$(1)_RUN_TEMPLATE = $$(wildcard $$(TESTS_$(1)_RUN_PATH)/*.template)
TESTS_$(1)_RUN_M4 = $$(wildcard $$(TESTS_$(1)_RUN_PATH)/*.m4)

# psirt tests files (template and m4)
TESTS_$(1)_REPO_PSIRT_TEMPLATE = $$(wildcard $$(TESTS_$(1)_REPO_PSIRT_PATH)/*.template)
TESTS_$(1)_REPO_PSIRT_INCLUDE = $$(wildcard $$(TESTS_$(1)_REPO_PSIRT_PATH)/*.include)
TESTS_$(1)_REPO_PSIRT_M4 = $$(wildcard $$(TESTS_$(1)_REPO_PSIRT_PATH)/*.m4)
TESTS_$(1)_RUN_PSIRT_TEMPLATE = $$(wildcard $$(TESTS_$(1)_RUN_PSIRT_PATH)/*.template)
TESTS_$(1)_RUN_PSIRT_INCLUDE = $$(wildcard $$(TESTS_$(1)_RUN_PSIRT_PATH)/*.include)
TESTS_$(1)_RUN_PSIRT_M4 = $$(wildcard $$(TESTS_$(1)_RUN_PSIRT_PATH)/*.m4)

endef

# Generate rules for all suppliers
$(foreach supplier,$(SUPPLIER_SCOPE),$(eval $(call supplier_template,$(supplier))))

# ===============================================================================
# CAWK EXECUTION OPTIONS
# ===============================================================================

TEST_EXE = -exec ./$(test) {} +
EGREP = grep -E
ECHO = echo

# ===============================================================================
# PARALLEL EXECUTION OPTIONS
# ===============================================================================
# Control how cawk distributes test execution across multiple CPU cores

# Enable parallel mode (yes/no) — spawns multiple make jobs
MAKE_PARALLEL ?= no

# Number of configuration files per target job (optimize granularity)
MAKE_FILES_PER_TARGET ?= 100
MAKE_FILES_PER_TARGET_PSIRT ?= 1

# GNU Make parallel job options (used when MAKE_PARALLEL=yes)
# Default to the host CPU count (fallback 4/3 if nproc is unavailable).
MAKE_J ?= $(shell nproc 2>/dev/null || echo 4)
MAKE_LOAD_AVG ?= $(shell nproc 2>/dev/null || echo 3)

# Suppress verbose gmake output
MAKEFLAGS += -s

# ===============================================================================
# ASSESSMENT & REPORTING OPTIONS
# ===============================================================================

# File selection filter for find (exclude directories)
FIND_CONF_SELECT = ! -type d

# Generate JSON reports alongside text reports (yes/no)
JSON ?= no

# Regenerate test metadata database at build time (yes/no)
CATALOG_BUILD ?= no

# Flag configurations not modified in N days as stale (yes/no)
DEADBEEF ?= no
DEADBEEF_THRESHOLD_DAYS ?= 30

# Auto-archive reports older than N days during cleanup
ARCHIVE_OLDER_DAYS ?= 120

# PSIRT assessment mode (yes/no)
#   no  = run standard tests + PSIRT tests (default)
#   yes = run ONLY PSIRT tests (standard tests are skipped)
# Note: PSIRT tests are always compiled; this flag only selects which tests run at assessment time.
PSIRT ?= no

# Remove intermediate assessment files after reporting (yes/no)
TMP_ASSESSMENT_FILES ?= yes

# ===============================================================================
# MACROS DATABASE
# ===============================================================================

# -------------------------------------------------------------------------------------------
# MACRO: sort_database_file — Sort flat-file database by first field (audit name)
# -------------------------------------------------------------------------------------------
# $(1) = database file path (db_sync.txt, db_email.txt, db_postaudit.txt)
# -------------------------------------------------------------------------------------------
define sort_database_file
	@if [ -s $(1) ]; then sort -k1 $(1) -o $(1); fi
endef

# ===============================================================================
# MACROS REPORT
# ===============================================================================

# DEADBEEF ----

# -------------------------------------------------------------------------------------------
# MACRO: cawk_deadbeef_scan — Per-device deadbeef+idx scan for one scope/supplier
# -------------------------------------------------------------------------------------------
# Single-line form (foreach-safe: expansion ends with ';'). Covers only the per-scope scan;
# the final 'assessment.all.deadbeef.idx' generation stays inline (runs once, after the loop).
# $(1) = scope/supplier, $(2) = path infix (REPO|RUN), $(3) = report dir (repo|run|run_$${audit})
# -------------------------------------------------------------------------------------------
define cawk_deadbeef_scan
	find $(CONFIGURATION_$(1)_$(2)_PATH) $(FIND_CONF_SELECT) -exec ./$(TESTS_COMMON_PATH)/deadbeef_cawk_conf.script $(DEADBEEF_THRESHOLD_DAYS) {} \; > $(REPORT_PATH)/$(3)/assessment.$(1).deadbeef.csv 2>/dev/null || true ;\
	cat $(REPORT_PATH)/$(3)/assessment.$(1).deadbeef.csv >> $(REPORT_PATH)/$(3)/assessment.all.deadbeef.csv ;\
	find $(CONFIGURATION_$(1)_$(2)_PATH) $(FIND_CONF_SELECT) > $(REPORT_PATH)/$(3)/assessment.$(1).idx 2>/dev/null || true ;\
	awk -v scope=$(1) '{print $$0,scope}' $(REPORT_PATH)/$(3)/assessment.$(1).idx >> $(REPORT_PATH)/$(3)/assessment.all.idx.swap ;
endef

# RUN && PSIRT ----

# -------------------------------------------------------------------------------------------
# MACRO: cawk_test_execution — Execute tests and collect assessment results
# -------------------------------------------------------------------------------------------
# $(1) = tests_path_std, $(2) = config_path, $(3) = output_csv, $(4) = tests_path_psirt
# -------------------------------------------------------------------------------------------
define cawk_test_execution
	$(if $(filter no,$(PSIRT)),\
		$(foreach test,$(shell find $(1) -name '*.gawk' -type f 2>/dev/null || true),\
			find $(2) $(FIND_CONF_SELECT) $(TEST_EXE) >> $(3) 2>/dev/null || true ;\
		),\
		touch $(3) ;\
	) \
	$(foreach test,$(shell find $(4) -name '*.gawk' -type f 2>/dev/null || true),\
		find $(2) $(FIND_CONF_SELECT) $(TEST_EXE) >> $(3) 2>/dev/null || true ;\
	)
endef

# -------------------------------------------------------------------------------------------
# MACRO: cawk_test_gen_parallel — Parallel-mode standard-test generation+run for one scope/supplier
# -------------------------------------------------------------------------------------------
# Single-line form (foreach-safe: expansion ends with ';'). The per-scope ECHO is kept inline
# (its wording varies per case), so this macro covers only the gen/run body.
# $(1) = scope/supplier, $(2) = path infix (REPO|RUN), $(3) = report dir (repo|run|run_$${audit}), $(4) = tmp suffix (repo|run|$${audit})
# -------------------------------------------------------------------------------------------
define cawk_test_gen_parallel
	find $(CONFIGURATION_$(1)_$(2)_PATH) $(FIND_CONF_SELECT) > $(TESTS_TMP)/conf_list_files.$(4).$(1) 2>/dev/null || true ;\
	$(if $(filter no,$(PSIRT)),\
		find $(TESTS_$(1)_$(2)_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.$(4).$(1) 2>/dev/null || true ;\
		$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk $(TESTS_TMP)/conf_list_files.$(4).$(1) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.$(4).$(1) > $(TESTS_TMP)/Makefile.$(4).$(1) 2>/dev/null || true ;\
		$(GMAKE) -f $(TESTS_TMP)/Makefile.$(4).$(1) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all >> $(REPORT_PATH)/$(3)/assessment.$(1).csv.swap 2>/dev/null || true ;\
		,\
		touch $(REPORT_PATH)/$(3)/assessment.$(1).csv.swap ;\
	)
endef

# CONTEXT LOCAL REPORT ----

# -------------------------------------------------------------------------------------------
# MACRO: cawk_report_scope_local — Filter exceptions and generate assessment summary reports
# -------------------------------------------------------------------------------------------
# $(1) = scope/supplier, $(2) = report_base (repo|run|run_${audit}), $(3) = exception_context (repo|run|run_${audit})
# $(4) = catalog tmp tag (repo|run|$(audit)) — see cawk_catalog_precompute, which must run once before this macro
# -------------------------------------------------------------------------------------------
define cawk_report_scope_local
# exception ---
	$(EGREP) -v -f $(EXCEPTION_PATH)/$(3)/exceptions.$(1) $(REPORT_PATH)/$(2)/assessment.$(1).csv.swap | sort -u > $(REPORT_PATH)/$(2)/assessment.$(1).csv || true
	cat $(REPORT_PATH)/$(2)/assessment.$(1).csv >> $(REPORT_PATH)/$(2)/assessment.all.csv.swap
	$(EGREP) -f $(EXCEPTION_PATH)/$(3)/exceptions.$(1) $(REPORT_PATH)/$(2)/assessment.$(1).csv.swap | $(EGREP) ';error' | sort -u > $(REPORT_PATH)/$(2)/assessment.$(1).exceptions.csv || true
	cat $(REPORT_PATH)/$(2)/assessment.$(1).exceptions.csv >> $(REPORT_PATH)/$(2)/assessment.all.exception.csv
# local ---
	$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/$(2)/assessment.all.deadbeef.csv $(REPORT_PATH)/$(2)/assessment.$(1).exceptions.csv $(REPORT_PATH)/$(2)/assessment.$(1).csv > $(REPORT_PATH)/$(2)/assessment.$(1).summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/$(2)/assessment.$(1).summary.txt
	$(ECHO) "---- tests purposes ----" >> $(REPORT_PATH)/$(2)/assessment.$(1).summary.txt
	$(ECHO) "------------------------" >> $(REPORT_PATH)/$(2)/assessment.$(1).summary.txt
	cat $(TESTS_TMP)/catalog_tests.$(4).txt >> $(REPORT_PATH)/$(2)/assessment.$(1).summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/$(2)/assessment.$(1).summary.txt
	$(ECHO) "---- exceptions purposes ----" >> $(REPORT_PATH)/$(2)/assessment.$(1).summary.txt
	$(ECHO) "------------------------------" >> $(REPORT_PATH)/$(2)/assessment.$(1).summary.txt
	cat $(TESTS_TMP)/catalog_exceptions.$(4).txt >> $(REPORT_PATH)/$(2)/assessment.$(1).summary.txt
endef

# CONTEXT ALL REPORT ----

# -------------------------------------------------------------------------------------------
# MACRO: cawk_report_scope_all — Generate final assessment reports and timeline exports
# -------------------------------------------------------------------------------------------
# $(1) = report_dir, $(2) = catalog tmp tag (repo|run|$(audit)) — see cawk_catalog_precompute, which must run once before this macro
# -------------------------------------------------------------------------------------------
define cawk_report_scope_all
	if [ "$(strip $(DEADBEEF))" = "yes" ]; then $(ECHO) "cawk deadbeef filter performed ----"; $(EGREP) -v -f $(1)/assessment.all.deadbeef.idx $(1)/assessment.all.csv.swap > $(1)/assessment.all.csv || true; else $(ECHO) "cawk deadbeef filter skipped ----"; mv $(1)/assessment.all.csv.swap $(1)/assessment.all.csv || true; fi
	$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(1)/assessment.all.deadbeef.csv $(1)/assessment.all.exception.csv $(1)/assessment.all.csv > $(1)/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(1)/assessment.all.summary.txt
	$(ECHO) "---- tests purposes ----" >> $(1)/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(1)/assessment.all.summary.txt
	cat $(TESTS_TMP)/catalog_tests.$(2).txt >> $(1)/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(1)/assessment.all.summary.txt
	$(ECHO) "---- exceptions purposes ----" >> $(1)/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(1)/assessment.all.summary.txt
	cat $(TESTS_TMP)/catalog_exceptions.$(2).txt >> $(1)/assessment.all.summary.txt
	$(EGREP) "(high|medium|low);error" $(1)/assessment.all.csv > $(1)/assessment.all.security.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(1)/assessment.all.idx.swap $(1)/assessment.all.security.csv > $(1)/assessment.all.security.timeline.csv || true
	$(EGREP) ";psirt" $(1)/assessment.all.csv > $(1)/assessment.all.psirt.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(1)/assessment.all.idx.swap $(1)/assessment.all.psirt.csv > $(1)/assessment.all.psirt.timeline.csv || true
	$(EGREP) "(info;error|;warning)" $(1)/assessment.all.csv > $(1)/assessment.all.audit.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(1)/assessment.all.idx.swap $(1)/assessment.all.audit.csv > $(1)/assessment.all.audit.timeline.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(1)/assessment.all.idx.swap $(1)/assessment.all.csv > $(1)/assessment.all.timeline.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(1)/assessment.all.idx.swap $(1)/assessment.all.exception.csv > $(1)/assessment.all.exception.timeline.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(1)/assessment.all.idx.swap $(1)/assessment.all.deadbeef.csv > $(1)/assessment.all.deadbeef.timeline.csv || true
	sort -u $(1)/assessment.all.idx.swap > $(1)/assessment.all.idx
	if [ "$(strip $(TMP_ASSESSMENT_FILES))" = "yes" ]; then $(ECHO) "cawk removing temporary assessment files ----"; for s in $(SUPPLIER_SCOPE); do $(RM) -f $(1)/assessment.$$s.* || true; done; $(RM) -f $(1)/assessment.all.*.swap || true; else $(ECHO) "cawk keeping assessment files ----"; fi
	if [ "$(strip $(JSON))" = "yes" ]; then $(ECHO) "cawk json reporting performed ----"; $(TESTS_COMMON_PATH)/report_json.gawk $(1)/assessment.all.csv > $(1)/assessment.all.json || true; $(TESTS_COMMON_PATH)/report_json.gawk $(1)/assessment.all.security.csv > $(1)/assessment.all.security.json || true; $(TESTS_COMMON_PATH)/report_json.gawk $(1)/assessment.all.audit.csv > $(1)/assessment.all.audit.json || true; $(TESTS_COMMON_PATH)/report_json.gawk $(1)/assessment.all.psirt.csv > $(1)/assessment.all.psirt.json || true; $(TESTS_COMMON_PATH)/report_json.gawk $(1)/assessment.all.exception.csv > $(1)/assessment.all.exception.json || true; $(TESTS_COMMON_PATH)/report_sumjson.gawk $(1)/assessment.all.summary.txt > $(1)/assessment.all.summary.json || true; else $(ECHO) "cawk json reporting skipped ----"; fi
endef

# CATALOG TAIL (shared across suppliers) ----

# -------------------------------------------------------------------------------------------
# MACRO: cawk_catalog_precompute — Generate the per-supplier summary catalog tails once
# -------------------------------------------------------------------------------------------
# The "tests purposes" / "exceptions purposes" catalog tail is identical for every supplier of
# a scope. Computing it once into a tmp file (instead of one recursive $(GMAKE) per supplier)
# removes 2*N redundant sub-make invocations per assessment. Consumers cat the tmp files.
# $(1) = catalog target, $(2) = exceptions catalog target, $(3) = tmp context tag
# -------------------------------------------------------------------------------------------
define cawk_catalog_precompute
	$(GMAKE) $(1) > $(TESTS_TMP)/catalog_tests.$(3).txt 2>/dev/null || true
	$(GMAKE) $(2) > $(TESTS_TMP)/catalog_exceptions.$(3).txt 2>/dev/null || true
endef

