# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

# ===============================================================================
# VERSION & CORE SETTINGS
# ===============================================================================

CAWK_RELEASE = v4.0.0
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
# TIMESTAMP (single value per gmake invocation)
# ===============================================================================

# Immediate assignment (:=): computed once when the Makefile is parsed, instead of
# once per $(shell date ...) occurrence. Recipes that embed the same date in several
# filenames (backup_run, archive_repo/run, sync rename targets) previously called
# `date` again for each occurrence, which could disagree if the recipe happened to
# straddle midnight (e.g. the tar file built with one date, gzip looking for another).
TODAY := $(shell date +%Y-%m-%d)

# ===============================================================================
# AUDIT DISCOVERY (dynamic run_audit directories)
# ===============================================================================

# Deferred (=) on purpose: this find must run only when a target actually reads
# RUN_DIRS (check_run_audit), not at parse time of every (recursive) make invocation.
RUN_DIRS = $(shell find -L tests -name '*run_*' -type d 2>/dev/null | awk -F'run_' '{print $$NF}' | sort -u || echo "")

# Shell-level equivalent of RUN_DIRS, for use as `$(RUN_DIRS_FIND) | while read -r audit; do ...; done`
# inside recipes instead of `for dir in $(RUN_DIRS)`: the number of run_<audit> directories is
# unbounded (grows with every create_audit over the tool's lifetime, unlike SUPPLIER_SCOPE), so
# inserting the whole list literally into a `for x in LIST` line risks MAX_ARG_STRLEN at scale
# (see CLAUDE.md Makefile Gotchas). This is plain recipe text (not $(shell ...)), re-run fresh
# by the shell on every use.
RUN_DIRS_FIND = find -L tests -name '*run_*' -type d 2>/dev/null | awk -F'run_' '{print $$NF}' | sort -u

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
	elif [ -z "$(filter common/%,$<)" ]; then \
		if ! { IFS= read -r l < $@; case "$$l" in "#!"*) true;; *) false;; esac; }; then \
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
	elif ! { IFS= read -r l < $@; case "$$l" in "#!"*) true;; *) false;; esac; }; then \
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
	elif [ -z "$(filter common/%,$<)" ]; then \
		if ! { IFS= read -r l < $@; case "$$l" in "#!"*) true;; *) false;; esac; }; then \
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
                 cisco-sdnios packetfilter-fwcli checkpoint-fwcli iptables-fwcli \
                 6wind-linux ekinops-oneos

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

# Safety ceiling for MAKE_FILES_PER_TARGET / MAKE_FILES_PER_TARGET_PSIRT: these values bound
# the number of config file paths embedded literally in one generated parallel-mode recipe
# line (common/gen_cawk_makefile*.gawk), which — unlike the sequential path's
# `find -exec {} +` — is not batched to respect the OS ARG_MAX. Enforced in check_supplier.
MAKE_FILES_PER_TARGET_MAX ?= 2000

# GNU Make parallel job options (used when MAKE_PARALLEL=yes)
# Default to the host CPU count (fallback 4/3 if nproc is unavailable).
MAKE_J ?= $(shell nproc 2>/dev/null || echo 4)
MAKE_LOAD_AVG ?= $(shell nproc 2>/dev/null || echo 3)

# Suppress verbose gmake output
MAKEFLAGS += -s -r

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

# Exclude badformat configurations (first-level indentation violations) from the final reports (yes/no)
BADFORMAT ?= no

# Exclude crlf configurations (windows format, results unreliable) from the final reports (yes/no, forced to yes by default)
CRLF ?= yes

# Auto-archive reports older than N days during cleanup
ARCHIVE_OLDER_DAYS ?= 120

