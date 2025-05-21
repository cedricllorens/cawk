#!/bin/sh

# ---------------------------------------------------------------------
# cawk is subject to an MIT open-source license
# Please refer to the MIT license file for further information
#
# For %SED_VAR% like SED_GAWK_PATH, etc. please refer to
# the file support/tests.sed for further information
#
# This script detects configurations older than 30 days
# Such a configuration is called a deadbeef configuration
#
# Usage: deadbeef_cawk_conf.gawk conf_file
# ---------------------------------------------------------------------

# Define the threshold in days
THRESHOLD_DAYS=30

# Check if at least one argument is passed
[ $# -eq 0 ] && exit 1

# Iterate over each argument passed to the script
for file in "$@"; do
  # Check if the file exists
  [ ! -e "$file" ] && continue

  # If the file is a symbolic link, get the real target
  if [ -L "$file" ]; then
    real_file=$(readlink -f "$file")
  else
    real_file="$file"
  fi

  # Retrieve the modification date of the real file
  file_mod_date=$(stat -c %Y "$real_file")
  current_date=$(date +%s)

  # Calculate the difference in days
  if [ $(( (current_date - file_mod_date) / 86400 )) -ge $THRESHOLD_DAYS ]; then
    echo "$file;cawk_deadbeef_internal_test;configuration older than $THRESHOLD_DAYS days;;info;warning"
  fi
done



