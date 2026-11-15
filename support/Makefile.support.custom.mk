# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

# UPDATE_CUSTOM_SCRIPT: support/Makefile.support.vars.mk

.PHONY: \
  update_custom_run

# runs the script of the user (database/scripts/update_custom.script.sh) after a cawk update; never called by check*
update_custom_run:
	@[ "$(FORCE)" = "yes" ] || { $(ECHO) "cawk error: update_custom_run runs your own script, FORCE=yes is required (usage: $(GMAKE) update_custom_run FORCE=yes) ----"; exit 1; }
	@[ -z "$(strip $(audit))" ] || { $(ECHO) "cawk error: update_custom_run takes no audit=, it runs one global script ----"; exit 1; }
	@[ -f $(UPDATE_CUSTOM_SCRIPT).sh ] || { $(ECHO) "cawk error: $(UPDATE_CUSTOM_SCRIPT).sh does not exist, create it first ----"; exit 1; }
	@$(GMAKE) database_target_sh || { $(ECHO) "cawk error: database_target_sh failed, $(UPDATE_CUSTOM_SCRIPT) not built ----"; exit 1; }
	@[ -x $(UPDATE_CUSTOM_SCRIPT) ] || { $(ECHO) "cawk error: $(UPDATE_CUSTOM_SCRIPT) not built or not executable ----"; exit 1; }
	@mkdir -p $(LOGS_PATH)
	@$(ECHO) "cawk $(UPDATE_CUSTOM_SCRIPT) execution ----"
	@$(UPDATE_CUSTOM_SCRIPT) 2>$(LOGS_PATH)/update_custom.err || { $(ECHO) "cawk error: update_custom.script failed (see $(LOGS_PATH)/update_custom.err) ----"; exit 1; }
	@$(ECHO) "cawk update_custom_run done ----"
