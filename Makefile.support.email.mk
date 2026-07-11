# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

.PHONY: \
  email_send email_send_audit

email_send:
ifeq ($(strip $(audit)),)
	$(ECHO) "cawk error audit=AUDIT_NAME must be set ----"
else
ifeq ($(wildcard $(REPORT_PATH)/run_$(audit)/.),)
	$(ECHO) "cawk error audit=$(audit) do not exist  ----"
else
	if $(EGREP) -q "^$(audit) " $(DATABASE_PATH)/db_email.txt; then \
		email_info=$$($(EGREP) "^$(audit) " $(DATABASE_PATH)/db_email.txt); \
		dst=$$($(ECHO) $$email_info | awk '{print $$2}'); \
		cc=$$($(ECHO) $$email_info | awk '{print $$3}'); \
		if [ -z "$$dst" ]; then \
			$(ECHO) "cawk error dst not found for audit $(audit) ----"; \
			exit 0; \
		fi; \
		if [ -z "$$(find $(REPORT_PATH)/run_$(audit) -name '*.csv' -type f)" ]; then \
			$(ECHO) "cawk error no csv files found in $(REPORT_PATH)/run_$(audit) ----"; \
			exit 0; \
		fi; \
		zip -j -9 -q $(REPORT_PATH)/run_$(audit)/assessment.run_$(audit).export.zip $$(find $(REPORT_PATH)/run_$(audit) -type f \( -name '*all.summary.txt' -o -name '*all.idx' -o -name '*all.security.timeline.csv' -o -name '*all.audit.timeline.csv' -o -name '*all.psirt.timeline.csv' -o -name '*all.exception.timeline.csv' -o -name '*all.deadbeef.timeline.csv' \)) || true; \
		$(ECHO) "cawk sending audit $(audit) to $$dst ----"; \
		if [ "$$cc" != "none" ]; then \
			if [ -n "$$(find $(REPORT_PATH)/run_$(audit) -name '*all.summary.txt' -type f)" ]; then \
				cat $(COMMON_PATH)/common_message.txt | mutt -s "cawk $(audit) assessment" -a $(REPORT_PATH)/run_$(audit)/*all.summary.txt -a $(REPORT_PATH)/run_$(audit)/assessment.run_$(audit).export.zip -c $$cc -- $$dst; \
			else \
				$(ECHO) "cawk error no summary found in $(REPORT_PATH)/run_$(audit), email not sent ----"; \
			fi; \
		else \
			if [ -n "$$(find $(REPORT_PATH)/run_$(audit) -name '*all.summary.txt' -type f)" ]; then \
				cat $(COMMON_PATH)/common_message.txt | mutt -s "cawk $(audit) assessment" -a $(REPORT_PATH)/run_$(audit)/*all.summary.txt -a $(REPORT_PATH)/run_$(audit)/assessment.run_$(audit).export.zip -- $$dst; \
			else \
				$(ECHO) "cawk error no summary found in $(REPORT_PATH)/run_$(audit), email not sent ----"; \
			fi; \
		fi; \
		$(ECHO) "cawk email sent successfully ----"; \
	else \
		$(ECHO) "cawk error no email info found for audit $(audit) ----"; \
	fi
endif
endif
	$(ECHO) "cawk send_audit_email done ----"

email_send_audit:
	for audit in $(RUN_DIRS); do \
		$(GMAKE) email_send audit=$$audit; \
	done
	$(ECHO) "cawk email_send_audit done ----"