# PSIRT_ONLY assessment mode (yes/no)
#   no  = run standard tests + PSIRT tests (default)
#   yes = run ONLY PSIRT tests (standard tests are skipped)
# Note: PSIRT tests are always compiled; this flag only selects which tests run at assessment time.
PSIRT_ONLY ?= no

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
	find $(CONFIGURATION_$(1)_$(2)_PATH) $(FIND_CONF_SELECT) -exec ./$(TESTS_COMMON_PATH)/deadbeef_cawk_conf.script $(DEADBEEF_THRESHOLD_DAYS) {} + > $(REPORT_PATH)/$(3)/assessment.$(1).deadbeef.csv 2>$(LOGS_PATH)/$(3)/deadbeef.$(1).err || $(ECHO) "cawk error: deadbeef scan failed for $(1) (see $(LOGS_PATH)/$(3)/deadbeef.$(1).err) ----" ;\
	cat $(REPORT_PATH)/$(3)/assessment.$(1).deadbeef.csv >> $(REPORT_PATH)/$(3)/assessment.all.deadbeef.csv ;\
	find $(CONFIGURATION_$(1)_$(2)_PATH) $(FIND_CONF_SELECT) > $(REPORT_PATH)/$(3)/assessment.$(1).idx 2>/dev/null || true ;\
	awk -v scope=$(1) '{print $$0,scope}' $(REPORT_PATH)/$(3)/assessment.$(1).idx >> $(REPORT_PATH)/$(3)/assessment.all.idx.swap ;
endef

# -------------------------------------------------------------------------------------------
# MACRO: cawk_deadbeef_scan_guarded — cawk_deadbeef_scan for a named audit, skipped when the supplier is absent
# -------------------------------------------------------------------------------------------
# Same skip condition as the RUN && PSIRT step (no confs, or neither standard nor PSIRT tests), so a
# PSIRT-only supplier still gets its deadbeef/idx lines. Single-line form (foreach-safe: ends with ';').
# $(1) = scope/supplier, $(2) = audit name
# -------------------------------------------------------------------------------------------
define cawk_deadbeef_scan_guarded
	if [ ! -d "$(CONFIGURATION_$(1)_RUN_PATH)" ] || ([ ! -d "$(TESTS_$(1)_RUN_PATH)" ] && [ ! -d "$(TESTS_$(1)_RUN_PSIRT_PATH)" ]); then \
		touch $(REPORT_PATH)/run_$(2)/assessment.all.deadbeef.csv $(REPORT_PATH)/run_$(2)/assessment.all.idx.swap; \
	else \
		$(call cawk_deadbeef_scan,$(1),RUN,run_$(2)) \
	fi;
endef

# BADFORMAT ----

# -------------------------------------------------------------------------------------------
# MACRO: cawk_badformat_scan — Per-device badformat scan (first-level indentation) for one scope/supplier
# -------------------------------------------------------------------------------------------
# Single-line form (foreach-safe: expansion ends with ';'). Unlike cawk_deadbeef_scan it does not
# append to 'assessment.all.idx.swap' (already filled by the deadbeef scan): a second append would
# double the device count reported by report_timeline.gawk.
# $(1) = scope/supplier, $(2) = path infix (REPO|RUN), $(3) = report dir (repo|run|run_$${audit})
# -------------------------------------------------------------------------------------------
define cawk_badformat_scan
	find $(CONFIGURATION_$(1)_$(2)_PATH) $(FIND_CONF_SELECT) -exec ./$(TESTS_COMMON_PATH)/badformat_cawk_conf.gawk {} + > $(REPORT_PATH)/$(3)/assessment.$(1).badformat.csv 2>$(LOGS_PATH)/$(3)/badformat.$(1).err || $(ECHO) "cawk error: badformat scan failed for $(1) (see $(LOGS_PATH)/$(3)/badformat.$(1).err) ----" ;\
	cat $(REPORT_PATH)/$(3)/assessment.$(1).badformat.csv >> $(REPORT_PATH)/$(3)/assessment.all.badformat.csv ;
endef

