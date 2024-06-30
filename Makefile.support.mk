# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# cawk is Copyright (C) 2024 by Cedric Llorens
# ------------------------------------------------------------
#
# Makefile.support.mk
# 
# Used to define cawk && Makefile options
# ------------------------------------------------------------

# ---------------
CAWK_RELEASE = v1.7.0

# --------------- cawk parallel options
# enable parallel : yes/no
MAKE_PARALLEL = no
# number of files to process per target (all targets are processed in parallel)
MAKE_FILES_PER_TARGET = 100

# --------------- gmake parallel options
# gmake number of jobs
MAKE_J = 4
# gmake load average
MAKE_LOAD_AVG = 3
