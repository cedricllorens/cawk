# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

.PHONY: \
  roles_list roles_perm

roles_perm:
	@if [ ! -f "roles/cawk_perm" ]; then \
		$(ECHO) "cawk error: roles/cawk_perm script not found ----"; \
		exit 1; \
	fi
	@sudo roles/cawk_perm

roles_list:
	@$(ECHO) ""
	@$(ECHO) "Members of cawk_admin:"
	@getent group cawk_admin | cut -d: -f4 | tr ',' '\n' | grep -v '^$$' | sed 's/^/  - /' || $(ECHO) "  (group not found)"
	@$(ECHO) ""
	@$(ECHO) "Members of cawk_auditor:"
	@getent group cawk_auditor | cut -d: -f4 | tr ',' '\n' | grep -v '^$$' | sed 's/^/  - /' || $(ECHO) "  (group not found)"
	@$(ECHO) ""
	@$(ECHO) "Members of cawk_approver:"
	@getent group cawk_approver | cut -d: -f4 | tr ',' '\n' | grep -v '^$$' | sed 's/^/  - /' || $(ECHO) "  (group not found)"
	@$(ECHO) ""