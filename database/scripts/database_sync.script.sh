#!/bin/sh

# ---------------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# this script allows to build, if needed, a sync inventory scope file
# for a specific audit=AUDIT_NAME
# 
# this script is launched when sync_audit audit=AUDIT_NAME target is 
# called
#
# this file may be used during the sync process to build a specific
# inventory scope thx to "egrep -f file" during the sync process
#
# the filename must not be changed
# usage: database_sync_script audit=AUDIT_NAME
# ---------------------------------------------------------------------

if [ -z "$1" ]; then
	echo "cawk error: audit=AUDIT_NAME is missing ----"
	exit 0
fi

# ---------------------------------------------------------------------
# if [ "$1" = "cawk" ]; then
#	echo "cawk error: audit must not be 'cawk' ----"
#	touch database/sync_scopes/$1_inventory_sync_scope.txt
#	exit 0
# fi

# ---------------------------------------------------------------------
# if [ "$1" = "cawk1" ]; then
#	echo "cawk error: audit must not be 'cawk' ----"
#	touch database/sync_scopes/$1_inventory_sync_scope.txt
#	exit 0
# fi

