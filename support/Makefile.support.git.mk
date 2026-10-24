# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

# ------------------------------------------------------------
# Git workflow - two release modes (all targets need FORCE=yes)
# ------------------------------------------------------------
# MODE 1 - Direct to master (solo / quick fixes):
#   gitinstallcicd -> gitcommit -> gitpush -> gitpushtag
#
# MODE 2 - Pull request (review, CODEOWNERS + branch protection):
#   gitnewbranch
#   gitinstallcicd -> gitcommit -> gitpushbranch -> gitpr
#   -> gitprmerge -> gitmasterupdate -> gitpushtag
#   (requires gh CLI authenticated; tag always applied on master)
# ------------------------------------------------------------

.PHONY: \
  gitcheck gitcheck_orthogonality gitcommit gitinstallcicd gitpush  \
  gitpushtag gitnewbranch gitpushbranch \
  gitpr gitprmerge gitmasterupdate \
  git_branch_master_check git_branch_not_master_check

# ------------------------------------------------------------

git_branch_master_check:
	@current=$$(git rev-parse --abbrev-ref HEAD); \
	if [ "$$current" != "master" ]; then \
		$(ECHO) "\033[31mcawk error: Git branch is '$$current'; must be 'master'.\033[0m"; \
		exit 1; \
	fi
	@$(ECHO) "cawk git_branch_master_check done ----"

git_branch_not_master_check:
	@current=$$(git rev-parse --abbrev-ref HEAD); \
	if [ "$$current" = "master" ]; then \
		$(ECHO) "\033[31mcawk error: Git branch is '$$current'; must NOT be 'master'.\033[0m"; \
		exit 1; \
	fi
	@$(ECHO) "cawk git_branch_not_master_check done ----"

# ------------------------------------------------------------

gitnewbranch: git_branch_master_check
	@if [ "$(FORCE)" = "yes" ]; then \
		git checkout -b $(CAWK_RELEASE)-beta; \
	else \
		$(ECHO) "cawk error: FORCE=yes must be set to run gitnewbranch ----"; \
		exit 1; \
	fi
	$(ECHO) "cawk gitnewbranch done ----"

# ------------------------------------------------------------

gitcheck_orthogonality:
	@rc=0; \
	report() { \
		if [ -n "$$2" ]; then \
			$(ECHO) "\033[31mcawk error: $$1\033[0m"; \
			$(ECHO) "$$2" | awk '{print "\033[37m  " $$0 "\033[0m"}'; \
			rc=1; \
		fi; \
	}; \
	srcs="-name *.gawk.template -o -name *.gawk.m4 -o -name *.gawk.include"; \
	for tag in test_name supplier purpose description actions nist800-53_ref risk_level authors; do \
		report "test sources without tag @$$tag" "$$(find tests/repo -type f \( $$srcs \) -exec grep -L "^# @$$tag " {} +)"; \
	done; \
	report "test sources with invalid @risk_level (high|medium|low|info)" "$$(find tests/repo -type f \( $$srcs \) -exec grep -H -m1 '^# @risk_level' {} + | \
		awk -F' : ' '{ n = split($$2, a, / *\| */); for (i = 1; i <= n; i++) { x = a[i]; gsub(/^ +| +$$/, "", x); if (x !~ /^(high|medium|low|info)$$/) { sub(/:.*/, "", $$1); print $$1 " -> " x; break } } }')"; \
	report "%SED_*% placeholders used but not defined in support/tests.sed" "$$(grep -rhoE '%SED_[A-Z0-9_]+%' tests/repo common m4 --include='*.template' --include='*.m4' --include='*.include' 2>/dev/null | sort -u | grep -v '^%SED_VAR%$$' | \
		while read -r p; do grep -qF "$$p" support/tests.sed || $(ECHO) "$$p"; done)"; \
	pathdiff=""; \
	for v in CONFS_PATH COMMON_PATH BACKUP_PATH DATABASE_PATH LOGS_PATH REPORT_PATH EXCEPTION_PATH TESTS_PATH TESTS_COMMON_PATH TESTS_SYSTEM TESTS_TMP; do \
		m=$$(sed -n "s/^$$v *= *//p" support/Makefile.support.mk | head -n 1 | sed 's/ *$$//'); \
		s=$$(sed -n "s/^$$v=\"\(.*\)\"/\1/p" database/include/scripts_config.sh | head -n 1); \
		[ "$$m" = "$$s" ] || pathdiff="$$pathdiff$$v: Makefile.support.mk='$$m' scripts_config.sh='$$s'\n"; \
	done; \
	report "path variables differ between Makefile.support.mk and scripts_config.sh" "$$(printf '%b' "$$pathdiff")"; \
	missing=""; \
	for s in $(SUPPLIER_SCOPE); do \
		[ -d "$(TESTS_PATH)/repo/tests.$$s" ] || missing="$${missing}$(TESTS_PATH)/repo/tests.$$s\n"; \
		[ -d "$(CONFS_PATH)/repo/confs.$$s" ] || missing="$${missing}$(CONFS_PATH)/repo/confs.$$s\n"; \
		[ -f "$(EXCEPTION_PATH)/repo/exceptions.$$s.m4" ] || missing="$${missing}$(EXCEPTION_PATH)/repo/exceptions.$$s.m4\n"; \
	done; \
	report "supplier of SUPPLIER_SCOPE without tests/confs/exceptions in repo" "$$(printf '%b' "$$missing")"; \
	unknown=""; \
	for d in $(TESTS_PATH)/repo/tests.* $(CONFS_PATH)/repo/confs.* $(EXCEPTION_PATH)/repo/exceptions.*.m4; do \
		s=$${d##*/}; s=$${s#tests.}; s=$${s#confs.}; s=$${s#exceptions.}; s=$${s%.m4}; s=$${s%.psirt}; s=$${s%.censored}; \
		case " $(SUPPLIER_SCOPE) " in *" $$s "*) ;; *) unknown="$$unknown$$d\n";; esac; \
	done; \
	report "repo supplier directories/files not in SUPPLIER_SCOPE" "$$(printf '%b' "$$unknown")"; \
	nopsirt=""; \
	for d in $(TESTS_PATH)/repo/tests.*.psirt; do \
		[ -d "$${d%.psirt}" ] || nopsirt="$$nopsirt$$d\n"; \
	done; \
	report "psirt test directories without standard tests directory" "$$(printf '%b' "$$nopsirt")"; \
	exit $$rc
	$(ECHO) "cawk gitcheck_orthogonality done ----"