# -------------------------------------------------------------------------------------------
# MACRO: cawk_badformat_scan_guarded — cawk_badformat_scan for a named audit, skipped when the supplier is absent
# -------------------------------------------------------------------------------------------
# Same skip condition as cawk_deadbeef_scan_guarded. Single-line form (foreach-safe: ends with ';').
# $(1) = scope/supplier, $(2) = audit name
# -------------------------------------------------------------------------------------------
define cawk_badformat_scan_guarded
	if [ ! -d "$(CONFIGURATION_$(1)_RUN_PATH)" ] || ([ ! -d "$(TESTS_$(1)_RUN_PATH)" ] && [ ! -d "$(TESTS_$(1)_RUN_PSIRT_PATH)" ]); then \
		touch $(REPORT_PATH)/run_$(2)/assessment.all.badformat.csv; \
	else \
		$(call cawk_badformat_scan,$(1),RUN,run_$(2)) \
	fi;
endef

# CRLF ----

# -------------------------------------------------------------------------------------------
# MACRO: cawk_crlf_scan — Per-device windows format (CRLF) scan for one scope/supplier
# -------------------------------------------------------------------------------------------
# Single-line form (foreach-safe: expansion ends with ';'). Like cawk_badformat_scan it does not
# append to 'assessment.all.idx.swap' (already filled by the deadbeef scan).
# $(1) = scope/supplier, $(2) = path infix (REPO|RUN), $(3) = report dir (repo|run|run_$${audit})
# -------------------------------------------------------------------------------------------
define cawk_crlf_scan
	find $(CONFIGURATION_$(1)_$(2)_PATH) $(FIND_CONF_SELECT) -exec ./$(TESTS_COMMON_PATH)/crlf_cawk_conf.gawk {} + > $(REPORT_PATH)/$(3)/assessment.$(1).crlf.csv 2>$(LOGS_PATH)/$(3)/crlf.$(1).err || $(ECHO) "cawk error: crlf scan failed for $(1) (see $(LOGS_PATH)/$(3)/crlf.$(1).err) ----" ;\
	cat $(REPORT_PATH)/$(3)/assessment.$(1).crlf.csv >> $(REPORT_PATH)/$(3)/assessment.all.crlf.csv ;
endef

# -------------------------------------------------------------------------------------------
# MACRO: cawk_crlf_scan_guarded — cawk_crlf_scan for a named audit, skipped when the supplier is absent
# -------------------------------------------------------------------------------------------
# Same skip condition as cawk_deadbeef_scan_guarded. Single-line form (foreach-safe: ends with ';').
# $(1) = scope/supplier, $(2) = audit name
# -------------------------------------------------------------------------------------------
define cawk_crlf_scan_guarded
	if [ ! -d "$(CONFIGURATION_$(1)_RUN_PATH)" ] || ([ ! -d "$(TESTS_$(1)_RUN_PATH)" ] && [ ! -d "$(TESTS_$(1)_RUN_PSIRT_PATH)" ]); then \
		touch $(REPORT_PATH)/run_$(2)/assessment.all.crlf.csv; \
	else \
		$(call cawk_crlf_scan,$(1),RUN,run_$(2)) \
	fi;
endef

# RUN && PSIRT ----

