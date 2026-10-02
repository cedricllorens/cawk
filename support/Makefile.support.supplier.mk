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
ifneq ($(strip $(supplier)),)
ifeq ($(filter $(supplier),$(SUPPLIER_SCOPE)),)
	$(ECHO) "cawk error ($(supplier)) is not in the list of suppliers covered by cawk ($(SUPPLIER_SCOPE)) ----"
	exit 1
endif
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
