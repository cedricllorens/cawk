# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2025 by Cedric Llorens
# ------------------------------------------------------------

# ---------------
CAWK_RELEASE = v2.6.0

# --------------- cawk parallel options
# enable parallel : yes/no
MAKE_PARALLEL ?= no
# number of files to process per target (all targets are processed in parallel)
MAKE_FILES_PER_TARGET ?= 100

# --------------- gmake parallel options
# gmake number of jobs
MAKE_J ?= 4
# gmake load average
MAKE_LOAD_AVG ?= 3

# --------------- gmake in silent mode
MAKEFLAGS += -s

# --------------- find specific parameters
FIND_CONF_SELECT = ! -type d

# --------------- json specific parameters
# if set to yes json reporting is activated
JSON ?= no
