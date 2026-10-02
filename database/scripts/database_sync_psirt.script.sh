#!/bin/sh

# ---------------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# this script allows to build, if needed, a psirt inventory scope file
# this script is launched when sync_psirt target is called
#
# this file may be used during the sync process to build specific
# psirt inventory scope file required when building advanced psirt 
# tests that must be located in the database/psirt_scopes directory
# with the exact following name psirt_os_inventory_scope.txt
#
# usage: database_sync_psirt.script
# ---------------------------------------------------------------------

# ---------------------------------------------------------------------
# check section
# ---------------------------------------------------------------------

CONFIG_FILE="database/include/scripts_config.sh"
if [ -f "$CONFIG_FILE" ]; then
    . "$CONFIG_FILE"
else
    echo "cawk error: configuration file not found: $CONFIG_FILE"
    exit 0
fi

# ---------------------------------------------------------------------
# to be updated 
# ---------------------------------------------------------------------
# echo "device_name os_version chassis cpu" > database/psirt_scopes/psirt_os_inventory_scope.txt



