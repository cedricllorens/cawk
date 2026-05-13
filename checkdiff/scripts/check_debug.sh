#!/bin/bash

# -----------------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# -----------------------------------------------------------------------
# Debug checker - runs full gmake check and logs results
# Also creates phases.txt mapping with command descriptions
# -----------------------------------------------------------------------

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/check_debug.log"
PHASES_FILE="$SCRIPT_DIR/phases.txt"

echo "cawk running full cawk check (10-15 minutes) ----"
echo ""
echo "This will execute all phases and generate checkdiff.new"
echo "Command mapping: $PHASES_FILE"
echo "Detailed log:    $LOG_FILE"
echo ""

# Generate phases.txt dynamically from Makefile
generate_phases_file() {
    cat > "$PHASES_FILE" << 'PHASES_EOF'
gmake catalog_build
gmake check_repo
gmake check_repo supplier=cisco-ios
gmake check_repo JSON=no
gmake check_repo JSON=yes
gmake check_run
gmake check_run supplier=cisco-ios
gmake check_run JSON=no
gmake check_run JSON=yes
gmake check_run (2nd)
gmake check_run supplier=cisco-ios (2nd)
create_audit client1 + sync_run
gmake check_run audit=client1
gmake check_run audit=client1 supplier=cisco-ios
create_audit client2
gmake check_run audit=client2
gmake check_run audit=client2 supplier=cisco-ios
gmake clean + check_repo
gmake check_repo (after clean)
gmake check_run
gmake check_run audit=client1
gmake check_run audit=client2
gmake view_repo
gmake view_repo_error
gmake view_repo supplier=cisco-ios
gmake view_run
gmake view_run supplier=cisco-ios
gmake view_run supplier=cisco-ios audit=client1
gmake view_run supplier=cisco-ios audit=client2
gmake backup_run operations
find backup/ -name '*.tar.gz' | wc -l
PHASES_EOF
}

generate_phases_file

{
    echo "cawk check debug started ----"
    echo "Timestamp: $(date)"
    echo ""
    gmake check
    echo ""
    echo "cawk check debug completed ----"
    echo "Timestamp: $(date)"
} | tee "$LOG_FILE"

echo ""
echo "cawk phases mapping created: $PHASES_FILE ----"
echo "cawk debug log saved to:     $LOG_FILE ----"
echo "cawk results in:             checkdiff/checkdiff.new ----"
echo ""
echo "cawk next: run 'gmake check_analyze' to see which phases changed ----"
