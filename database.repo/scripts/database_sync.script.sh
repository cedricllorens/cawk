#!/bin/sh

# ---------------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# this script allows to build, if needed, a sync inventory scope file
# for a specific audit=AUDIT_NAME
# 
# this script is launched when sync_run audit=AUDIT_NAME target is 
# called
#
# you may set in the database/sync_scopes directory a full device
# path as only the device name will taken into consideration
#
# usage: database_sync.script audit=AUDIT_NAME
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
#	touch database/sync_scopes/$1_inventory_sync_scope.txt
#	exit 0
# fi

# ---------------------------------------------------------------------
# to be updated 
# ---------------------------------------------------------------------
# if [ "$1" = "cawk1" ]; then
#	touch database/sync_scopes/$1_inventory_sync_scope.txt
#	exit 0
# fi

