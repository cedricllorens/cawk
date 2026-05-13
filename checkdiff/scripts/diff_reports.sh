#!/bin/bash

# -----------------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# -----------------------------------------------------------------------
# Compare CSV reports and show differences
# -----------------------------------------------------------------------

PHASE="${1:-}"

if [ -z "$PHASE" ]; then
    echo "cawk usage: $0 <phase_number> ----"
    echo ""
    echo "cawk examples:"
    echo "  $0 21   - Show changes in phase 21"
    echo "  $0 26   - Show changes in phase 26"
    exit 0
fi

echo "cawk analyzing phase $PHASE ----"
echo ""

if [ ! -d "reports" ]; then
    echo "cawk error: reports directory not found ----"
    exit 1
fi

echo "cawk csv files in reports/ ----"
find reports -name "*.csv" -type f | head -10
