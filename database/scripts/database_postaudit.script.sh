#!/bin/sh

# ---------------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# this script is launched when postaudit_audit audit=AUDIT_NAME target is 
# called. post audit tasks can be executed like create an helddesk ticket,
# etc.
#
# usage: database_postaudit.script <AUDIT_NAME>
# ---------------------------------------------------------------------

# ---------------------------------------------------------------------
# check section
# ---------------------------------------------------------------------
if [ -z "$1" ]; then
	echo "cawk error: audit=AUDIT_NAME is missing ----"
	exit 1
fi

CONFIG_FILE="database/include/scripts_config.sh"
if [ -f "$CONFIG_FILE" ]; then
    . "$CONFIG_FILE"
else
    echo "cawk error: configuration file not found: $CONFIG_FILE"
    exit 1
fi

# ---------------------------------------------------------------------
# to be updated
# ---------------------------------------------------------------------
# if [ "$1" = "cawk" ]; then
#	tasks to be done
#	exit 0
# fi

# ---------------------------------------------------------------------
# to be updated
# ---------------------------------------------------------------------
# if [ "$1" = "cawk1" ]; then
#	tasks to be done
#	exit 0
# fi

