# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

.PHONY: \
  check_supplier common supplier system

check_supplier:
ifneq ($(strip $(supplier)),)
ifeq ($(filter $(supplier),$(SUPPLIER_SCOPE)),)
	$(ECHO) "cawk error ($(supplier)) is not in the list of suppliers covered by cawk ($(SUPPLIER_SCOPE)) ----"
	exit 1
endif
endif

supplier:
	$(ECHO) $(SUPPLIER_SCOPE)
	$(ECHO) "cawk supplier done ----"

system:
	$(TESTS_SYSTEM)/cawk_check_system


common:
	$(EGREP) purpose common/*.template
