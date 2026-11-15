# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

# Variables: none here, every variable of cawk is in support/Makefile.support.vars.mk

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
		m="failed to compile $< (empty file in $@)"; $(call cawk_phase_err,compile); \
		rm -f $@; \
		false; \
	elif [ -z "$(filter common/%,$<)" ]; then \
		if ! { IFS= read -r l < $@; case "$$l" in "#!"*) true;; *) false;; esac; }; then \
			m="failed to compile $< (missing shebang in $@)"; $(call cawk_phase_err,compile); \
			rm -f $@; \
			false; \
		fi; \
	fi
	chmod 750 $@

%.gawk: %.gawk.include common/test_generic_psirt.gawk.template support/tests.sed
	sed -e 's|CAWK_PSIRT_NAME|$(basename $@).gawk.include|g' -e 's|CAWK_PSIRT_TESTNAME|$(notdir $(basename $@))|g' -e 's|CAWK_PSIRT_OS|os|g' common/test_generic_psirt.gawk.template > $@.swap || true
	sed -f support/tests.sed $@.swap > $@ || true
	@if [ ! -s $@ ]; then \
		m="failed to compile $< (empty file in $@)"; $(call cawk_phase_err,compile); \
		rm -f $@ $@.swap; \
		false; \
	elif ! { IFS= read -r l < $@; case "$$l" in "#!"*) true;; *) false;; esac; }; then \
		m="failed to compile $< (missing shebang in $@)"; $(call cawk_phase_err,compile); \
		rm -f $@ $@.swap; \
		false; \
	fi
	rm -f $@.swap
	chmod 750 $@

# psirt test written with the macros of m4/cawk_psirt.m4 : the generated include (*.gawk.include.gen, not versioned) is read by the engine at run time
%.gawk: %.gawk.include.m4 common/test_generic_psirt.gawk.template support/tests.sed m4/cawk_psirt.m4
	m4 -I m4 $< > $(basename $@).gawk.include.m4out && sed -f support/tests.sed $(basename $@).gawk.include.m4out > $(basename $@).gawk.include.gen || rm -f $(basename $@).gawk.include.gen
	@rm -f $(basename $@).gawk.include.m4out
	@if [ ! -s $(basename $@).gawk.include.gen ]; then \
		m="failed to compile $< (empty file in $(basename $@).gawk.include.gen)"; $(call cawk_phase_err,compile); \
		rm -f $(basename $@).gawk.include.gen; \
		false; \
	fi
	sed -e 's|CAWK_PSIRT_NAME|$(basename $@).gawk.include.gen|g' -e 's|CAWK_PSIRT_TESTNAME|$(notdir $(basename $@))|g' -e 's|CAWK_PSIRT_OS|os|g' common/test_generic_psirt.gawk.template > $@.swap || true
	sed -f support/tests.sed $@.swap > $@ || true
	@if [ ! -s $@ ]; then \
		m="failed to compile $< (empty file in $@)"; $(call cawk_phase_err,compile); \
		rm -f $@ $@.swap; \
		false; \
	elif ! { IFS= read -r l < $@; case "$$l" in "#!"*) true;; *) false;; esac; }; then \
		m="failed to compile $< (missing shebang in $@)"; $(call cawk_phase_err,compile); \
		rm -f $@ $@.swap; \
		false; \
	fi
	rm -f $@.swap
	chmod 750 $@

%.gawk: %.gawk.m4
	m4 -I m4 $< > $@.m4out && sed -f support/tests.sed $@.m4out > $@ || rm -f $@
	@rm -f $@.m4out
	@if [ ! -s $@ ]; then \
		m="failed to compile $< (empty file in $@)"; $(call cawk_phase_err,compile); \
		rm -f $@; \
		false; \
	elif [ -z "$(filter common/%,$<)" ]; then \
		if ! { IFS= read -r l < $@; case "$$l" in "#!"*) true;; *) false;; esac; }; then \
			m="failed to compile $< (missing shebang in $@)"; $(call cawk_phase_err,compile); \
			rm -f $@; \
			false; \
		fi; \
	fi
	chmod 750 $@

