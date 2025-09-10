# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2025 by Cedric Llorens
# ------------------------------------------------------------

# ---------------
CAWK_RELEASE = v2.9.0

# ---------------

CONFS_PATH = confs
COMMON_PATH = common
BACKUP_PATH = backup
DATABASE_PATH = database
LOGS_PATH = logs
DATABASE_PATH_SH = $(DATABASE_PATH)/scripts
DATABASE_SH = $(wildcard $(DATABASE_PATH_SH)/*.script.sh)
REPORT_PATH = reports

TESTS_COMMON_PATH = common
TESTS_PATH = tests
TESTS_COMMON_TEMPLATE = $(wildcard $(TESTS_COMMON_PATH)/*.template)
TESTS_COMMON_SH = $(wildcard $(TESTS_COMMON_PATH)/*.script.sh)
TESTS_SYSTEM = system
TESTS_TMP = tmp

EXCEPTION_PATH = exceptions
EXCEPTION_M4 = $(wildcard $(EXCEPTION_PATH)/repo/*.m4) $(wildcard $(EXCEPTION_PATH)/run*/*.m4)

# ---------------

RUN_DIRS := $(shell find tests -name '*run_*' -type d 2>/dev/null | awk -F'run_' '{print $$NF}' | sort -u || echo "")

# ---------------

# Define all suppliers/platforms
SUPPLIER_SCOPE = cisco-ios cisco-xr juniper-junos huawei-vrp fortinet-fortios nokia-sros paloalto-panos cisco-viptela cisco-cedge cisco-xe packetfilter-fwcli checkpoint-fwcli iptables-fwcli 6wind-linux

SUPPLIER_M4_REPO_FILES = $(foreach supplier,$(SUPPLIER_SCOPE),$(TESTS_$(supplier)_REPO_M4:.gawk.m4=.gawk))
SUPPLIER_TEMPLATE_REPO_FILES = $(foreach supplier,$(SUPPLIER_SCOPE),$(TESTS_$(supplier)_REPO_TEMPLATE:.gawk.template=.gawk))

SUPPLIER_M4_RUN_FILES = $(foreach supplier,$(SUPPLIER_SCOPE),$(TESTS_$(supplier)_RUN_M4:.gawk.m4=.gawk))
SUPPLIER_TEMPLATE_RUN_FILES = $(foreach supplier,$(SUPPLIER_SCOPE),$(TESTS_$(supplier)_RUN_TEMPLATE:.gawk.template=.gawk))

# Generic template for all suppliers
define supplier_template
CONFIGURATION_$(1)_REPO_PATH = $$(CONFS_PATH)/repo/confs.$(1)
ifeq ($$(strip $$(audit)),)
	CONFIGURATION_$(1)_RUN_PATH = $$(CONFS_PATH)/run/confs.$(1)
else
	CONFIGURATION_$(1)_RUN_PATH = $$(CONFS_PATH)/run_$${audit}/confs.$(1)
endif

TESTS_$(1)_REPO_PATH = $$(TESTS_PATH)/repo/tests.$(1)
ifeq ($$(strip $$(audit)),)
	TESTS_$(1)_RUN_PATH = $$(TESTS_PATH)/run/tests.$(1)
else
	TESTS_$(1)_RUN_PATH = $$(TESTS_PATH)/run_$${audit}/tests.$(1)
endif

TESTS_$(1)_REPO_TEMPLATE = $$(wildcard $$(TESTS_$(1)_REPO_PATH)/*.template)
TESTS_$(1)_REPO_M4 = $$(wildcard $$(TESTS_$(1)_REPO_PATH)/*.m4)
TESTS_$(1)_RUN_TEMPLATE = $$(wildcard $$(TESTS_$(1)_RUN_PATH)/*.template)
TESTS_$(1)_RUN_M4 = $$(wildcard $$(TESTS_$(1)_RUN_PATH)/*.m4)
endef

# Generate rules for all suppliers
$(foreach supplier,$(SUPPLIER_SCOPE),$(eval $(call supplier_template,$(supplier))))

# --------------- cawk specific options
# test execution command
TEST_EXE = -exec ./$(test) {} +

# --------------- cawk parallel options
# enable parallel : yes/no
MAKE_PARALLEL ?= no
# number of files to process per target (all targets are processed in parallel)
MAKE_FILES_PER_TARGET ?= 100

# --------------- gmake parallel options
# gmake number of jobs
MAKE_J ?= 4
# gmake load average
MAKE_LOAD_AVG ?= 3

# --------------- gmake in silent mode
MAKEFLAGS += -s

# --------------- find specific parameters
FIND_CONF_SELECT = ! -type d

# --------------- json specific parameters
# if set to yes json reporting is activated
JSON ?= no

# --------------- deadbeef specific parameters
# if set to yes deadbeef support is activated
DEADBEEF = no
DEADBEEF_THRESHOLD_DAYS ?= 30