# -------------------------------------------------------------------------------------------
# MACRO: cawk_test_execution — Execute tests and collect assessment results
# -------------------------------------------------------------------------------------------
# $(1) = tests_path_std, $(2) = config_path, $(3) = output_csv, $(4) = tests_path_psirt, $(5) = scope/supplier (for log naming), $(6) = log dir (repo|run|run_${audit})
# -------------------------------------------------------------------------------------------
define cawk_test_execution
	> $(LOGS_PATH)/$(6)/test_exec.$(5).err ;\
	$(if $(filter no,$(PSIRT_ONLY)),\
		find $(1) -name '*.gawk' -type f 2>/dev/null | while read -r cawktest; do find $(2) $(FIND_CONF_SELECT) -exec "$$cawktest" {} + >> $(3) 2>>$(LOGS_PATH)/$(6)/test_exec.$(5).err; done ;\
		,\
		touch $(3) ;\
	) \
	find $(4) -name '*.gawk' -type f 2>/dev/null | while read -r cawktest; do find $(2) $(FIND_CONF_SELECT) -exec "$$cawktest" {} + >> $(3) 2>>$(LOGS_PATH)/$(6)/test_exec.$(5).err; done ;\
	if [ -s $(LOGS_PATH)/$(6)/test_exec.$(5).err ]; then $(ECHO) "cawk error: test execution failed for $(5) (see $(LOGS_PATH)/$(6)/test_exec.$(5).err) ----"; fi
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
	$(if $(filter no,$(PSIRT_ONLY)),\
		find $(TESTS_$(1)_$(2)_PATH) -type f -name '*.gawk' > $(TESTS_TMP)/conf_list_tests.$(4).$(1) 2>/dev/null || true ;\
		$(TESTS_COMMON_PATH)/gen_cawk_makefile.gawk $(TESTS_TMP)/conf_list_files.$(4).$(1) $(MAKE_FILES_PER_TARGET) $(TESTS_TMP)/conf_list_tests.$(4).$(1) > $(TESTS_TMP)/Makefile.$(4).$(1) 2>$(LOGS_PATH)/$(3)/gen_makefile.$(1).err || $(ECHO) "cawk error: parallel makefile generation failed for $(1) (see $(LOGS_PATH)/$(3)/gen_makefile.$(1).err) ----" ;\
		$(GMAKE) -f $(TESTS_TMP)/Makefile.$(4).$(1) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all >> $(REPORT_PATH)/$(3)/assessment.$(1).csv.swap 2>$(LOGS_PATH)/$(3)/parallel_gmake.$(1).err || $(ECHO) "cawk error: parallel test execution failed for $(1) (see $(LOGS_PATH)/$(3)/parallel_gmake.$(1).err) ----" ;\
		,\
		touch $(REPORT_PATH)/$(3)/assessment.$(1).csv.swap ;\
	)
endef