gitcheck: tests_target_common
	$(GMAKE) clean clean_force FORCE=yes
	
	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start check databases\033[0m"
	$(RM) -f $(DATABASE_PATH)/db_info.txt
	$(RM) -f $(DATABASE_PATH)/db_exception.txt
	$(RM) -f $(DATABASE_PATH)/db_email.txt
	$(RM) -f $(DATABASE_PATH)/db_postaudit.txt
	$(RM) -f $(DATABASE_PATH)/db_sync.txt
	$(RM) -f $(DATABASE_PATH)/db_nist_mappings.json
	touch $(DATABASE_PATH)/db_email.txt
	touch $(DATABASE_PATH)/db_postaudit.txt
	touch $(DATABASE_PATH)/db_sync.txt
	touch $(DATABASE_PATH)/db_info.txt
	touch $(DATABASE_PATH)/db_exception.txt
	$(GMAKE) catalog_build
	$(GMAKE) exceptions_build
	@$(ECHO) "\033[31m================================================== : end check databases\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start filename without gawk code\033[0m"
	find tests/ -type f ! -name "*gawk*" ! -name ".gitkeep" | awk '{print "\033[37m" $$0 "\033[0m"}'
	@$(ECHO) "\033[31m================================================== : end check filename without gawk code\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start check tests error code\033[0m"
	$(GMAKE) tests_check_nok
	$(GMAKE) clean clean_force FORCE=yes
	@$(ECHO) "\033[31m================================================== : end check tests error code\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start check system check\033[0m"
	chmod 750 system/cawk_check_system
	@$(ECHO) "\033[0m" ; $(GMAKE) system ; $(ECHO) "\033[0m"
	@$(ECHO) "\033[31m================================================== : end call system check\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start supplier list\033[0m"
	$(GMAKE) supplier | awk '{print "\033[37m" $$0 "\033[0m"}'
	@$(ECHO) "\033[31m================================================== : end supplier list\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start audit list\033[0m"
	$(GMAKE) list_audit | awk '{print "\033[37m" $$0 "\033[0m"}'
	@$(ECHO) "\033[31m================================================== : end audit list\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start run_ directories not in audit list\033[0m"
	@audits=$$($(RUN_DIRS_FIND)); \
	orphans=$$(for d in $(LOGS_PATH) $(REPORT_PATH) $(TESTS_PATH) $(EXCEPTION_PATH) $(CONFS_PATH); do \
		find -L $$d -maxdepth 1 -type d -name 'run_*' 2>/dev/null; \
	done | while read -r p; do \
		printf '%s\n' "$$audits" | grep -Fxq -- "$${p##*/run_}" || $(ECHO) "$$p"; \
	done); \
	if [ -n "$$orphans" ]; then \
		$(ECHO) "$$orphans" | awk '{print "\033[37m" $$0 "\033[0m"}'; \
		$(ECHO) "\033[31mcawk error: run_ directories above do not belong to any audit of list_audit\033[0m"; \
		exit 1; \
	fi
	@$(ECHO) "\033[31m================================================== : end run_ directories not in audit list\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start no *.gawk must be there\033[0m"
	find . -name '*.gawk' | awk '{print "\033[37m" $$0 "\033[0m"}'
	@$(ECHO) "\033[31m================================================== : end no *.gawk must be there\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start no *.script must be there\033[0m"
	find . -name '*.script' | awk '{print "\033[37m" $$0 "\033[0m"}'
	@$(ECHO) "\033[31m================================================== : end no *.script must be there\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start clean vscode param\033[0m"
	find . -name .DS_Store | xargs $(RM) -f
	$(RM) -r -f .vscode
	@$(ECHO) "\033[31m================================================== : end clean vscode param\033[0m"
	
	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start docker state\033[0m"
	gmake -f Makefile.docker info
	@$(ECHO) "\033[31m================================================== : end docker state\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start update run repository confs && tests && exceptions from repo\033[0m"
	$(RM) -r confs/run && cp -r confs/repo confs/run
	$(RM) -r tests/run && cp -r tests/repo tests/run
	$(RM) -r exceptions/run && cp -r exceptions/repo exceptions/run
	@$(ECHO) "\033[31m================================================== : end update run repository confs && tests && exceptions from repo\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start touch .gitkeep in reports and tmp\033[0m"
	touch reports/repo/.gitkeep && touch reports/run/.gitkeep && touch tmp/.gitkeep
	touch reports/repo/archives/.gitkeep && touch reports/run/archives/.gitkeep
	@$(ECHO) "\033[31m================================================== : end touch .gitkeep in reports and tmp\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start check .gitkeep in directories\033[0m"
	@for dir in reports/repo reports/run tests/repo tests/run confs/repo confs/run exceptions/repo exceptions/run tmp; do \
		if [ ! -f "$$dir/.gitkeep" ]; then \
			$(ECHO) "$$dir" | awk '{print "\033[37m" $$0 "\033[0m"}'; \
		fi; \
	done
	@$(ECHO) "\033[31m================================================== : end check .gitkeep in directories\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start check CRLF in test templates\033[0m"
	find tests/repo -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -l "$$(printf '\r')" {} \; | awk '{print "\033[37m" $$0 "\033[0m"}'
	find database -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -l "$$(printf '\r')" {} \; | awk '{print "\033[37m" $$0 "\033[0m"}'
	find common -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -l "$$(printf '\r')" {} \; | awk '{print "\033[37m" $$0 "\033[0m"}'
	find confs -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -l "$$(printf '\r')" {} \; | awk '{print "\033[37m" $$0 "\033[0m"}'
	find exceptions -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -l "$$(printf '\r')" {} \; | awk '{print "\033[37m" $$0 "\033[0m"}'
	find m4 -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -l "$$(printf '\r')" {} \; | awk '{print "\033[37m" $$0 "\033[0m"}'
	find support -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -l "$$(printf '\r')" {} \; | awk '{print "\033[37m" $$0 "\033[0m"}'
	find system -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -l "$$(printf '\r')" {} \; | awk '{print "\033[37m" $$0 "\033[0m"}'
	@$(ECHO) "\033[31m================================================== : end check CRLF in test templates\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start check orthogonality\033[0m"
	$(GMAKE) gitcheck_orthogonality
	@$(ECHO) "\033[31m================================================== : end check orthogonality\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start check databases are not empty\033[0m"
	@for db in database/db_info.txt database/db_exception.txt; do \
		if [ ! -s "$$db" ]; then \
			$(ECHO) "$$db" | awk '{print "\033[37m❌ empty: " $$0 "\033[0m"}'; \
		fi; \
	done
	@$(ECHO) "\033[31m================================================== : end check databases are not empty\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start check critical directories exist\033[0m"
	@for dir in confs tests exceptions reports tmp database; do \
		if [ ! -d "$$dir" ]; then \
			$(ECHO) "$$dir" | awk '{print "\033[37m❌ missing directory: " $$0 "\033[0m"}'; \
		fi; \
	done
	@$(ECHO) "\033[31m================================================== : end check critical directories exist\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start check archives directories exist\033[0m"
	@for archdir in reports/repo/archives reports/run/archives; do \
		if [ ! -d "$$archdir" ]; then \
			$(ECHO) "$$archdir" | awk '{print "\033[37m❌ missing directory: " $$0 "\033[0m"}'; \
		fi; \
	done
	@$(ECHO) "\033[31m================================================== : end check archives directories exist\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start check file extensions (.template.m4 invalid)\033[0m"
	@invalid=$$(find tests/repo exceptions/repo -type f -name "*.template.m4" -o -name "*.m4.template"); \
	if [ -n "$$invalid" ]; then \
		echo "$$invalid" | awk '{print "\033[37m❌ invalid extension: " $$0 "\033[0m"}'; \
	fi
	@$(ECHO) "\033[31m================================================== : end check file extensions\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start check backup files (.orig)\033[0m"
	@backups=$$(find . -type f -name "*.orig" 2>/dev/null | sort); \
	if [ -n "$$backups" ]; then \
		$(ECHO) "\033[37m✓ Backup files found:\033[0m"; \
		echo "$$backups" | awk '{print "\033[37m  " $$0 "\033[0m"}'; \
	else \
		$(ECHO) "\033[37m ℹ No backup files (.orig) found\033[0m"; \
	fi
	@$(ECHO) "\033[31m================================================== : end check backup files\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start update Makefile.support.mk with CAWK_RELEASE = $(CAWK_RELEASE)\033[0m"
	@$(ECHO) "\033[31m================================================== : end update Makefile.support.mk with CAWK_RELEASE = $(CAWK_RELEASE)\033[0m"
	@$(ECHO) "cawk gitcheck done ----"


# ------------------------------------------------------------

gitinstallcicd:
	if [ "$(FORCE)" = "yes" ]; then \
		mkdir -p .github/workflows; \
		cp cicd/*.yml .github/workflows/ 2>/dev/null || true; \
	else \
		$(ECHO) "cawk error: FORCE=yes must be set to run gitinstallcicd ----"; \
		exit 1; \
	fi
	$(ECHO) "cawk gitinstallcicd done ----"

# ------------------------------------------------------------

gitcommit: gitinstallcicd
	if [ "$(FORCE)" = "yes" ]; then \
		git add .; \
		msg="*$(CAWK_RELEASE) ref ChangeLog"; \
		if [ -n "$(CO_AUTHOR)" ]; then \
			msg="$$msg\n\n$(CO_AUTHOR)"; \
		fi; \
		printf "$$msg" > .git_commit_msg; \
		git commit -F .git_commit_msg; \
		rm -f .git_commit_msg; \
	else \
		$(ECHO) "cawk error: FORCE=yes must be set to run gitcommit ----"; \
		exit 1; \
	fi
	@echo "gitpush or gitpushbranchtarget next step"
	@$(ECHO) "cawk gitcommit done ----"

# ------------------------------------------------------------

# DIRECT -----------------------------------------------------

gitpush: git_branch_master_check
	@if [ "$(FORCE)" = "yes" ]; then \
		git push origin master; \
	else \
		$(ECHO) "cawk error: FORCE=yes must be set to run gitpush ----"; \
		exit 1; \
	fi
	$(ECHO) "cawk gitpush done ----"

# BRANCH -----------------------------------------------------

gitpushbranch: git_branch_not_master_check
	@if [ "$(FORCE)" = "yes" ]; then \
		git push origin $(CAWK_RELEASE)-beta; \
	else \
		$(ECHO) "cawk error: FORCE=yes must be set to run gitpushbranch ----"; \
		exit 1; \
	fi
	$(ECHO) "cawk gitpushbranch done ----"

gitpr: git_branch_not_master_check
	@if [ "$(FORCE)" = "yes" ]; then \
		gh pr create --title "cawk $(CAWK_RELEASE)" --base master --head $$(git branch --show-current); \
	else \
		$(ECHO) "cawk error: FORCE=yes must be set to run gitpr ----"; \
		exit 1; \
	fi
	@echo "gitprmerge target next step"
	@$(ECHO) "cawk gitpr done ----"

gitprmerge: git_branch_not_master_check
	@if [ "$(FORCE)" = "yes" ]; then \
		gh pr merge --merge --delete-branch; \
	else \
		$(ECHO) "cawk error: FORCE=yes must be set to run gitprmerge ----"; \
		exit 1; \
	fi
	@echo "gitmasterupdate target next step"
	@$(ECHO) "cawk gitprmerge done ----"

gitmasterupdate: git_branch_not_master_check
	@if [ "$(FORCE)" = "yes" ]; then \
		git checkout master; \
		git pull origin master; \
	else \
		$(ECHO) "cawk error: FORCE=yes must be set to run gitmasterupdate ----"; \
		exit 1; \
	fi
	@echo "gitpushtag target next step"
	@$(ECHO) "cawk gitmasterupdate done ----"

# ------------------------------------------------------------

gitpushtag: git_branch_master_check
	@if [ "$(FORCE)" = "yes" ]; then \
		git tag -a $(CAWK_RELEASE) -m "$(CAWK_RELEASE)"; \
		git push origin $(CAWK_RELEASE); \
	else \
		$(ECHO) "cawk error: FORCE=yes must be set to run gitpushtag ----"; \
		exit 1; \
	fi
	$(ECHO) "cawk gitpushtag done ----"

