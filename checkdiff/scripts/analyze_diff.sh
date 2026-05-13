#!/bin/bash

# -----------------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# -----------------------------------------------------------------------
# Analyze differences between checkdiff.old and checkdiff.new
# Shows which phases differ and by how much
# -----------------------------------------------------------------------

if [ ! -f "checkdiff/checkdiff.old" ] || [ ! -f "checkdiff/checkdiff.new" ]; then
    echo "cawk error: checkdiff.old or checkdiff.new not found ----"
    exit 1
fi

echo "cawk checkdiff - phase comparison report ----"

OLD_FILE="checkdiff/checkdiff.old"
NEW_FILE="checkdiff/checkdiff.new"
PHASES_FILE="checkdiff/scripts/phases.txt"

# Check if phases.txt exists
if [ ! -f "$PHASES_FILE" ]; then
    echo "⚠ Warning: $PHASES_FILE not found"
    echo "Run 'gmake check_debug' first to generate phase descriptions"
    echo ""
fi

# Compare line by line and collect stats
DIFFS=0
MATCHES=0

paste "$OLD_FILE" "$NEW_FILE" | nl | while read line_num old new; do
    # Get phase description from phases.txt if available
    PHASE_DESC=""
    if [ -f "$PHASES_FILE" ]; then
        PHASE_DESC=$(sed -n "${line_num}p" "$PHASES_FILE" 2>/dev/null)
    fi

    if [ "$old" = "$new" ]; then
        printf "✓ Phase %2d: %-35s | %5d lines (OK)\n" "$line_num" "$PHASE_DESC" "$old"
        MATCHES=$((MATCHES + 1))
    else
        DELTA=$((new - old))
        SIGN=$([ $DELTA -gt 0 ] && echo "+" || echo "")
        printf "✗ Phase %2d: %-35s | %5d → %5d [${SIGN}%d]\n" "$line_num" "$PHASE_DESC" "$old" "$new" "$DELTA"
        DIFFS=$((DIFFS + 1))
    fi
done

echo ""
diff -u "$OLD_FILE" "$NEW_FILE" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    TOTAL=$(wc -l < "$OLD_FILE")
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              RESULT: ALL PHASES MATCH ✓                       ║"
    echo "║              ( $TOTAL of $TOTAL phases OK)                       ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
else
    TOTAL=$(wc -l < "$OLD_FILE")
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║              RESULT: SOME PHASES DIFFER                        ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
fi