# -------------------------------------------------------------------------------------------
# MACRO: cawk_exceptions_compile — Compile every *.m4 exception file of a directory into its exceptions.<supplier>
# -------------------------------------------------------------------------------------------
# Avoids piping m4 straight into sed: a fork/pipe refused by the kernel (e.g. EMFILE/ENFILE under
# file-descriptor exhaustion) would then leave nothing in the log (the redirect is set up before m4
# even starts) and no non-zero exit for the recipe to see, so exceptions_run could report "done"
# without ever recompiling. Each stage's own exit status ($$?) is checked explicitly and logged,
# and the compiled file is only replaced (atomic mv from a $$$$-suffixed temp) once both succeeded.
# $(1) = exceptions source dir (exceptions/repo, exceptions/run, exceptions/run_$${audit}), $(2) = error log file
# -------------------------------------------------------------------------------------------
define cawk_exceptions_compile
	find $(1) -maxdepth 1 -type f -name "*.m4" | while read -r exc; do \
		out="$${exc%.m4}"; \
		tmp_m4="$$out.m4out.$$$$"; \
		tmp_out="$$out.tmp.$$$$"; \
		m4 -I m4 "$$exc" > "$$tmp_m4" 2>>$(2); \
		m4_rc=$$?; \
		if [ "$$m4_rc" -ne 0 ]; then \
			$(ECHO) "cawk error: m4 exit $$m4_rc compiling $$exc ----" >> $(2); \
		else \
			sed '/^$$/d' "$$tmp_m4" > "$$tmp_out"; \
			sed_rc=$$?; \
			if [ "$$sed_rc" -ne 0 ]; then \
				$(ECHO) "cawk error: sed exit $$sed_rc compiling $$exc ----" >> $(2); \
			else \
				mv -f "$$tmp_out" "$$out"; \
				chmod 650 "$$out"; \
			fi; \
		fi; \
		rm -f "$$tmp_m4" "$$tmp_out"; \
	done
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
	$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(REPORT_PATH)/$(2)/assessment.all.deadbeef.csv $(REPORT_PATH)/$(2)/assessment.all.badformat.csv $(REPORT_PATH)/$(2)/assessment.all.crlf.csv $(REPORT_PATH)/$(2)/assessment.$(1).exceptions.csv $(REPORT_PATH)/$(2)/assessment.$(1).csv > $(REPORT_PATH)/$(2)/assessment.$(1).summary.txt 2>$(LOGS_PATH)/$(2)/report_local.$(1).err
	@if [ -s $(LOGS_PATH)/$(2)/report_local.$(1).err ]; then $(ECHO) "cawk error: report.gawk failed for $(1) (see $(LOGS_PATH)/$(2)/report_local.$(1).err) ----"; fi
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
# MACRO: cawk_filter_idx — Report one filter (deadbeef|badformat|crlf) and queue its devices for exclusion
# -------------------------------------------------------------------------------------------
# Detected devices are always reported as a cawk error, excluded only when the filter option is yes.
# Single-line form (ends with ';').
# $(1) = filter name (deadbeef|badformat|crlf), $(2) = option variable name (DEADBEEF|BADFORMAT|CRLF), $(3) = report_dir
# $(4) = optional detection threshold, shown apart from the option since detection always runs (e.g. DEADBEEF_THRESHOLD_DAYS=30)
# -------------------------------------------------------------------------------------------
cawk_comma := ,
define cawk_filter_idx
	if [ "$(strip $($(2)))" = "yes" ]; then filter_state="activated ($(2)=yes)"; else filter_state="not activated ($(2)=no)"; fi; \
	filter_state="$$filter_state$(if $(4),$(cawk_comma) $(1) threshold ($(4)))"; \
	if [ -s $(3)/assessment.all.$(1).idx ]; then \
		filter_count=$$(wc -l < $(3)/assessment.all.$(1).idx); \
		if [ "$(strip $($(2)))" = "yes" ]; then \
			$(ECHO) "cawk error: $(1) filter $$filter_state, $$filter_count $(1) configuration(s) detected and excluded from the assessment (see $(3)/assessment.all.$(1).csv) ----"; \
			cat $(3)/assessment.all.$(1).idx >> $(3)/assessment.all.filter.idx.swap; \
		else \
			$(ECHO) "cawk error: $(1) filter $$filter_state, $$filter_count $(1) configuration(s) detected and kept in the assessment (see $(3)/assessment.all.$(1).csv) ----"; \
		fi; \
	else \
		$(ECHO) "cawk $(1) filter $$filter_state, no $(1) configuration detected ----"; \
	fi;
endef

