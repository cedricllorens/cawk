# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

# check_track runs gmake check unchanged through a SHELL wrapper that records, per phase,
# the counter written in checkdiff.new, the sorted content the counter counted, its command
# and its exit status in checkdiff/track/trace (trace.tsv, snap/, last.txt, not versioned);
# the last run only is kept there, the reference of check_track_update in checkdiff/track/ref
# (versioned), the last one only. check_track fails when the trace does not hold one line
# per counter of checkdiff.new (self-test of the tracking itself).

.PHONY: check_track check_track_explain check_track_update clean_track

check_track:
	$(RM) -rf $(TRACK_PATH)/trace
	mkdir -p $(TRACK_PATH)/trace/snap
	sh $(TRACK_SCRIPTS)/env_snapshot.sh $(TRACK_PATH)/trace/env.txt
	rc=0; $(GMAKE) check CHECK_TRACK=yes SHELL=$(CURDIR)/$(TRACK_SCRIPTS)/trace_shell.sh || rc=$$?; \
	if [ $$rc -ne 0 ]; then sh $(TRACK_SCRIPTS)/explain_diff.sh; fi; \
	nb=$$(wc -l < checkdiff/checkdiff.new 2>/dev/null || echo 0); \
	tr=$$(wc -l < $(TRACK_PATH)/trace/trace.tsv 2>/dev/null || echo 0); \
	if [ "$$nb" != "$$tr" ]; then $(ECHO) "cawk error: trace.tsv holds $$tr phases, checkdiff.new holds $$nb counters, tracking broken ----"; exit 1; fi; \
	exit $$rc

check_track_explain:
	sh $(TRACK_SCRIPTS)/explain_diff.sh

check_track_update:
	@if [ ! -f $(TRACK_PATH)/trace/trace.tsv ]; then \
		$(ECHO) "cawk error: no trace, run gmake check_track first ----"; exit 1; \
	fi
	$(GMAKE) check_update
	$(RM) -rf $(TRACK_PATH)/ref
	mkdir -p $(TRACK_PATH)/ref
	cp -R $(TRACK_PATH)/trace/snap $(TRACK_PATH)/trace/trace.tsv $(TRACK_PATH)/trace/env.txt $(TRACK_PATH)/ref/
	$(ECHO) "cawk check_track_update done ----"

clean_track:
	@if [ "$(FORCE)" != "yes" ]; then \
		$(ECHO) "cawk error: FORCE=yes must be set to run clean_track ----"; \
		exit 1; \
	fi
	$(RM) -rf $(TRACK_PATH)/trace
	$(ECHO) "cawk clean_track done ----"
