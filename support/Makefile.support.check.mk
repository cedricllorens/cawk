# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

.PHONY: \
  check check_analyze check_checkdiff check_debug  \
  check_debug_log check_parallel check_parallel_debug check_update

check:
	$(GMAKE) clean clean_force FORCE=yes
	find -H confs -type f -exec touch {} \;
	find -H validate/test-sync/source -type f -exec touch {} \;
	$(RM) -f checkdiff/checkdiff.new

	$(GMAKE) catalog_build
	$(GMAKE) exceptions_build

	$(GMAKE) check_repo
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_repo supplier=cisco-ios
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	$(GMAKE) check_repo JSON=no
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_repo SECRETSCAN=yes JSON=yes HTML=yes
	test -s reports/repo/assessment.all.censored.csv && test -z "$$(find reports/repo -maxdepth 1 -name 'assessment.*.csv' ! -name '*.censored.csv')" || { $(ECHO) "cawk error: SECRETSCAN=yes left an uncensored csv report or no censored csv report in reports/repo ----"; exit 1; }
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_repo JSON=yes
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_repo DEADBEEF=yes
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_repo BADFORMAT=yes
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	$(GMAKE) check_run
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_run supplier=cisco-ios
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	$(GMAKE) check_run JSON=no
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_run JSON=yes
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	$(GMAKE) check_run
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_run supplier=cisco-ios
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	$(GMAKE) check_run JSON=no
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_run JSON=yes
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	$(GMAKE) create_audit audit=client1_skffqsfqhsf10948494

	$(GMAKE) database_sync_update audit=client1_skffqsfqhsf10948494 \
		dir=$(CURDIR)/validate/test-sync/source/,$(CURDIR)/validate/test-sync/source/_backup/ \
		regexinventory=.*\\.cfg$$ \
		scope=validate/test-sync/scope.txt \
		regexos=cisco-ios\|cisco-sdnios\|fortinet-fortios\|juniper-junos \
		regexpathexclude=_backup \
		regexinventoryexclude=none

	$(GMAKE) sync_run audit=client1_skffqsfqhsf10948494
	find confs/run_client1_skffqsfqhsf10948494/confs.* -type l 2>/dev/null | sort | wc -l >> checkdiff/checkdiff.new
	find confs/run_client1_skffqsfqhsf10948494 -maxdepth 1 -type d -name 'confs.*' | sort | wc -l >> checkdiff/checkdiff.new

	$(GMAKE) sync_teststoconfs_run audit=client1_skffqsfqhsf10948494
	find tests/run_client1_skffqsfqhsf10948494 -maxdepth 1 -name 'zz.sync.save.*' | sort | wc -l >> checkdiff/checkdiff.new
	find tests/run_client1_skffqsfqhsf10948494 -maxdepth 1 -name 'tests.*' | sort | wc -l >> checkdiff/checkdiff.new

	$(GMAKE) sync_exceptionstoconfs_run audit=client1_skffqsfqhsf10948494
	find exceptions/run_client1_skffqsfqhsf10948494 -maxdepth 1 -name 'zz.sync.save.*' | sort | wc -l >> checkdiff/checkdiff.new
	find exceptions/run_client1_skffqsfqhsf10948494 -maxdepth 1 -name 'exceptions.*' | sort | wc -l >> checkdiff/checkdiff.new

	$(GMAKE) sync_psirt audit=client1_skffqsfqhsf10948494
	wc -c < database/psirt_scopes/psirt_os_inventory_scope.txt >> checkdiff/checkdiff.new

	$(GMAKE) check_run audit=client1_skffqsfqhsf10948494
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_run audit=client1_skffqsfqhsf10948494 supplier=cisco-ios
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	$(GMAKE) check_run audit=client1_skffqsfqhsf10948494 PSIRT_ONLY=yes
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_run audit=client1_skffqsfqhsf10948494 supplier=cisco-ios PSIRT_ONLY=yes
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	$(GMAKE) database_sync_del audit=client1_skffqsfqhsf10948494
	$(EGREP) "^client1_skffqsfqhsf10948494 " database/db_sync.txt && $(ECHO) "cawk error: db_sync.txt still holds a test entry ----" || $(ECHO) "cawk db_sync.txt cleanly reset ----"
	wc -c < database/db_sync.txt >> checkdiff/checkdiff.new

	$(GMAKE) database_email_update audit=client1_skffqsfqhsf10948494 dst=test1@example.com,test2@example.com cc=test3@example.com
	$(EGREP) "^client1_skffqsfqhsf10948494 " database/db_email.txt | wc -l >> checkdiff/checkdiff.new

	$(GMAKE) database_email_del audit=client1_skffqsfqhsf10948494
	$(EGREP) "^client1_skffqsfqhsf10948494 " database/db_email.txt && $(ECHO) "cawk error: db_email.txt still holds a test entry ----" || $(ECHO) "cawk db_email.txt cleanly reset ----"
	wc -c < database/db_email.txt >> checkdiff/checkdiff.new

	$(GMAKE) database_postaudit_update audit=client1_skffqsfqhsf10948494
	$(EGREP) "^client1_skffqsfqhsf10948494$$" database/db_postaudit.txt | wc -l >> checkdiff/checkdiff.new

	$(GMAKE) database_postaudit_del audit=client1_skffqsfqhsf10948494
	$(EGREP) "^client1_skffqsfqhsf10948494$$" database/db_postaudit.txt && $(ECHO) "cawk error: db_postaudit.txt still holds a test entry ----" || $(ECHO) "cawk db_postaudit.txt cleanly reset ----"
	wc -c < database/db_postaudit.txt >> checkdiff/checkdiff.new

	$(GMAKE) create_audit audit=client2_mqsdhqndqqos198440
	$(GMAKE) check_run audit=client2_mqsdhqndqqos198440
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_run audit=client2_mqsdhqndqqos198440 supplier=cisco-ios
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	$(GMAKE) sync_run_audit
	$(GMAKE) sync_teststoconfs_run_audit
	$(GMAKE) sync_exceptionstoconfs_run_audit
	$(GMAKE) list_audit | wc -l >> checkdiff/checkdiff.new

	$(GMAKE) clean
	$(GMAKE) check_repo
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_repo
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_run
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_run audit=client1_skffqsfqhsf10948494
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_run audit=client2_mqsdhqndqqos198440

	$(GMAKE) view_repo | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) view_repo_error | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) view_repo supplier=cisco-ios | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) view_run | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) view_run supplier=cisco-ios | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) view_run supplier=cisco-ios audit=client1_skffqsfqhsf10948494 | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) view_run supplier=cisco-ios audit=client2_mqsdhqndqqos198440 | wc -l >> checkdiff/checkdiff.new

	$(GMAKE) backup_run audit=client2_mqsdhqndqqos198440
	$(GMAKE) backup_run audit=client1_skffqsfqhsf10948494
	$(GMAKE) backup_run_audit
	find backup/ -name '*.tar.gz' | wc -l >> checkdiff/checkdiff.new
	
	$(GMAKE) clean
	$(GMAKE) delete_audit audit=client1_skffqsfqhsf10948494
	$(GMAKE) restore_run_audit file=backup/run_audit_$(TODAY).tar.gz
	
	$(GMAKE) check_run audit=client1_skffqsfqhsf10948494
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_run audit=client1_skffqsfqhsf10948494 supplier=cisco-ios
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	$(GMAKE) clean
	$(GMAKE) delete_audit audit=client1_skffqsfqhsf10948494
	$(GMAKE) restore_run_audit file=backup/run_audit_client1_skffqsfqhsf10948494_$(TODAY).tar.gz

	$(GMAKE) check_run audit=client1_skffqsfqhsf10948494
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_run audit=client1_skffqsfqhsf10948494 supplier=cisco-ios
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	$(GMAKE) clean
	$(GMAKE) delete_audit audit=client1_skffqsfqhsf10948494

	$(GMAKE) create_audit audit=client1_skffqsfqhsf10948494
	$(RM) -r -f confs/run*client1_skffqsfqhsf10948494/*cisco-ios* tests/run*client1_skffqsfqhsf10948494/*cisco-ios* || true
	$(GMAKE) check_run audit=client1_skffqsfqhsf10948494 JSON=no
	$(GMAKE) check_run audit=client1_skffqsfqhsf10948494 JSON=yes
	$(GMAKE) check_run audit=client1_skffqsfqhsf10948494 JSON=no supplier=cisco-ios
	$(GMAKE) check_run audit=client1_skffqsfqhsf10948494 JSON=yes supplier=cisco-ios
	$(GMAKE) delete_audit audit=client1_skffqsfqhsf10948494
	$(GMAKE) delete_audit audit=client2_mqsdhqndqqos198440
	$(GMAKE) clean clean_force FORCE=yes
	$(GMAKE) clean_logs FORCE=yes

	$(RM) -f checkdiff/cawk-crypto-image.new
	sha512sum checkdiff/checkdiff.new > checkdiff/cawk-crypto-image.new

	$(ECHO) "------------------------------------------------------"
	$(ECHO) "------------------------------------------------------"
	$(ECHO) "CHECK MUST BE OK -------------------------------------"
	$(ECHO) "------------------------------------------------------"
	$(ECHO) "check cawk commands ----"
	diff checkdiff/checkdiff.new checkdiff/checkdiff.old >/dev/null && $(ECHO) OK || $(ECHO) NOK
	$(ECHO) "check cawk crypto image ----"
	diff checkdiff/cawk-crypto-image.new checkdiff/cawk-crypto-image.old >/dev/null && $(ECHO) OK || $(ECHO) NOK
	$(ECHO) "------------------------------------------------------"
	$(ECHO) "CHECK MUST BE OK -------------------------------------"
	$(ECHO) "------------------------------------------------------"
	$(ECHO) "------------------------------------------------------"
	diff checkdiff/checkdiff.new checkdiff/checkdiff.old >/dev/null && diff checkdiff/cawk-crypto-image.new checkdiff/cawk-crypto-image.old >/dev/null || { $(ECHO) "cawk error: check NOK ----"; exit 1; }
	$(ECHO) "cawk check done ----"

check_parallel:
	$(GMAKE) check MAKE_PARALLEL=yes

check_update:
	$(RM) -f checkdiff/cawk-crypto-image.new
	sha512sum checkdiff/checkdiff.new > checkdiff/cawk-crypto-image.new
	cp -v checkdiff/checkdiff.new checkdiff/checkdiff.old
	cp -v checkdiff/cawk-crypto-image.new checkdiff/cawk-crypto-image.old
	$(ECHO) "cawk check_update done ----"

check_debug: check_checkdiff
	./checkdiff/scripts/check_debug
	$(ECHO) "cawk check_debug completed - use '$(GMAKE) check_analyze' to see results"

check_analyze: check_checkdiff
	./checkdiff/scripts/analyze_diff
	$(ECHO) "cawk check_analyze completed - checkdiff/checkdiff_report.txt generated with analysis results"

check_debug_log: check_checkdiff
	./checkdiff/scripts/run_check log
	$(ECHO) "cawk check_debug_log completed - checkdiff/checkdiff_log.txt generated with debug logs"

check_parallel_debug: check_checkdiff
	./checkdiff/scripts/check_parallel_debug
	$(ECHO) "cawk check_parallel_debug completed - use '$(GMAKE) check_analyze' to see results"

check_checkdiff:
	$(GMAKE) checkdiff/scripts/analyze_diff checkdiff/scripts/check_debug checkdiff/scripts/check_parallel_debug checkdiff/scripts/run_check checkdiff/scripts/diff_reports
	$(ECHO) "cawk check_checkdiff done ----"


