# Checkdiff - Enhanced Debugging System

Quick access to debugging tools and documentation.

## Structure

```
checkdiff/
├── scripts/           # Executable scripts (source: *.sh, compiled: no extension)
│   ├── analyze_diff   # Compare checkdiff.old vs checkdiff.new
│   ├── check_debug    # Run full gmake check + generate phase descriptions
│   ├── run_check      # Master orchestrator (debug/analyze/log modes)
│   └── diff_reports   # Investigate specific phases
│
└── README.md          # This file
```

## Quick Start

### 1. Run full check (10-15 minutes)
```bash
gmake check_debug
```
Executes `gmake check` and generates `checkdiff/scripts/phases.txt` with command descriptions.

### 2. Analyze differences (< 1 second)
```bash
gmake check_analyze
```
Shows which phases differ and by how much, with command details.

### 3. View detailed logs
```bash
gmake check_debug_log
```
Displays the full debug log from the last check.

## Generated Files (auto-cleaned on gmake clean)

- `checkdiff/scripts/phases.txt` — Phase-to-command mapping (generated dynamically)
- `checkdiff/scripts/check_debug.log` — Detailed execution log
- Compiled executables: `analyze_diff`, `check_debug`, `run_check`, `diff_reports`

## For More Information

👉 **New to cawk?** Start with: [`doc/START_HERE.txt`](doc/START_HERE.txt)

👉 **Quick 5-minute guide?** See: [`doc/QUICK_START.md`](doc/QUICK_START.md)

👉 **Reference all tools?** Check: [`doc/TOOLS.md`](doc/TOOLS.md)

👉 **Full technical details?** Read: [`doc/README.debug`](doc/README.debug)
