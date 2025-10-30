#!/bin/sh

# ---------------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# this script is launched when postaudit_audit audit=AUDIT_NAME target is 
# called. post audit tasks can be executed like create an helddesk ticket,
# etc.
#
# usage: database_postaudit.script audit=AUDIT_NAME
#
# THIS SCRIPT IS CENTRAL FOR ALL THE audit=AUDIT_NAME
# ---------------------------------------------------------------------

if [ -z "$1" ]; then
	echo "cawk error: audit=AUDIT_NAME is missing ----"
	exit 0
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

