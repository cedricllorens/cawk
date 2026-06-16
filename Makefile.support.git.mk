# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

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
	@$(ECHO) "\033[31m================================================== : start no *.gawk must be there\033[0m"
	find . -name *.gawk | awk '{print "\033[37m" $$0 "\033[0m"}'
	@$(ECHO) "\033[31m================================================== : end no *.gawk must be there\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start no *.script must be there\033[0m"
	find . -name .DS_Store | xargs $(RM) -f
	@$(ECHO) "\033[31m================================================== : end clean DS store file\033[0m"

	$(ECHO) ""
	@$(ECHO) "\033[31m================================================== : start clean vscode param\033[0m"
	find . -name .DS_Store | xargs $(RM) -f
	$(RM) -r -f .vscode
	@$(ECHO) "\033[31m================================================== : end clean vscode param\033[0m"

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
	@$(ECHO) "\033[31m================================================== : start check metadata in test templates\033[0m"
	@missing=$$(find tests/repo -type f \( -name "*.gawk.template" -o -name "*.gawk.m4" -o -name "*.gawk.include" \) -exec grep -L "# @test_name\|# @supplier\|# @purpose\|# @description\|# @actions\|# @nist800-53_ref\|# @authors" {} \;); \
	if [ -n "$$missing" ]; then \
		echo "$$missing" | sed 's/^/  /' | awk '{print "\033[37m❌ " $$0 "\033[0m"}'; \
	fi
	@$(ECHO) "\033[31m================================================== : end check metadata in test templates\033[0m"

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

gitinstallcicd:
	@if [ "$(FORCE)" = "yes" ]; then \
		mkdir -p .github/workflows; \
		cp cicd/release.yml .github/workflows/release.yml; \
	fi

gitcommit:
	@if [ "$(FORCE)" = "yes" ]; then \
		git add .; \
		git commit -m "*$(CAWK_RELEASE) ref ChangeLog"; \
	fi

gitpush:
	@if [ "$(FORCE)" = "yes" ]; then \
		git push origin master; \
	fi

gitpushtag:
	@if [ "$(FORCE)" = "yes" ]; then \
		git tag -a $(CAWK_RELEASE) -m "$(CAWK_RELEASE)"; \
		git push origin $(CAWK_RELEASE); \
	fi

