#!/bin/sh
#==============================================================================
# File        : update_custom.script.sh
# Purpose     : your own changes after a cawk update, run by: gmake update_custom_run FORCE=yes
# Note        : user side (database/): saved by backup_run, never overwritten by a cawk update
#               run from the cawk root directory, no argument, global (no audit=)
#               fail explicitly: echo "cawk error: <message> ----"; exit 1
#               errors (stderr) are written in logs/update_custom.err
#==============================================================================

# add your own commands here

exit 0
