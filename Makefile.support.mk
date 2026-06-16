# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

# ===============================================================================
# VERSION & CORE SETTINGS
# ===============================================================================

CAWK_RELEASE = v3.6.0
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

RUN_DIRS := $(shell find tests -name '*run_*' -type d 2>/dev/null | awk -F'run_' '{print $$NF}' | sort -u || echo "")

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
MAKE_J ?= 4
MAKE_LOAD_AVG ?= 3

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
