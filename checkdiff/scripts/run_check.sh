#!/bin/sh

# -----------------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# -----------------------------------------------------------------------
# Master orchestrator for check operations
# -----------------------------------------------------------------------

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODE="${1:-debug}"

case "$MODE" in
    debug)
        echo "cawk running check in debug mode ----"
        "$SCRIPT_DIR/check_debug.sh"
        echo ""
        echo "cawk analyzing results ----"
        "$SCRIPT_DIR/analyze_diff.sh"
        ;;
    analyze)
        echo "cawk analyzing existing results ----"
        "$SCRIPT_DIR/analyze_diff.sh"
        ;;
    log)
        if [ -f "$SCRIPT_DIR/check_debug.log" ]; then
            cat "$SCRIPT_DIR/check_debug.log"
        else
            echo "cawk no debug log found ----"
        fi
        ;;
    *)
        echo "cawk usage: $0 [debug|analyze|log] ----"
        exit 1
        ;;
esac