%.script: %.script.sh
	cp $< $@
	chmod 750 $@

%: %.m4
	m4 -I m4 -I $(TESTS_COMMON_PATH)/censor $< > $@.tmp && sed '/^$$/d' $@.tmp > $@ && rm -f $@.tmp || { m="m4 failed for $<"; $(call cawk_phase_err,compile); rm -f $@ $@.tmp; false; }

checkdiff/scripts/%: checkdiff/scripts/%.sh
	cp $< $@ || true
	chmod 755 $@

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
	$(if $(filter yes,$(STANDARD_ONLY)),:,find $(4) -name '*.gawk' -type f 2>/dev/null | while read -r cawktest; do find $(2) $(FIND_CONF_SELECT) -exec "$$cawktest" {} + >> $(3) 2>>$(LOGS_PATH)/$(6)/test_exec.$(5).err; done) ;\
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
		$(GMAKE) --no-print-directory -f $(TESTS_TMP)/Makefile.$(4).$(1) -j $(MAKE_J) --load-average=$(MAKE_LOAD_AVG) all >> $(REPORT_PATH)/$(3)/assessment.$(1).csv.swap 2>$(LOGS_PATH)/$(3)/parallel_gmake.$(1).err || $(ECHO) "cawk error: parallel test execution failed for $(1) (see $(LOGS_PATH)/$(3)/parallel_gmake.$(1).err) ----" ;\
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
define cawk_filter_idx
	filter_what="$(if $(filter deadbeef,$(1)),stale configurations,$(if $(filter badformat,$(1)),first-level indentation violations,windows CRLF line endings))"; \
	if [ "$(strip $($(2)))" = "yes" ]; then filter_state="scan of $$filter_what ($(2)=yes: detected configurations are excluded"; else filter_state="scan of $$filter_what ($(2)=no: detected configurations are kept"; fi; \
	filter_state="$$filter_state$(if $(4),$(cawk_comma) $(4))) "; \
	if [ -s $(3)/assessment.all.$(1).idx ]; then \
		filter_count=$$(wc -l < $(3)/assessment.all.$(1).idx); \
		if [ "$(strip $($(2)))" = "yes" ]; then \
			$(ECHO) "cawk warning: $(1) $$filter_state-> $$filter_count configuration(s) detected and excluded from the audit, see $(3)/assessment.all.$(1).csv ----"; \
			cat $(3)/assessment.all.$(1).idx >> $(3)/assessment.all.filter.idx.swap; \
		else \
			$(ECHO) "cawk warning: $(1) $$filter_state-> $$filter_count configuration(s) detected and kept in the audit, see $(3)/assessment.all.$(1).csv ----"; \
		fi; \
	else \
		$(ECHO_INFO) "cawk $(1) $$filter_state-> none detected ----"; \
	fi;
endef

# -------------------------------------------------------------------------------------------
# MACRO: cawk_html_gen — Generate the standalone html report from assessment.all.csv (single recipe line)
# -------------------------------------------------------------------------------------------
# $(1) = report_dir, $(2) = audit key (repo|run|$(audit)), $(3) = file receiving the stderr of report_html.gawk
# -------------------------------------------------------------------------------------------
define cawk_html_gen
	base64 -w0 $(LOGO_HTML) > $(TESTS_TMP)/logo_html.b64 2>/dev/null || : ; $(TESTS_COMMON_PATH)/report_html.gawk -v HTML_SKELETON=$(TESTS_COMMON_PATH)/report_html.skeleton.html -v CONTEXT=$(2) -v AUDIT=$(2) -v CAWK_RELEASE=$(CAWK_RELEASE) -v LOGO_HTML=$(LOGO_HTML) -v LOGO_B64=$(TESTS_TMP)/logo_html.b64 $(if $(strip $(audit)),-v "DATA_SET_FILES=$$(ls $(DATA_SET_PATH)/run_$(strip $(audit))/data_set_$(strip $(audit))_*.txt 2>/dev/null | LC_ALL=C sort | tr '\n' ' ')" -v DATA_SET_KEEP=$(DATA_SET_KEEP)) $(DATABASE_CIS_INFO) $(1)/assessment.all$(CSV_EXT) > $(1)/assessment.all.summary.html 2>>$(3)
