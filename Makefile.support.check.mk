# ------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
# cawk is Copyright (C) 2024-2026 by Cedric Llorens
# ------------------------------------------------------------

check:
	$(GMAKE) clean clean_force FORCE=yes
	find confs -type f -exec touch {} \;
	$(RM) -f checkdiff/checkdiff.new

	$(GMAKE) catalog_build
	$(GMAKE) exceptions_build

	$(GMAKE) check_repo
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_repo supplier=cisco-ios
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	$(GMAKE) check_repo JSON=no
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_repo JSON=yes
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

	$(GMAKE) delete_audit audit=client1_skffqsfqhsf10948494
	$(GMAKE) create_audit audit=client1_skffqsfqhsf10948494
	$(GMAKE) sync_run audit=client1_skffqsfqhsf10948494
	$(GMAKE) check_run audit=client1_skffqsfqhsf10948494
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_run audit=client1_skffqsfqhsf10948494 supplier=cisco-ios
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	$(GMAKE) delete_audit audit=client2_mqsdhqndqqos198440
	$(GMAKE) create_audit audit=client2_mqsdhqndqqos198440
	$(GMAKE) check_run audit=client2_mqsdhqndqqos198440
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_run audit=client2_mqsdhqndqqos198440 supplier=cisco-ios
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	
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
	$(GMAKE) delete_audit audit=client2_mqsdhqndqqos198440
	$(GMAKE) restore_run_audit file=backup/run_audit_$(shell date +%Y-%m-%d).tar.gz
	
	$(GMAKE) check_run audit=client1_skffqsfqhsf10948494
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_run audit=client1_skffqsfqhsf10948494 supplier=cisco-ios
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	$(GMAKE) clean
	$(GMAKE) delete_audit audit=client1_skffqsfqhsf10948494
	$(GMAKE) delete_audit audit=client2_mqsdhqndqqos198440
	$(GMAKE) restore_run_audit file=backup/run_audit_client1_skffqsfqhsf10948494_$(shell date +%Y-%m-%d).tar.gz

	$(GMAKE) check_run audit=client1_skffqsfqhsf10948494
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new
	$(GMAKE) check_run audit=client1_skffqsfqhsf10948494 supplier=cisco-ios
	cat reports/*/*.csv | wc -l >> checkdiff/checkdiff.new

	$(GMAKE) clean
	$(GMAKE) delete_audit audit=client1_skffqsfqhsf10948494
	$(GMAKE) delete_audit audit=client2_mqsdhqndqqos198440

	$(GMAKE) create_audit audit=client1_skffqsfqhsf10948494
	$(RM) -r -f confs/run*client1_skffqsfqhsf10948494/*cisco-ios* tests/run*client1_skffqsfqhsf10948494/*cisco-ios* || true
	$(GMAKE) check_run audit=client1_skffqsfqhsf10948494 JSON=no
	$(GMAKE) check_run audit=client1_skffqsfqhsf10948494 JSON=yes
	$(GMAKE) check_run audit=client1_skffqsfqhsf10948494 JSON=no supplier=cisco-ios
	$(GMAKE) check_run audit=client1_skffqsfqhsf10948494 JSON=yes supplier=cisco-ios
	$(GMAKE) delete_audit audit=client1_skffqsfqhsf10948494
	$(GMAKE) clean clean_force FORCE=yes

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