# -------------------------------------------------------------------------------------------
# MACRO: cawk_report_scope_all — Generate final assessment reports and timeline exports
# -------------------------------------------------------------------------------------------
# $(1) = report_dir, $(2) = catalog tmp tag (repo|run|$(audit)) — see cawk_catalog_precompute, which must run once before this macro
# $(3) = log_dir (repo|run|run_${audit}) — where report_all.err is written; stderr of every
# report.gawk/report_timeline.gawk/report_json.gawk/report_sumjson.gawk call below is appended
# to it, so a failure surfaces in cawk_check_errors_scan's end-of-run summary instead of only
# flashing on stdout during the run.
# -------------------------------------------------------------------------------------------
define cawk_report_scope_all
	: > $(3)/report_all.err
	> $(1)/assessment.all.filter.idx.swap; \
	$(call cawk_filter_idx,deadbeef,DEADBEEF,$(1),DEADBEEF_THRESHOLD_DAYS=$(DEADBEEF_THRESHOLD_DAYS)) \
	$(call cawk_filter_idx,badformat,BADFORMAT,$(1)) \
	$(call cawk_filter_idx,crlf,CRLF,$(1)) \
	if [ -s $(1)/assessment.all.filter.idx.swap ]; then $(EGREP) -v -f $(1)/assessment.all.filter.idx.swap $(1)/assessment.all.csv.swap > $(1)/assessment.all.csv || true; else mv $(1)/assessment.all.csv.swap $(1)/assessment.all.csv || true; fi
	$(TESTS_COMMON_PATH)/report.gawk $(DATABASE_CIS_INFO) $(1)/assessment.all.deadbeef.csv $(1)/assessment.all.badformat.csv $(1)/assessment.all.crlf.csv $(1)/assessment.all.exception.csv $(1)/assessment.all.csv > $(1)/assessment.all.summary.txt 2>>$(3)/report_all.err
	$(ECHO) "------------------------" >> $(1)/assessment.all.summary.txt
	$(ECHO) "---- tests purposes ----" >> $(1)/assessment.all.summary.txt
	$(ECHO) "------------------------" >> $(1)/assessment.all.summary.txt
	cat $(TESTS_TMP)/catalog_tests.$(2).txt >> $(1)/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(1)/assessment.all.summary.txt
	$(ECHO) "---- exceptions purposes ----" >> $(1)/assessment.all.summary.txt
	$(ECHO) "------------------------------" >> $(1)/assessment.all.summary.txt
	cat $(TESTS_TMP)/catalog_exceptions.$(2).txt >> $(1)/assessment.all.summary.txt
	$(EGREP) "(high|medium|low);error" $(1)/assessment.all.csv > $(1)/assessment.all.security.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(1)/assessment.all.idx.swap $(1)/assessment.all.security.csv > $(1)/assessment.all.security.timeline.csv 2>>$(3)/report_all.err || true
	$(EGREP) ";psirt" $(1)/assessment.all.csv > $(1)/assessment.all.psirt.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(1)/assessment.all.idx.swap $(1)/assessment.all.psirt.csv > $(1)/assessment.all.psirt.timeline.csv 2>>$(3)/report_all.err || true
	$(EGREP) "(info;error|;warning)" $(1)/assessment.all.csv > $(1)/assessment.all.audit.csv || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(1)/assessment.all.idx.swap $(1)/assessment.all.audit.csv > $(1)/assessment.all.audit.timeline.csv 2>>$(3)/report_all.err || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(1)/assessment.all.idx.swap $(1)/assessment.all.csv > $(1)/assessment.all.timeline.csv 2>>$(3)/report_all.err || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(1)/assessment.all.idx.swap $(1)/assessment.all.exception.csv > $(1)/assessment.all.exception.timeline.csv 2>>$(3)/report_all.err || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(1)/assessment.all.idx.swap $(1)/assessment.all.deadbeef.csv > $(1)/assessment.all.deadbeef.timeline.csv 2>>$(3)/report_all.err || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(1)/assessment.all.idx.swap $(1)/assessment.all.badformat.csv > $(1)/assessment.all.badformat.timeline.csv 2>>$(3)/report_all.err || true
	$(TESTS_COMMON_PATH)/report_timeline.gawk $(1)/assessment.all.idx.swap $(1)/assessment.all.crlf.csv > $(1)/assessment.all.crlf.timeline.csv 2>>$(3)/report_all.err || true
	sort -u $(1)/assessment.all.idx.swap > $(1)/assessment.all.idx
	if [ "$(strip $(TMP_ASSESSMENT_FILES))" = "yes" ]; then $(ECHO) "cawk removing temporary assessment files (TMP_ASSESSMENT_FILES=yes) ----"; for s in $(SUPPLIER_SCOPE); do $(RM) -f $(1)/assessment.$$s.* || true; done; $(RM) -f $(1)/assessment.all.*.swap || true; else $(ECHO) "cawk keeping assessment files (TMP_ASSESSMENT_FILES=no) ----"; fi
	if [ "$(strip $(JSON))" = "yes" ]; then $(ECHO) "cawk json reporting performed (JSON=yes) ----"; $(TESTS_COMMON_PATH)/report_json.gawk $(1)/assessment.all.csv > $(1)/assessment.all.json 2>>$(3)/report_all.err || true; $(TESTS_COMMON_PATH)/report_json.gawk $(1)/assessment.all.security.csv > $(1)/assessment.all.security.json 2>>$(3)/report_all.err || true; $(TESTS_COMMON_PATH)/report_json.gawk $(1)/assessment.all.audit.csv > $(1)/assessment.all.audit.json 2>>$(3)/report_all.err || true; $(TESTS_COMMON_PATH)/report_json.gawk $(1)/assessment.all.psirt.csv > $(1)/assessment.all.psirt.json 2>>$(3)/report_all.err || true; $(TESTS_COMMON_PATH)/report_json.gawk $(1)/assessment.all.exception.csv > $(1)/assessment.all.exception.json 2>>$(3)/report_all.err || true; $(TESTS_COMMON_PATH)/report_sumjson.gawk $(1)/assessment.all.summary.txt > $(1)/assessment.all.summary.json 2>>$(3)/report_all.err || true; else $(ECHO) "cawk json reporting skipped (JSON=no) ----"; fi
	@if [ -s $(3)/report_all.err ]; then $(ECHO) "cawk error: final report generation failed (see $(3)/report_all.err) ----"; fi
