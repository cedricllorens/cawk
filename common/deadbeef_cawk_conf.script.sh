#!/bin/sh

# ---------------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# for %SED_VAR% change like SED_GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# this script allows to detect configurations older than 30 days
# such conf is called a deadbeef configuration
#
# usage: deadbeef_cawk_conf.gawk conf_file
# ---------------------------------------------------------------------

[ -z "$1" ] && exit 1
file_mod_date=$(stat -c %Y "$1")
current_date=$(date +%s)
[ $(( (current_date - file_mod_date) / 86400 )) -ge 30 ] && echo "$1"