endef

# -------------------------------------------------------------------------------------------
# MACRO: cawk_secretscan_csv — SECRETSCAN=yes: censor the csv reports of a report dir, then remove the originals
# -------------------------------------------------------------------------------------------
# The originals are only removed when every file was censored. find batches the files itself (ARG_MAX).
# $(1) = report_dir, $(2) = log_dir (report_all.err)
# -------------------------------------------------------------------------------------------
define cawk_secretscan_csv
if [ "$(strip $(SECRETSCAN))" = "yes" ]; then \
		if CENSOR_MODE=censor CENSOR_CSV=yes CENSOR_LEVEL="$(strip $(CENSOR_LEVEL))" find $(1) -maxdepth 1 -type f -name '$(CAWK_SECRETSCAN_GLOB)' ! -name '*.censored.csv' -exec $(TESTS_COMMON_PATH)/censor.gawk {} + 2>>$(2)/report_all.err; then \
			find $(1) -maxdepth 1 -type f -name '$(CAWK_SECRETSCAN_GLOB)' ! -name '*.censored.csv' -delete; \
			$(ECHO_INFO) "cawk secretscan (SECRETSCAN=yes CENSOR_LEVEL=$(strip $(CENSOR_LEVEL))): censored csv reports written, $$(find $(1) -maxdepth 1 -type f -name 'assessment.*.censored.csv' | wc -l) csv report(s) censored, originals removed ----"; \
		else \
			$(ECHO) "cawk error: secretscan censoring failed, the original csv reports are kept (see $(2)/report_all.err) ----"; \
		fi; \
	else \
		$(ECHO_INFO) "cawk secretscan skipped (SECRETSCAN=no): csv reports are not censored ----"; \
	fi
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
	$(if $(strip $(audit)),$(if $(strip $(supplier)),$(ECHO_INFO) "cawk data_set skipped (supplier= set: partial counters; DATA_SET=$(strip $(DATA_SET)) DATA_SET_KEEP=$(strip $(DATA_SET_KEEP))) ----",$(if $(filter yes,$(strip $(DATA_SET))),$(ECHO_INFO) "cawk data_set (DATA_SET=$(strip $(DATA_SET)) DATA_SET_KEEP=$(strip $(DATA_SET_KEEP))): one file per date feeds the html section Evolution of the audit ----" && $(DATA_SET_SCRIPT) init "$(strip $(audit))" && $(DATA_SET_SCRIPT) append "$(strip $(audit))" "$(strip $(DATA_SET_KEEP))" "$(TODAY)",$(ECHO_INFO) "cawk data_set skipped (DATA_SET=no; DATA_SET=$(strip $(DATA_SET)) DATA_SET_KEEP=$(strip $(DATA_SET_KEEP))) ----")),$(ECHO_INFO) "cawk data_set skipped (no audit=: only a named audit has a data_set; DATA_SET=$(strip $(DATA_SET)) DATA_SET_KEEP=$(strip $(DATA_SET_KEEP))) ----")
	$(EGREP) "(high|medium|low);error" $(1)/assessment.all.csv > $(1)/assessment.all.security.csv || true
	$(EGREP) ";psirt" $(1)/assessment.all.csv > $(1)/assessment.all.psirt.csv || true
	$(EGREP) "(info;error|;warning)" $(1)/assessment.all.csv > $(1)/assessment.all.audit.csv || true
	$(call cawk_secretscan_csv,$(1),$(3))
	if [ "$(strip $(TIMELINE))" = "yes" ]; then $(ECHO_INFO) "cawk timeline done (TIMELINE=yes): first date of detection of each error ----"; else $(ECHO_INFO) "cawk timeline skipped (TIMELINE=no) ----"; fi
	if [ "$(strip $(TIMELINE))" = "yes" ]; then $(TESTS_COMMON_PATH)/report_timeline.gawk $(1)/assessment.all.idx.swap $(1)/assessment.all.security$(CSV_EXT) > $(1)/assessment.all.security.timeline$(CSV_EXT) 2>>$(3)/report_all.err || true; fi
	if [ "$(strip $(TIMELINE))" = "yes" ]; then $(TESTS_COMMON_PATH)/report_timeline.gawk $(1)/assessment.all.idx.swap $(1)/assessment.all.psirt$(CSV_EXT) > $(1)/assessment.all.psirt.timeline$(CSV_EXT) 2>>$(3)/report_all.err || true; fi
	if [ "$(strip $(TIMELINE))" = "yes" ]; then $(TESTS_COMMON_PATH)/report_timeline.gawk $(1)/assessment.all.idx.swap $(1)/assessment.all.audit$(CSV_EXT) > $(1)/assessment.all.audit.timeline$(CSV_EXT) 2>>$(3)/report_all.err || true; fi
	if [ "$(strip $(TIMELINE))" = "yes" ]; then $(TESTS_COMMON_PATH)/report_timeline.gawk $(1)/assessment.all.idx.swap $(1)/assessment.all$(CSV_EXT) > $(1)/assessment.all.timeline$(CSV_EXT) 2>>$(3)/report_all.err || true; fi
	if [ "$(strip $(TIMELINE))" = "yes" ]; then $(TESTS_COMMON_PATH)/report_timeline.gawk $(1)/assessment.all.idx.swap $(1)/assessment.all.exception$(CSV_EXT) > $(1)/assessment.all.exception.timeline$(CSV_EXT) 2>>$(3)/report_all.err || true; fi
	if [ "$(strip $(TIMELINE))" = "yes" ]; then $(TESTS_COMMON_PATH)/report_timeline.gawk $(1)/assessment.all.idx.swap $(1)/assessment.all.deadbeef$(CSV_EXT) > $(1)/assessment.all.deadbeef.timeline$(CSV_EXT) 2>>$(3)/report_all.err || true; fi
	if [ "$(strip $(TIMELINE))" = "yes" ]; then $(TESTS_COMMON_PATH)/report_timeline.gawk $(1)/assessment.all.idx.swap $(1)/assessment.all.badformat$(CSV_EXT) > $(1)/assessment.all.badformat.timeline$(CSV_EXT) 2>>$(3)/report_all.err || true; fi
	if [ "$(strip $(TIMELINE))" = "yes" ]; then $(TESTS_COMMON_PATH)/report_timeline.gawk $(1)/assessment.all.idx.swap $(1)/assessment.all.crlf$(CSV_EXT) > $(1)/assessment.all.crlf.timeline$(CSV_EXT) 2>>$(3)/report_all.err || true; fi
	sort -u $(1)/assessment.all.idx.swap > $(1)/assessment.all.idx
	if [ "$(strip $(TMP_ASSESSMENT_FILES))" = "yes" ]; then $(ECHO_INFO) "cawk cleanup done (TMP_ASSESSMENT_FILES=yes): per-supplier temporary files removed ----"; for s in $(SUPPLIER_SCOPE); do $(RM) -f $(1)/assessment.$$s.* || true; done; $(RM) -f $(1)/assessment.all.*.swap || true; else $(ECHO) "cawk cleanup skipped (TMP_ASSESSMENT_FILES=no): per-supplier temporary files kept ----"; fi
	if [ "$(strip $(JSON))" = "yes" ]; then $(ECHO_INFO) "cawk json done (JSON=yes): json reports written ----"; $(TESTS_COMMON_PATH)/report_json.gawk $(1)/assessment.all$(CSV_EXT) > $(1)/assessment.all$(JSON_EXT) 2>>$(3)/report_all.err || true; $(TESTS_COMMON_PATH)/report_json.gawk $(1)/assessment.all.security$(CSV_EXT) > $(1)/assessment.all.security$(JSON_EXT) 2>>$(3)/report_all.err || true; $(TESTS_COMMON_PATH)/report_json.gawk $(1)/assessment.all.audit$(CSV_EXT) > $(1)/assessment.all.audit$(JSON_EXT) 2>>$(3)/report_all.err || true; $(TESTS_COMMON_PATH)/report_json.gawk $(1)/assessment.all.psirt$(CSV_EXT) > $(1)/assessment.all.psirt$(JSON_EXT) 2>>$(3)/report_all.err || true; $(TESTS_COMMON_PATH)/report_json.gawk $(1)/assessment.all.exception$(CSV_EXT) > $(1)/assessment.all.exception$(JSON_EXT) 2>>$(3)/report_all.err || true; $(TESTS_COMMON_PATH)/report_sumjson.gawk $(1)/assessment.all.summary.txt > $(1)/assessment.all.summary.json 2>>$(3)/report_all.err || true; else $(ECHO_INFO) "cawk json skipped (JSON=no) ----"; fi
	if [ "$(strip $(HTML))" = "yes" ]; then $(ECHO_INFO) "cawk html done (HTML=yes): standalone report assessment.all.summary.html written ----"; $(call cawk_html_gen,$(1),$(2),$(3)/report_all.err) || true; else $(ECHO_INFO) "cawk html skipped (HTML=no) ----"; fi
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
	fi