endef

# -------------------------------------------------------------------------------------------
# MACRO: cawk_check_errors_scan — Scan every *.err log of the current audit context and print each non-blank line
# -------------------------------------------------------------------------------------------
# Called at the very end of check_repo/check_run, once per invocation, on the exact log dir of
# the context that just ran: logs/repo for check_repo, logs/run or logs/run_$${audit} for
# check_run depending on whether audit= was given — never a mix of several contexts at once.
# $(1) = log dir of the CURRENT context only (logs/repo, logs/run, or logs/run_$${audit})
# -------------------------------------------------------------------------------------------
define cawk_check_errors_scan
	@errlines="$$(find $(1) -maxdepth 1 -type f -name '*.err' -exec cat {} + 2>/dev/null | grep -v '^[[:space:]]*$$')"; \
	if [ -n "$$errlines" ]; then \
		echo "$$errlines" | while IFS= read -r line; do $(ECHO) "cawk error: $$line"; done; \
	else \
		$(ECHO) "cawk no execution errors found ----"; \
	fi
endef

# CATALOG TAIL (shared across suppliers) ----

# -------------------------------------------------------------------------------------------
# MACRO: cawk_catalog_precompute — Generate the per-supplier summary catalog tails once
# -------------------------------------------------------------------------------------------
# The "tests purposes" / "exceptions purposes" catalog tail is identical for every supplier of
# a scope. Computing it once into a tmp file (instead of one recursive $(GMAKE) per supplier)
# removes 2*N redundant sub-make invocations per assessment. Consumers cat the tmp files.
# $(1) = catalog target, $(2) = exceptions catalog target, $(3) = tmp context tag, $(4) = log dir (repo|run|run_${audit})
# -------------------------------------------------------------------------------------------
define cawk_catalog_precompute
	$(GMAKE) $(1) > $(TESTS_TMP)/catalog_tests.$(3).txt 2>$(LOGS_PATH)/$(4)/catalog_precompute.$(3).err || $(ECHO) "cawk error: catalog precompute failed for $(3) (see $(LOGS_PATH)/$(4)/catalog_precompute.$(3).err) ----"
	$(GMAKE) $(2) > $(TESTS_TMP)/catalog_exceptions.$(3).txt 2>>$(LOGS_PATH)/$(4)/catalog_precompute.$(3).err || $(ECHO) "cawk error: catalog exceptions precompute failed for $(3) (see $(LOGS_PATH)/$(4)/catalog_precompute.$(3).err) ----"
endef

