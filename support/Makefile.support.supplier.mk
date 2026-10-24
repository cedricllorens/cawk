# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

.PHONY: \
  check_supplier common supplier system

check_supplier:
# PSIRT was renamed PSIRT_ONLY: an old PSIRT=yes would otherwise be silently ignored and run all tests
ifneq ($(origin PSIRT),undefined)
	$(ECHO) "cawk error: PSIRT has been renamed PSIRT_ONLY (use PSIRT_ONLY=$(strip $(PSIRT))) ----"
	exit 1
endif
ifeq ($(filter $(strip $(PSIRT_ONLY)),yes no),)
	$(ECHO) "cawk error: PSIRT_ONLY=$(PSIRT_ONLY) is not yes or no ----"
	exit 1
endif
ifeq ($(filter $(strip $(STANDARD_ONLY)),yes no),)
	$(ECHO) "cawk error: STANDARD_ONLY=$(STANDARD_ONLY) is not yes or no ----"
	exit 1
endif
ifeq ($(strip $(PSIRT_ONLY))$(strip $(STANDARD_ONLY)),yesyes)
	$(ECHO) "cawk error: PSIRT_ONLY=yes and STANDARD_ONLY=yes exclude each other, no test would run ----"
	exit 1
endif
ifeq ($(filter $(strip $(CENSOR_LEVEL)),internal external),)
	$(ECHO) "cawk error: CENSOR_LEVEL=$(CENSOR_LEVEL) is not internal or external ----"
	exit 1
endif
ifeq ($(filter $(strip $(SECRETSCAN)),yes no),)
	$(ECHO) "cawk error: SECRETSCAN=$(SECRETSCAN) is not yes or no ----"
	exit 1
endif
# the value is never echoed: it would be expanded into the shell command line
	@bad=0; $(foreach v,MAKE_PARALLEL JSON HTML TIMELINE CATALOG_BUILD DEADBEEF BADFORMAT CRLF TMP_ASSESSMENT_FILES,$(if $(filter $(strip $($(v))),yes no),,echo "cawk error: $(v) is not yes or no ----"; bad=1;)) [ $$bad -eq 0 ] || exit 1
	@bad=0; $(foreach v,MAKE_J MAKE_LOAD_AVG DEADBEEF_THRESHOLD_DAYS,printf '%s' '$(strip $($(v)))' | grep -Eq '^[1-9][0-9]*$$' || { echo "cawk error: $(v) is not a number >= 1 ----"; bad=1; }; ) [ $$bad -eq 0 ] || exit 1
ifneq ($(strip $(supplier)),)
ifeq ($(filter $(supplier),$(SUPPLIER_SCOPE)),)
	$(ECHO) "cawk error ($(supplier)) is not in the list of suppliers covered by cawk ($(SUPPLIER_SCOPE)) ----"
	exit 1
endif
endif
ifneq ($(origin audit),undefined)
# audit is exported to the recipe environment: never expand it in the shell command line
	@printf '%s' "$$audit" | grep -Eq '^[A-Za-z0-9_-]+$$' || { echo "cawk error: audit must only contain letters, digits, '_' and '-' ----" ; exit 1 ; }
endif
	@if [ $(MAKE_FILES_PER_TARGET) -lt 1 ] || [ $(MAKE_FILES_PER_TARGET) -gt $(MAKE_FILES_PER_TARGET_MAX) ]; then \
		echo "cawk error: MAKE_FILES_PER_TARGET=$(MAKE_FILES_PER_TARGET) is out of the safe range [1,$(MAKE_FILES_PER_TARGET_MAX)] ----" ; \
		exit 1 ; \
	fi
	@if [ $(MAKE_FILES_PER_TARGET_PSIRT) -lt 1 ] || [ $(MAKE_FILES_PER_TARGET_PSIRT) -gt $(MAKE_FILES_PER_TARGET_MAX) ]; then \
		echo "cawk error: MAKE_FILES_PER_TARGET_PSIRT=$(MAKE_FILES_PER_TARGET_PSIRT) is out of the safe range [1,$(MAKE_FILES_PER_TARGET_MAX)] ----" ; \
		exit 1 ; \
	fi

supplier:
	$(ECHO) $(SUPPLIER_SCOPE)
	$(ECHO) "cawk supplier done ----"

system:
	$(TESTS_SYSTEM)/cawk_check_system


common:
	$(EGREP) purpose common/*.template

# the audit name goes into paths and sed/grep patterns of these targets
create_audit delete_audit database_sync_add database_sync_update database_sync_del database_postaudit_add database_postaudit_update database_postaudit_del database_email_add database_email_update database_email_del database_collect_add database_collect_update database_collect_del: check_supplier