endef

# -------------------------------------------------------------------------------------------
# MACRO: cawk_phase_err — error of a phase run before the logs of the context exist (integrity, compile, catalog_dir, exceptions_dir, tests_copy, deprecated)
# -------------------------------------------------------------------------------------------
# $(1) = phase name; the message is read from the shell variable m (set it first: m="..."; $(call cawk_phase_err,phase))
# shows `cawk error: <m> ----` and appends it to $(PHASE_ERR_DIR)/<phase>.err, because clean_logs_* of check_repo/check_run runs after those phases and would delete a log written in logs/<context>
# a phase of a run stopped by an error leaves its file in $(PHASE_ERR_DIR), reset by the next check_integrity
# -------------------------------------------------------------------------------------------
define cawk_phase_err
$(ECHO) "cawk error: $$m ----"; mkdir -p $(PHASE_ERR_DIR) && echo "$$m ----" >> $(PHASE_ERR_DIR)/$(1).err
endef

# -------------------------------------------------------------------------------------------
# MACRO: cawk_phase_log — moves the errors of the phases into the logs of the context, scanned with the other .err at the end of check_repo/check_run
# -------------------------------------------------------------------------------------------
# $(1) = logs directory of the context (logs/repo, logs/run, logs/run_<audit>), $(2) = name (repo, run, <audit>): $(PHASE_ERR_DIR)/<phase>.err becomes $(1)/<phase>.$(2).err
# -------------------------------------------------------------------------------------------
define cawk_phase_log
	@for f in $(PHASE_ERR_DIR)/*.err; do \
		[ -s "$$f" ] || continue; \
		p=$$(basename "$$f" .err); \
		mv "$$f" $(1)/$$p.$(2).err || { $(ECHO) "cawk error: cannot move $$f to $(1)/$$p.$(2).err ----"; exit 1; }; \
	done; rm -f $(PHASE_ERR_DIR)/*.err
endef

# -------------------------------------------------------------------------------------------
# MACRO: cawk_check_start — time stamp of the start of a check, read back by cawk_check_recap
# -------------------------------------------------------------------------------------------
# $(1) = context dir (repo, run or run_<audit>) ; the stamp is in tmp/, never in reports/ (checkdiff counts reports/*/*.csv)
# -------------------------------------------------------------------------------------------
define cawk_check_start
	@date +%s > $(TESTS_TMP)/check_start.$(1)
