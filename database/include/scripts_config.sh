#!/bin/sh
#==============================================================================
# File        : scripts_config.sh
# Purpose     : Global configuration variables for shell scripts
# Author      : cllorens
# Note        : Include-only file; source this file in shell scripts via:
#               . "${SCRIPT_DIR}/scripts_config.sh"
#               Must NOT be executed directly
#==============================================================================

#==============================================================================
# Core Directory Paths
# These define the main structural paths relative to repository root
#==============================================================================

# Configuration path (contains vendor-specific configs for assessment)
CONFS_PATH="confs"

# Common library path (shared AWK includes and templates)
COMMON_PATH="common"

# Backup archive path (stores backed up files and snapshots)
BACKUP_PATH="backup"

# Database path (flat-file DBs: db_sync.txt, db_email.txt, db_postaudit.txt, etc.)
DATABASE_PATH="database"

# Logs path (assessment and operation logs)
LOGS_PATH="logs"

# Report path (generated assessment reports and archives)
REPORT_PATH="reports"

# Exception rules path (audit exceptions applied during reporting)
EXCEPTION_PATH="exceptions"

#==============================================================================
# Database-Specific Paths
#==============================================================================

# Database info file (test catalog: metadata for all compiled tests)
DATABASE_CIS_INFO="${DATABASE_PATH}/db_info.txt"

# Database scripts path (contains *.script.sh files for database operations)
DATABASE_SH_PATH="${DATABASE_PATH}/scripts"

# Optional configuration collectors path (contains *.collector.sh files, run by gmake collect_run)
COLLECTORS_PATH="${DATABASE_PATH}/collectors"

# Database scripts glob pattern
# Usage: for script in ${DATABASE_SH_PATTERN}; do ... done
DATABASE_SH_PATTERN="${DATABASE_SH_PATH}/*.script.sh"

#==============================================================================
# Tests Directory Paths
#==============================================================================

# Test templates path (source directory for test templates before compilation)
TESTS_PATH="tests"

# Test common path (shared test libraries and includes)
TESTS_COMMON_PATH="common"

# Test common template glob pattern
# Usage: for tmpl in ${TESTS_COMMON_TEMPLATE_PATTERN}; do ... done
TESTS_COMMON_TEMPLATE_PATTERN="${TESTS_COMMON_PATH}/*.template"

# Test common scripts glob pattern
# Usage: for script in ${TESTS_COMMON_SH_PATTERN}; do ... done
TESTS_COMMON_SH_PATTERN="${TESTS_COMMON_PATH}/*.script.sh"

# Test system path (system-specific test configurations)
TESTS_SYSTEM="system"

# Test temporary path (temporary files during test compilation and execution)
TESTS_TMP="tmp"

#==============================================================================
# Helper Functions for Glob Expansion
# Use these to get actual file lists in shell scripts (POSIX-compatible)
#==============================================================================

# Expand database scripts pattern and return list
# Usage: scripts=$(get_database_scripts)
get_database_scripts() {
	find "${DATABASE_SH_PATH}" -maxdepth 1 -name "*.script.sh" -type f 2>/dev/null | sort
}

# Expand test common templates pattern and return list
# Usage: templates=$(get_test_common_templates)
get_test_common_templates() {
	find "${TESTS_COMMON_PATH}" -maxdepth 1 -name "*.template" -type f 2>/dev/null | sort
}

# Expand test common scripts pattern and return list
# Usage: scripts=$(get_test_common_scripts)
get_test_common_scripts() {
	find "${TESTS_COMMON_PATH}" -maxdepth 1 -name "*.script.sh" -type f 2>/dev/null | sort
}

#==============================================================================
# End of Configuration
#==============================================================================