endef

# -------------------------------------------------------------------------------------------
# MACRO: cawk_check_recap — the one recap printed at the end of check_repo / check_run
# -------------------------------------------------------------------------------------------
# duration, suppliers, tests x confs actually executed (PSIRT_ONLY / STANDARD_ONLY honoured),
# results by status and by risk (one gawk pass over assessment.all.csv), execution errors and the report path.
# $(1) = path infix (REPO|RUN), $(2) = context dir (repo|run|run_<audit>), $(3) = audit name, empty out of an audit,
# $(4) = label (check_repo|check_run)
# -------------------------------------------------------------------------------------------
define cawk_check_recap
	@csv="$(REPORT_PATH)/$(2)/assessment.all$(CSV_EXT)"; \
	if [ ! -f "$$csv" ]; then $(ECHO) "cawk error: $(4) recap: $$csv not found ----"; exit 1; fi; \
	end=$$(date +%s); start=$$(cat $(TESTS_TMP)/check_start.$(2) 2>/dev/null || echo $$end); \
	nt=0; nc=0; nr=0; ns=0; \
	$(foreach scope,$(CHECK_SCOPE),if [ -d "$(CONFIGURATION_$(scope)_$(1)_PATH)" ]$(if $(strip $(3)), && { [ -d "$(TESTS_$(scope)_$(1)_PATH)" ] || [ -d "$(TESTS_$(scope)_$(1)_PSIRT_PATH)" ]; }); then \
		t=$$( { $(if $(filter yes,$(strip $(PSIRT_ONLY))),:;,find "$(TESTS_$(scope)_$(1)_PATH)" -type f -name '*.gawk' 2>/dev/null;) $(if $(filter yes,$(strip $(STANDARD_ONLY))),:;,find "$(TESTS_$(scope)_$(1)_PSIRT_PATH)" -type f -name '*.gawk' 2>/dev/null;) } | wc -l ); \
		c=$$(find "$(CONFIGURATION_$(scope)_$(1)_PATH)" -maxdepth 1 -type f 2>/dev/null | wc -l); \
		nt=$$((nt+t)); nc=$$((nc+c)); nr=$$((nr+t*c)); ns=$$((ns+1)); \
	fi; ) \
	errs=$$(find $(LOGS_PATH)/$(2) -maxdepth 1 -type f -name '*.err' -exec cat {} + 2>/dev/null | grep -vc '^[[:space:]]*$$' || true); \
	$(ECHO) "cawk recap $(4) ----"; \
	$(ECHO) "cawk duration      : $$((end-start)) s (MAKE_PARALLEL=$(strip $(MAKE_PARALLEL)))"; \
	$(ECHO) "cawk suppliers     : $$ns"; \
	$(ECHO) "cawk tests x confs : $$nt tests, $$nc confs, $$nr executions"; \
	LC_ALL=C gawk -F';' '{ s = $$NF; r = $$(NF-1); st[s]++; if (s != "pass") { n = split(r, a, "|"); for (i = 1; i <= n; i++) rk[a[i]]++ } } \
		END { printf "cawk results       : error %d | warning %d | psirt %d | pass %d\n", st["error"], st["warning"], st["psirt"], st["pass"]; \
		printf "cawk by risk       : high %d | medium %d | low %d | info %d\n", rk["high"], rk["medium"], rk["low"], rk["info"] }' "$$csv" || { $(ECHO) "cawk error: $(4) recap: gawk failed on $$csv ----"; exit 1; }; \
	$(ECHO) "cawk execution err : $$errs"; \
	$(ECHO) "cawk report        : $$csv"; \
	$(if $(filter yes,$(strip $(HTML))),if [ -f "$(REPORT_PATH)/$(2)/assessment.all.summary.html" ]; then $(ECHO) "cawk html report   : $(REPORT_PATH)/$(2)/assessment.all.summary.html (HTML=yes)"; fi;,:;) \
	$(if $(strip $(3)),if [ -d "$(DATA_SET_PATH)/run_$(3)" ]; then $(ECHO) "cawk data_set      : $$(ls $(DATA_SET_PATH)/run_$(3)/data_set_$(3)_*.txt 2>/dev/null | wc -l) date(s) in $(DATA_SET_PATH)/run_$(3) (DATA_SET=$(strip $(DATA_SET)) DATA_SET_KEEP=$(strip $(DATA_SET_KEEP)))"; fi;,:;)
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

