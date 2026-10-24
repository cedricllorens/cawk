<p align="left"><img src="docs/logo/logo-cawk-pro.svg" width="200" alt="cawk"></p>

# cawk README

> **cawk is subject to an MIT open-source license**  
> Please refer to the LICENSE file for further information
> **cawk is Copyright (C) 2024-2026 by Cedric Llorens**

# cawk introduction

cawk is a network configuration compliance checker and censor.

cawk's objective is to provide the community with a complete list of tests for checking 
network configurations across all suppliers. Moreover, cawk is ONLY based on 3 well-known
packages: 
- gnu m4 aka m4
- gnu make aka gmake
- gnu awk aka gawk

These packages are very powerful today and the cawk project intends to ONLY use these
packages. No other languages, no databases, no configure, etc. cawk tries to keep things 
simple and understandable for everyone. The package size is very small while maintaining 
powerful capabilities.

All developers and AIs can help to build new tests because Cawk relies on well-known languages,
making development and maintenance easier. cawk is now managed by Claude Code, enabling efficient
development workflows and AI-assisted enhancements while maintaining code quality and consistency.

You can work with two predefined assessments <repo> and <run> included in the cawk package, but
you can create/delete as many different assessments as you want <run_{audit_name}> based on 
your own different networks or customers.

In summary, in gawk && gmake && m4 we trust :-)

# cawk workflow

this chapter explains, step by step and with no prior knowledge, how cawk goes from "my network
configurations sit on a central server" to "I have an audit report". read it once from top to
bottom, then use it as a checklist. every step says WHAT it does, WHY it exists, the COMMAND to
type, WHERE the result lands and how to CHECK it worked.

## the words used in this chapter

	- conf          : the text file holding the configuration of ONE device (a router, a switch, a firewall...).
	                  the file is named after the device (i.e. cisco-ios1).
	- supplier      : the vendor/os of a conf (cisco-ios, juniper-junos, fortinet-fortios...). cawk detects it
	                  by reading the conf. tests are written per supplier.
	- test          : a small gawk program checking ONE rule on the confs of ONE supplier (i.e. "SNMP default
	                  community must not exist"). tests live in tests/.
	- exception     : a documented decision to accept a finding (who approved it, when, why). exceptions live
	                  in exceptions/ and are applied when the report is built.
	- audit         : a named, isolated workspace (audit=client1) with its own tests, confs, exceptions and
	                  reports. you create one audit per customer or per network, so nothing is mixed.
	- central system: a unix/linux server where the confs are stored (a backup server, a config archive...).
	                  cawk only needs to READ it.
	- collector     : an optional cawk script that copies the confs from the central system to cawk (scp, rsync or a local cp).
	- sync          : the cawk step that detects the supplier of every conf and places it in the right folder
	                  of the audit.

## the big picture

	  +---------------------------+
	  |      CENTRAL SYSTEM       |   a unix/linux server, ONE FILE PER DEVICE (i.e. /srv/confs/)
	  |   (cawk only reads it)    |
	  +-------------+-------------+
	                |
	                |  scp or rsync over ssh, with a key
	                |  [1] COLLECT   gmake collect_run audit=client1        (optional)
	                v
	  +---------------------------+
	  | confs/collect_client1/    |   raw copies of the confs   (they contain secrets)
	  +-------------+-------------+
	                |
	                |  detect the supplier of each conf, build soft links
	                |  [2] SYNC      gmake sync_run audit=client1
	                v
	  +------------------------------------------------+
	  | confs/run_client1/                             |
	  |    confs.cisco-ios/        cisco-ios1 ...      |   confs sorted by supplier
	  |    confs.juniper-junos/    junos1 ...          |
	  |    confs.fortinet-fortios/ forti1 ...          |
	  +-------------+----------------------------------+
	                |
	                |  [3] ALIGN     gmake sync_teststoconfs_run audit=client1
	                |                gmake sync_exceptionstoconfs_run audit=client1
	                |                (keep only the tests and exceptions of suppliers that have confs)
	                v
	  +---------------------------+        +----------------------------+
	  | tests/run_client1/        |        | exceptions/run_client1/    |
	  +-------------+-------------+        +--------------+-------------+
	                |                                     |
	                +------------------+------------------+
	                                   |
	                                   v
	  +----------------------------------------------------+
	  | [4] AUDIT      gmake check_run audit=client1       |
	  |     every test is applied to every conf            |
	  |     of the same supplier, exceptions are applied   |
	  +--------------------------+-------------------------+
	                             |
	                             v
	  +----------------------------------------------------+
	  | reports/run_client1/   one line per check:         |
	  |    pass | error | warning | psirt                  |
	  +--------+------------------+------------------+-----+
	           |                  |                  |
	           v                  v                  v
	     [5] READ            [6] SHARE           [7] KEEP
	     gmake view_run      gmake email_send    gmake backup_run
	     audit=client1       audit=client1       audit=client1
	           |
	           v
	  +-----------------------------------------------------+
	  | [8] HTML REPORT  gmake check_run audit=client1      |
	  |     HTML=yes  ->  assessment.all.summary.html       |
	  |     one standalone page, counters only, for the     |
	  |     customer                                        |
	  +-----------------------------------------------------+

	rule of thumb : [1] and [2] bring the confs in, [3] and [4] judge them, [5] to [7] use the verdict,
	[8] is the final high-level deliverable (optional, built by step 4 with HTML=yes, described in step 8).
	[1] is optional: if the confs already reach cawk another way (a mounted directory, a copy by hand
	into confs/run_client1/confs.<supplier>/), start at [2] or even at [4].

	where the files live, once an audit client1 exists (everything is under the cawk root directory):

	  cawk/
	   +-- tests/       run_client1/  tests.cisco-ios/ tests.juniper-junos/ ...      <- the rules
	   +-- exceptions/  run_client1/  exceptions.cisco-ios.m4 ...                    <- accepted findings
	   +-- confs/       collect_client1/   raw confs from the central system         <- step 1
	   |                run_client1/       confs.<supplier>/<device>                 <- step 2
	   +-- reports/     run_client1/       the assessment, archives/ holds old ones  <- step 4
	   +-- logs/        run_client1/       collect.client1.err ...                   <- when something fails
	   +-- database/    db_collect.txt db_sync.txt db_email.txt db_postaudit.txt      <- how each audit behaves
	   +-- backup/      run_audit_client1_<date>.tar.gz                               <- step 7

## step 0 : create the audit (once)

	WHAT   : creates the workspace of the audit and fills it with a full copy of the cawk tests, exceptions
	         and demo confs, plus one default line in each database (collect, sync, email, post-audit).
	WHY    : each audit must be independent. you can remove tests or confs of this audit without touching
	         the others or the original repository (repo).
	COMMAND: gmake create_audit audit=client1
	WHERE  : tests/run_client1/ confs/run_client1/ exceptions/run_client1/ reports/run_client1/
	CHECK  : gmake list_audit   (client1 is listed)
	NOTE   : the copied demo confs are only samples. step 2 (sync) removes the local confs of the audit and
	         replaces them with yours.

## step 1 : collect the confs from the central system (optional)

	WHAT   : copies the confs from the central unix/linux system into cawk with scp or rsync, using an
	         ssh key (never a password). the copy is automatic: you only describe WHERE the confs are.
	WHY    : cawk must not work directly on the live central repository, and it needs a local copy.
	         the copy is the only moment cawk touches the central system, and it only reads it.
	THE DRAWING:

	   cawk machine                                        central system (192.0.2.10)
	  +--------------------------------+   ssh key     +-----------------------------+
	  | scp.collector.sh               | ------------> | account  cawk               |
	  |  (or rsync.collector.sh)       |  host= user=  | directory /srv/confs/       |
	  |  arguments read from           |  key= port=   |    cisco-ios1               |
	  |  database/db_collect.txt:      |               |    junos1                   |
	  |  client1 scp host=192.0.2.10,..| <------------ |    forti1                   |
	  +----------------+---------------+  files copied +-----------------------------+
	                   |                  (read only)
	                   v
	      confs/collect_client1/cisco-ios1  junos1  forti1

	WHAT YOU NEED BEFORE:
	         - the address (host=) of the central system, an IP address or a name
	         - an account (user=) allowed to read the confs, with an ssh key (key=)
	         - the directory (remote_path=) holding ONE FILE PER DEVICE, i.e. /srv/confs/
	         - the central system host key known by the cawk machine (ssh once by hand, or hostkey=accept-new)
	COMMANDS (declare the collector once, then run it):
	         gmake database_collect_add audit=client1 collector=scp \
	               args=host=192.0.2.10,user=cawk,remote_path=/srv/confs/,key=/home/cawk/.ssh/id_ed25519 sync=yes
	         gmake collect_run audit=client1
	         (collector=rsync works the same way, collector=local args=source_path=/srv/confs/ copies from a directory of the cawk machine; sync=yes also declares the folder in the sync database,
	          see step 2)
	WHERE  : confs/collect_client1/ (one file per device, named after the device)
	CHECK  : ls -l confs/collect_client1   (one file per device, the modification time of the original is kept)
	         a failure keeps the previous files, prints a "cawk error" and returns an error code.
	WARNING: these raw confs contain secrets. they are not saved by backup_run, not removed by gmake clean,
	         and removed by delete_audit. use the censor step (step 7) before sharing them.
	see also : "cawk collect audit=AUDIT_NAME assessment" for every argument (port=, timeout=, options=...).

## step 2 : sync = detect the supplier of every conf and sort them

	WHAT   : reads every conf of the sync paths, detects its supplier (cisco-ios, juniper-junos...), and
	         creates a soft link in confs/run_client1/confs.<supplier>/ for each of them.
	WHY    : the tests are written per supplier. cawk must know which tests apply to which conf, and it
	         cannot guess it from the file name. the sync also lets you choose which devices are audited
	         (scope file and regular expressions of the sync database).
	THE DRAWING (the CONTENT of a conf tells its supplier, not its file name):

	  confs/collect_client1/               confs/run_client1/
	  +--------------------+  read it     +---------------------------------------+
	  | cisco-ios1         | -----------> | confs.cisco-ios/cisco-ios1  (link)    |
	  | junos1             | -----------> | confs.juniper-junos/junos1  (link)    |
	  | forti1             | -----------> | confs.fortinet-fortios/forti1 (link)  |
	  +--------------------+  detect os   +---------------------------------------+
	                          + filters of the sync database: which devices, which suppliers, which paths

	COMMANDS:
	         gmake database_sync_update audit=client1 dir=../collect_client1/ regexinventory=.* scope=none \
	               regexos=.* regexpathexclude=none regexinventoryexclude=none
	               (not needed if you used sync=yes at step 1: it already wrote dir=../collect_client1/)
	         gmake sync_run audit=client1
	         shortcut : gmake sync_run audit=client1 COLLECT=yes   (runs step 1 then step 2 in one command)
	WHERE  : confs/run_client1/confs.<supplier>/<device>  (soft links to confs/collect_client1/<device>)
	CHECK  : ls -l confs/run_client1/confs.*/   (each device sits in the folder of its supplier)
	WARNING: the local confs of the audit are REMOVED and rebuilt at each sync_run: never edit a conf
	         inside confs/run_client1, edit it at its source.

## step 3 : align tests and exceptions with the confs you really have (recommended)

	WHAT   : keeps only the tests and exceptions of the suppliers that have at least one conf in the audit.
	         the others are not deleted: their folder is renamed zz.sync.save.<name> (audit trail).
	WHY    : you do not want to run 16 suppliers of tests when your network only holds 3 of them, and the
	         report should only talk about what you have.
	THE DRAWING (this audit holds confs of 2 suppliers only):

	  tests/run_client1/ BEFORE                tests/run_client1/ AFTER
	  +-----------------------------+          +-----------------------------------------+
	  | tests.cisco-ios/            |   kept   | tests.cisco-ios/                        |
	  | tests.juniper-junos/        |   kept   | tests.juniper-junos/                    |
	  | tests.nokia-sros/           | -------> | zz.sync.save.* (nokia-sros: no conf,    |
	  | tests.paloalto-panos/       | renamed  |  folder kept for the audit trail)       |
	  +-----------------------------+          +-----------------------------------------+

	COMMANDS: gmake sync_teststoconfs_run audit=client1
	          gmake sync_exceptionstoconfs_run audit=client1
	WHERE  : tests/run_client1/ and exceptions/run_client1/ (orphan folders renamed zz.sync.save.*)
	CHECK  : ls tests/run_client1   (only your suppliers remain active)
	UNDO   : gmake tests_run_copy audit=client1 copies the tests from repo again.
	PSIRT  : to also run the vulnerability (psirt) tests, describe your devices (os version, chassis...)
	         in database/psirt_scopes/psirt_os_inventory_scope.txt, i.e. with gmake sync_psirt.

## step 4 : run the audit

	WHAT   : applies every test of the audit to every conf of the same supplier and writes the results.
	         in order, cawk: compiles the tests (templates -> .gawk) and the exceptions, scans the confs
	         for obvious problems (windows line endings, wrong first-level indentation, files older
	         than a threshold), runs each test on each conf, applies the exceptions, builds the reports
	         and archives the previous ones.
	WHY    : this is the audit itself, the moment where each conf is compared with the rules.
	THE DRAWING (what happens inside gmake check_run audit=client1):

	  +--> [a] compile      tests (*.gawk.template / .m4 / .include -> *.gawk) and exceptions (*.m4)
	  |
	  +--> [b] pre-scan     each conf: windows line endings (CRLF)?  wrong first-level indentation?
	  |                     older than DEADBEEF_THRESHOLD_DAYS (if DEADBEEF=yes)?
	  |
	  +--> [c] run          for each supplier --> for each conf --> for each test --> one result line
	  |
	  +--> [d] exceptions   findings that have a documented exception are marked accordingly
	  |
	  +--> [e] report       reports/run_client1/ written, the previous reports go to archives/

	COMMAND: gmake check_run audit=client1
	         gmake check_run audit=client1 supplier=cisco-ios   (one supplier only)
	         useful options added to the command line:
	           PSIRT_ONLY=yes      run only the vulnerability tests (STANDARD_ONLY=yes: only the standard ones)
	           DEADBEEF=yes        flag confs not updated for DEADBEEF_THRESHOLD_DAYS days (default 30)
	           JSON=yes            also write the reports in json
	           TIMELINE=no         skip the timeline reports (default yes: timeline reports written, the csv they are built from kept)
	           HTML=yes            also write assessment.all.summary.html: one standalone high-level page (counters only, no config line) for the customer, with the cawk logo (LOGO_HTML, default docs/logo/logo-cawk.svg) in its header
	           MAKE_PARALLEL=yes   spread the tests on several jobs for big audits
	         other options (defaults in support/Makefile.support.mk): HTML defaults to yes, CATALOG_BUILD=yes
	         rebuilds the test catalog (db_info.txt) before the assessment (default no), TMP_ASSESSMENT_FILES=no
	         keeps the intermediate assessment files (default yes: removed after reporting), ARCHIVE_OLDER_DAYS=N
	         archives the reports older than N days during the cleanup (default 120)
	WHERE  : reports/run_client1/ (previous reports are archived in reports/run_client1/archives/)
	CHECK  : the command ends without "cawk error"; the reports files exist.

## step 5 : read the result

	WHAT   : displays the reports. each line has the same fields:
	             conf_name | test_name | error_line | line_nb | risk_level | status_code
	         i.e. "cisco-ios1 | snmp_community_notset | snmp-server community public RO | 12 | high | error"

	  cisco-ios1 | snmp_community_notset | snmp-server community public RO | 12 | high | error
	  ^            ^                       ^                                  ^    ^      ^
	  |            |                       |                                  |    |      +-- status_code
	  |            |                       |                                  |    +-- risk_level
	  |            |                       |                                  +-- line_nb (line of the conf)
	  |            |                       +-- error_line (what was found)
	  |            +-- test_name (which rule)
	  +-- conf_name (which device)
	WHY    : to know what to fix, and how urgent it is.
	HOW TO READ IT:
	         - status_code : pass (rule respected), error (rule broken), warning (acceptable but to watch),
	                         psirt (a psirt test result: high = vulnerable, low = version in scope but not exposed,
	                         info = not vulnerable, medium = skipped for lack of information)
	         - risk_level  : high, medium, low, info (info = information for the auditor, not a failure)
	         - line_nb     : the line of the conf that triggered the finding, to find it quickly
	COMMANDS: gmake view_run audit=client1            (everything)
	          gmake view_run_error audit=client1      (errors only: start here)
	          gmake view_run audit=client1 supplier=cisco-ios
	THEN   : fix the conf at its source, or, if the finding is accepted on purpose, document it as an exception
	         (exceptions/run_client1/exceptions.<supplier>.m4: approver, date, reason). run steps 1, 2 and 4
	         again: a clean report proves the fix.

## step 6 : share the result (optional)

	WHAT   : emails the reports as a zip file to the people registered for the audit, then runs your own
	         post-audit script (i.e. to open helpdesk tickets).
	COMMANDS: gmake database_email_add audit=client1 dst=john@example.com,jane@example.com cc=none
	          gmake email_send audit=client1
	          gmake database_postaudit_add audit=client1
	          gmake postaudit_run audit=client1   (runs database/scripts/database_postaudit.script if it exists)
	NEEDS  : the mutt and zip commands installed on the cawk machine (the only prerequisite besides gawk, gmake, m4).
	WARNING: the reports name devices and findings: send them only to people allowed to see them.

## step 7 : censor, back up, clean (optional)

	- censor  : gmake censor_run audit=client1
	            writes a copy of the confs with the secrets (passwords, keys, snmp communities...) replaced by
	            CENSORED into confs/run_client1/confs.<supplier>.censored (add CENSOR_LEVEL=external to also hide
	            hostnames and ip addresses). send the censored copy, never the raw one, when you share a conf.
	            the reports hold conf lines too : gmake censor_report_run audit=client1 writes their censored
	            copy into reports/run_client1.censored, gmake censor_logs_run audit=client1 the same for the
	            logs ; gmake censor_check in=<file or dir> fails while a secret is still there (the guard before
	            sharing), gmake censor_file in=<file> out=<file> censors one file into one file and
	            gmake censor_stdout in=<file> to the standard output.
	- backup  : gmake backup_run audit=client1   -> backup/run_audit_client1_<date>.tar.gz (tests, exceptions, confs,
	            reports of the audit). restore with gmake restore_run audit=client1 file=<the backup>.
	- clean   : gmake clean_report_run audit=client1 removes the reports, gmake clean_archive_run audit=client1
	            the archives, gmake delete_audit audit=client1 removes the whole audit.

## step 8 : final HTML report for the customer (optional)

	WHAT   : one standalone page, assessment.all.summary.html, with the high-level counters of the audit by risk
	         level, supplier, NIST 800-53 control and test. no conf name, no error line: nothing sensitive.
	WHY    : the text reports name devices and findings; the HTML page is the safe summary to show or send
	         to a customer or a manager.
	COMMAND: gmake check_run audit=client1 HTML=yes
	         (the page is built at the end of step 4, from the final assessment.all.csv)
	WHERE  : reports/run_client1/assessment.all.summary.html (open it in any browser, no server needed)
	CHECK  : ls reports/run_client1/assessment.all.summary.html

## the same workflow, every day, for all the audits

	once the audits exist and their collector, sync, email databases are set, one run per day is just:

	gmake collect_run_audit            # 1. fetch the confs of every audit that has a collector
	gmake sync_run_audit               # 2. sort them by supplier
	gmake sync_teststoconfs_run_audit  # 3. keep the useful tests ...
	gmake sync_exceptionstoconfs_run_audit   #    ... and exceptions
	gmake check_run_audit HTML=yes     # 4. audit them all (+ final html summary of each audit)
	gmake email_send_audit             # 5. email the reports
	gmake postaudit_run_audit          # 6. run the post-audit scripts

	put these lines in a script launched by cron and the compliance report arrives by itself.

## if something goes wrong

	- "cawk error" after step 1 : read logs/run_client1/collect.client1.err (wrong key, unreachable host, unknown
	  host key, empty remote directory). the previous confs are kept, nothing is lost.
	- empty report or missing devices : run ls confs/run_client1/confs.*/ ; a device missing there was filtered by the
	  sync database (regexinventory, scope, regexpathexclude) or its supplier was not detected.
	- a supplier has no results : its tests were renamed zz.sync.save.* at step 3 because no conf was found for it.
	- results look wrong on windows-format confs : the CRLF scan excludes them from the reports on purpose
	  (CRLF=yes by default), fix the line endings at the source.
	- start again cleanly : gmake clean_report_run audit=client1, then repeat from the failing step.

# cawk check

Before installing the application, extract it to a temporary directory and launch <gmake check>.
A full set of tests will be performed and a hash computed to ensure the distribution has not been
altered

# cawk installation

## manually

jump to a specific directory and extract cawk, cd to cawk root directory and execute the <gmake> 
command in order to have help on the cawk gmake targets. 

## Makefile.cawk.version

The Makefile.cawk.version file provides installation and version management targets:

	- install - First time installation of cawk
		- required: `CAWK_VERSION=x.y.y`
	- reinstall - Reinstall current cawk version with audit backup and restore
		- required: `CAWK_VERSION=x.y.y`
	- update - Install new cawk version with automatic backup and restore from previous version
		- required: `CAWK_VERSION=x.y.y CAWK_NEXT_VERSION=x.y.y`

	note: This Makefile must be located in the parent directory of cawk installations.

important note : you may have to change the file support/tests.sed for finding the gawk path at your
system level required for building tests:
	-%SED_GAWK_PATH% must point out the right path for gawk
	( we set <!/usr/bin/env -S gawk -f> for a generic finding )

# cawk gmake targets

just execute <gmake> in the cawk root directory and all the cawk targets are detailed

# cawk gmake parallel

in standard mode, cawk performs assessment not in parallel mode. to use parallel mode,
you have to modify the Makefile.support.mk file thanks to these gmake VARS:

	# --------------- cawk parallel options
	# enable parallel yes/no
	MAKE_PARALLEL = yes
	# number of files to process per target (all targets are processed in parallel)
	MAKE_FILES_PER_TARGET = 100
	# number of psirt test config files per target (default 1)
	MAKE_FILES_PER_TARGET_PSIRT = 1
	# safety ceiling of both values (default 2000, ARG_MAX): check_supplier refuses a value out of [1,2000]
	MAKE_FILES_PER_TARGET_MAX = 2000

	# --------------- gmake parallel options
	# gmake number of jobs
	MAKE_J = 4
	# gmake load average
	MAKE_LOAD_AVG = 3

once cawk parallel mode is enabled, before performing assessment, cawk build one Makefile
per os in tmp directory. once done, it performs each Makefile in parallel mode to offer 
enhanced performances for a huge set of files.

# cawk first use

after install, cd to the cawk root directory, execute:

	- gmake version : provide the cawk version release
	
	- gmake : provide all cawk gmake targets

	- gmake clean check_repo view_repo : it applies the test repo to conf repo 
	and see results, you may check reports/repo assessment files 

	- gmake clean check_run view_run : it applies the test run to conf run and 
	see results, you may check reports/run assessment files

	-- audit=AUDIT_NAME assessment --

## audit create (create_audit)

	- gmake create_audit audit=client1
	  Create full audit: copies all tests, exceptions, and confs from repo.
	  You may then remove or add tests, confs as needed for your assessment.

	- gmake create_audit audit=client1 supplier=cisco-ios
	  Add supplier to existing audit: copies only the specified supplier's tests,
	  exceptions, and confs into an existing audit. Does not modify databases.
	  Useful for incrementally building up an audit with specific suppliers.

## audit execution

    - gmake check_run audit=client1 : applies tests/run_client1 to confs/run_client1
	(you may also check reports/run_client1 assessment files)

    - gmake check_run view_run audit=client1 : applies tests/run_client1 to
	confs/run_client1 and displays results
	(you may also check reports/run_client1 assessment files)

    - gmake check_run view_run audit=client1 supplier=cisco-ios : same as previous
	but only for cisco-ios configurations

## audit delete (delete_audit)

	- gmake delete_audit audit=client1
	  Delete full audit: removes all tests, exceptions, confs, reports, logs,
	  and audit entries from databases.

	- gmake delete_audit audit=client1 supplier=cisco-ios
	  Remove supplier from audit: removes only the specified supplier's tests,
	  exceptions, and confs from an existing audit. Does not modify databases.
	  Useful for removing specific suppliers from an audit.

## audit listing

	- gmake list_audit : list all AUDIT_NAMEs (audit=AUDIT_NAME)
	- gmake check_run_audit : run assessments for all AUDIT_NAMEs

# cawk directories

cawk has the following core directories:

- checkdiff : contains a cawk compliance print to compare when running <gmake check>, 
to be launched only after the first installation

- common : contains a <kind of library> (set of functions) included in the tests and 
others common useful scripts

- m4 : contains a <kind of m4 libraries> (set of m4 functions) that may be used at 
exceptions or tests level

- database : contains all the flat files databases used to manage various cawk options like sync
confs, sending emails, etc.

- database/scripts : contains scripts used for various usages as described : generally it requires the
use of the internal inventory

	- each time sync_run audit=AUDIT_NAME target is called, database_sync.script is launched
	allowing to update device scope files. these file scopes are/must be stored in database/sync_scopes with
	the name audit(=AUDIT_NAME)_inventory_sync_scope.txt
	
- database/sync_scopes : sync scopes files generated by the scripts described above. It could be useful
	to define various sub-assessments for a as same audit=AUDIT_NAME like
		- audit_network_part1 assessment with scope associated to
		- audit_network_part2 assessment with scope associated to
		- etc.

	- post_audit : can be used by post_audit target process if needed

- tests : contains a collection of individual tests <*.gawk.template> or <*.gawk.m4> or 
<*.gawk.include> per supplier :

	- there are 3 types of core tests directories:
		- tests/repo : contains the full collection of cawk coded tests, that can be used in 
		tests/run or tests/run_{audit_name} directories
		- tests/run  : a full copy of repo by default (you may copy tests from tests/repo 
		or add your own tests)
		-- audit=AUDIT_NAME assessment --
		- tests/run_{audit_name} : contains a full copy of repo tests when created (you can 
		remove or add other tests or add your own tests)
		- tests/run_{audit_name}.psirt : contains a full copy of repo psirt tests when created 
		(you can remove or add other tests or add your own tests)
		-- audit=AUDIT_NAME assessment --

	- inside each core tests directories, you have a full set of tests supplier directories

	- a test has <.template> suffix or <.m4> suffix or <.include> suffix, but the test is 
	converted to <.gawk> with the 	support of support/tests.sed and the cawk root Makefile. 
	this <step> allows to write tests more 	easily and to enforce env system portability, so 
	each test may to %SED_VAR% aka:
		- %SED_BLOCK_JUNIPER% : space identation used for block hierarchy
		- %SED_COMMON_PATH% = to point out the common <kind of library>
		- %SED_GAWK_PATH% = to point out the right path for gawk 
		etc.
		these values can be changed thanks to the file support/tests.sed

		moreover, a cawk m4 parse block macro allows to parse any type configuration without 
		managing the block hierarchy level as it is automatically generated by the macro when 
		the <.gawk> is generated

## Supported Suppliers

cawk organizes all tests, configurations, and exceptions by supplier (network platform). Current scope:

`cisco-ios`, `cisco-xr`, `cisco-xe`, `cisco-cedge`, `cisco-viptela`, `cisco-sdnios`, `juniper-junos`, `huawei-vrp`, `fortinet-fortios`, `nokia-sros`, `paloalto-panos`, `checkpoint-fwcli`, `packetfilter-fwcli`, `iptables-fwcli`, `6wind-linux`, `ekinops-oneos`

Each supplier is organized in per-directory format:
- `tests/repo/tests.cisco-ios/` — Tests for Cisco IOS
- `confs/repo/confs.cisco-ios/` — Reference configurations for Cisco IOS
- `exceptions/repo/exceptions.cisco-ios.m4` — Exception rules for Cisco IOS
- And similarly for all other supported suppliers

- confs : contains a collection of configurations per supplier

	- there are 3 types of core confs directories:
		- confs/repo : contains a collection of cawk tests confs
		- confs/run : a full copy of repo by default (you may copy configurations from confs/repo 
		or add your own configurations)
		-- audit=AUDIT_NAME assessment --
		- confs/run_{audit_name} : a full copy of repo confs when created (you can remove or 
		add other configurations)
		-- audit=AUDIT_NAME assessment --

	- inside each core conf directories, you have a full set of configuration supplier directories

	- inside each core conf directories, you have a sync directory allowing to sync confs with a
	  central repository, please refer to the cawk sync section for further information

- exceptions : contains a collection of exceptions per supplier applied for reporting

	- there are 3 types of core exceptions directories:
		- exceptions/repo : contains a collection of up-and-running exceptions
		- exceptions/run : contains a collection of up-and-running exceptions (a full copy of repo)
		-- audit=AUDIT_NAME assessment --
		- exceptions/run_{audit_name} : contains a full copy of repo exceptions when created
		-- audit=AUDIT_NAME assessment --

	- inside each core exception directories, you have a full set of exception supplier files

- logs : to store all the cawk logs if needed

- reports : contains assessment reports (and summary), each report has the same format

	- there are 3 types of core report directories:
		- report/repo : empty by default, contains the repo assessment results
		- report/run : empty by default, contains the run assessment results
		-- audit=AUDIT_NAME assessment --
		- report/run_{audit_name} : empty by default, contains the run_{audit_name} assessment results
		-- audit=AUDIT_NAME assessment --

	- each of these directories has a sub-directory <archives>. each time an asessment is performed
	  a tar.gz file is built and stored in this directory including the date in filename 
	  (please refer to cawk assessment format for further information)

	- there are intermediary reports and final reports, the intermediary reports are generated for each supplier
	  and the final reports have the substrings (.all(.security./.audit./.psirt./.exception./.deadbeef./.badformat./.crlf.))
	
	- for all the final reports (.all.security., .all.audit., .all.psirt., .all.exception., .all.deadbeef., .all.badformat. and .all.crlf.), a timeline 
	  report is also generated in order to be injected into microsoft powerbi, grafana, etc. as it includes a 
	  timestamp for each error modifying the line format (day, month, year, week, number of devices assessed)
	  (please refer to cawk assessment format for further information)

	- for the final reports, the concept of deadbeef that can be also activated in Makefile.support.mk or by 
	  calling gmake with DEADBEEF like (gmake check_run audit=cawk DEADBEEF=yes):
		- if DEADBEEF is set to "yes", then the deadbeef final report is generated and the deadbeef devices 
		  are removed from the others final reports (.all.security.,.all.audit.,.all.psirt.,all.exception.)
		- if DEADBEEF is set to "no", then the deadbeef final report is generated and the deadbeef devices 
		  are kept in the others final reports (.all.security.,.all.audit.,.all.psirt.,all.exception.)
		- a device is considered by default as deadbeef if the configuration is older than the days value 
		set in DEADBEEF_THRESHOLD_DAYS  (default value is 30 days)

# cawk Configuration Variables

cawk uses two synchronized configuration sources for directory paths:

1. **`support/Makefile.support.mk`** — Make/gmake configuration for build system and assessment targets
2. **`database/include/scripts_config.sh`** — POSIX shell configuration for database and post-audit scripts

Both files define identical path variables to ensure consistency across Make targets and shell scripts. When modifying any path, **both files must be updated together** to prevent silent failures or operations on wrong directories.

## Core Path Variables

The following variables are defined in both configuration files:

- `CONFS_PATH` — Configuration directory (confs)
- `COMMON_PATH` — Common AWK libraries (common)
- `BACKUP_PATH` — Backup archives (backup)
- `DATABASE_PATH` — Flat-file databases (database)
- `COLLECTORS_PATH` — Optional configuration collectors (database/collectors)
- `LOGS_PATH` — Execution-result logs (logs): `test_exec.*`, `gen_makefile.*`/`gen_makefile_psirt.*`, `parallel_gmake.*`/`parallel_gmake_psirt.*`, `deadbeef.*`, `catalog_precompute.*`, `backup.*`, `restore.*`, `email.*`, `sync.*`/`sync_psirt.*`, `collect.*`, `postaudit.*`, `archive.*`; each `<name>.<scope|audit>.err` file captures stderr for that operation, paired with a `cawk error:` message on failure. Persists across runs (not touched by `gmake clean`/`clean_tmp`), purged only via `gmake clean_logs` (all scopes), or per-scope via `gmake clean_logs_repo`, `gmake clean_logs_run` (or `audit=AUDIT_NAME`), `gmake clean_logs_run_audit` (all audits)
- `REPORT_PATH` — Generated reports (reports)
- `EXCEPTION_PATH` — Exception rules (exceptions)
- `TESTS_PATH` — Test templates (tests)
- `TESTS_COMMON_PATH` — Common test libraries (common)
- `TESTS_SYSTEM` — System test configurations (system)
- `TESTS_TMP` — Temporary test files (tmp)

## Scripts Configuration File

`database/include/scripts_config.sh` is a POSIX-compatible shell include file for use in database scripts:

```bash
. database/include/scripts_config.sh
echo "${DATABASE_PATH}"          # Access variables
get_database_scripts              # Get list of database scripts
get_test_common_templates         # Get list of test templates
```

Helper functions in the script provide POSIX-compatible alternatives to Make's `$(wildcard ...)`:

- `get_database_scripts()` — Lists all database/*.script.sh files
- `get_test_common_templates()` — Lists all common/*.template files
- `get_test_common_scripts()` — Lists all common/*.script.sh files

## Enforcement Rule

Refer to docs/CAWK_CODE_RULES.md section **"Configuration Variables: Make ↔ Shell Consistency"** for the mandatory enforcement procedure when modifying configuration variables. This ensures that Make targets and shell scripts always operate on the correct directories.

## SECRETSCAN Concept

The csv reports hold the configuration line of every finding (the `error_line` column), so they can hold secrets. With **SECRETSCAN=yes** the final reports are censored at the end of `check_repo`/`check_run` with the regexes of `database/censor/censor_regex.m4` (level `CENSOR_LEVEL`, `internal` by default):

1. every `assessment.*.csv` is rewritten into `assessment.*.censored.csv`, only the `error_line` column is censored, the 6 columns of the format are kept
2. the original `assessment.*.csv` are removed
3. the timeline (`assessment.all.*.timeline.censored.csv`) and json (`assessment.all.*.censored.json`) reports are built from the censored csv; `view_*` and the email export read them too
4. `assessment.all.summary.txt`, `.json` and `.html` only hold counters and are unchanged

`SECRETSCAN=no` (default) leaves the reports as they are. The `check_repo`/`check_run` output tells whether the filter is activated.

```bash
gmake check_run audit=AUDIT_NAME SECRETSCAN=yes
```

## CRLF Concept

cawk tests anchor their regexes on end of line (`$`); a configuration saved in windows format (CRLF) keeps a trailing `\r` on every line, so those regexes no longer match and the results are wrong. Every assessment therefore scans each configuration with `common/crlf_cawk_conf.gawk`, modeled on deadbeef/badformat: each configuration in windows format produces one `info;error` line in `assessment.all.crlf.csv` (and `assessment.all.crlf.timeline.csv`), and the summary reports `number_of_confs_crlf`.

Unlike deadbeef and badformat, the filter is **forced to yes by default** (`CRLF ?= yes`), since the results of a CRLF configuration are wrong, not just doubtful:

1. **CRLF=yes** (default) — crlf configurations are removed from the final reports (`.all.csv`, `.all.security.`, `.all.audit.`, `.all.psirt.`)
2. **CRLF=no** — crlf configurations stay in all reports; the crlf report is still produced

```bash
gmake check_run audit=AUDIT_NAME CRLF=no
```

A test fixture is available under `validate/crlf/` (`conf_crlf`). To fix a listed file, convert it to unix format (e.g. `sed -i 's/\r$//' FILE`).

## Badformat Concept

**What is "Badformat"?**
Badformat refers to configurations with first-level indentation violations, which make block-based cawk results unreliable. Every assessment scans each configuration with `common/badformat_cawk_conf.gawk` (`info;warning`): when a column-0 line is followed by an indented line, that line's indentation becomes the block reference; until the next column-0 line, no indented line may be shallower than the reference (a tab counts as one character, blank lines are ignored). Windows format (CRLF) is not part of badformat: see the CRLF Concept section.

Each badformat configuration produces one line in `assessment.all.badformat.csv` (and `assessment.all.badformat.timeline.csv`); the summary reports `number_of_confs_badformat`.

**Two Operating Modes (same as deadbeef):**

1. **BADFORMAT=yes** — badformat configurations are removed from the final reports (`.all.csv`, `.all.security.`, `.all.audit.`, `.all.psirt.`)
2. **BADFORMAT=no** (default) — badformat configurations stay in all reports; the badformat report is still produced

```bash
gmake check_run audit=AUDIT_NAME BADFORMAT=yes
```

Test fixtures are available under `validate/badformat/` (`conf_ok`, `conf_ko`).

## Deadbeef Concept Clarification

**What is "Deadbeef"?**
Deadbeef refers to configurations that are "stale" — not updated recently. It's a data quality control mechanism to identify devices whose configurations may be outdated or no longer in use.

**How it Works:**
- A device's configuration is considered "deadbeef" if its modification timestamp is older than `DEADBEEF_THRESHOLD_DAYS` (default: 30 days)
- The deadbeef status is determined by file system metadata, not by cawk testing

**Two Operating Modes:**

1. **DEADBEEF=yes** (Exclude from compliance metrics)
   - Deadbeef devices are separated into their own report file (`.all.deadbeef.csv`)
   - Removed from other final reports (`.all.security.`, `.all.audit.`, `.all.psirt.`, `.all.exception.`)
   - Your compliance scores reflect only active, recently-updated devices
   - Use this when you want to know the compliance of your *current* production fleet only

2. **DEADBEEF=no** (Include in all reports)
   - Deadbeef devices appear in all final reports, including compliance metrics
   - You still get a separate deadbeef report for audit trail purposes
   - Your compliance scores include both active and stale devices
   - Use this when you want a complete inventory view including unmaintained devices

**Configuring the Threshold:**
```bash
gmake check_run DEADBEEF=yes DEADBEEF_THRESHOLD_DAYS=90
```
Set DEADBEEF_THRESHOLD_DAYS to match your maintenance cycle (e.g., 60 days for monthly maintenance, 90 days for quarterly reviews)

**Why This Matters:**
Stale configurations can artificially inflate or deflate your compliance scores. A device that hasn't been touched in 6 months shouldn't count equally with actively-maintained infrastructure. Use the deadbeef filter to separate real compliance issues from data quality issues.

- support : contains files helping for building cawk:

	- tests.sed : used when building the tests in order to make change of the set %SED_VAR%

- backup : contains tar.gz files when using cawk backup targets, please refer to the cawk backup
           section for further information

# cawk risk level && status code

cawk allows the following risk levels:
	- high   : for (high impacts) security item
	- medium : for (medium impacts) security item
	- low    : for (low impacts) security item
	- info   : for audit/information item

cawk allows the following status codes:
	- pass    : check passed successfully
	- error   : check failed or error occurred
	- warning : check passed with warning
	- psirt   : check psirt classified errors

# cawk assessment format

cawk follows an assessment report format consisting of these fields:
	---- timeline header ----
	- year
	- month
	- day
	- week
	- number of devices assessed
	---- timeline header ----
	---- generic header ---------
	conf_name: name of the configuration
	test_name: name of the test
	error_line: output describing the error
	line_nb: line number
	risk_level: high, medium, low, info
	status_code: pass, error, warning, psirt
	---- generic header ---------

# cawk security key indicators

cawk computes four key security indicators in the summary report with the following exact formulas:

## 1. Security Compliance (scope pass/error)
**Formula:**
```
security_compliance = 100 - 100 × [
  (weight_high × error_high + weight_medium × error_medium + weight_low × error_low) /
  (weight_high × (pass_high + error_high) + weight_medium × (pass_medium + error_medium) + weight_low × (pass_low + error_low))
]
```
**Where:** weight_high = 3, weight_medium = 2, weight_low = 1  
If there are no pass/error findings, the report returns `100%`.
**Range:** 0% to 100% (100% is best)  
**Interpretation:** [90,100] = excellent, [60,90) = good, [40,60) = average, [0,40) = critical

## 2. Security Info Compliance (scope pass/error - informational only)
**Formula:**
```
security_info_compliance = 100 - 100 × [error_info / (pass_info + error_info)]
```
If there are no informational pass/error findings, the report returns `100%`.
**Range:** 0% to 100% (100% is best)  
**Interpretation:** Informational only - not a compliance requirement

## 3. Average Errors Per Device (scope error)
**Formula:**
```
error_avg_perdevice = (error_high + error_medium + error_low) / number_of_devices
```
The report uses the number of assessed configuration files as `number_of_devices`.
**Range:** 0 and upward (0 is best)  
**Interpretation:** [0,1) = excellent, [1,5) = good, [5,15] = average, >15 = critical

## 4. High Risk Error Ratio (scope error)
**Formula:**
```
error_high_ratio = 100 × [error_high / (error_high + error_medium + error_low)]
```
If there are no high/medium/low errors, the report returns `0%`.
**Range:** 0% to 100% (0% is best)  
**Interpretation:** 0-10% = excellent, 10-30% = good, 30-50% = average, 50-100% = critical

## Understanding Assessment Reports

The four security indicators work together to provide a complete security posture view:

- **Use security_compliance as your primary score** — This is your overall weighted compliance percentage. It's the best single metric for executive reporting and trend analysis. The weights (high=3, medium=2, low=1) ensure that critical issues have proportional impact.

- **Use error_high_ratio to prioritize remediation** — If this ratio is high (>30%), your most critical issues dominate the problem set. Focus resources on high-severity findings first.

- **Use error_avg_perdevice to track infrastructure scale impact** — This tells you how many errors each device has on average. Excellent (<1 error/device) means isolated issues; good (1-5) means manageable scope; average (5-15) means significant issues; critical (>15) means systemic problems across configurations.

- **Use security_info_compliance separately** — Informational findings (info risk_level) are excluded from your compliance score. Track them separately; they should not inflate or deflate your compliance metrics. Use them for trend analysis and context.

**Example interpretation:** If security_compliance=72%, error_high_ratio=18%, error_avg_perdevice=3.2, this indicates good compliance with mostly medium/low issues at a manageable rate (3-4 errors per device) — no systemic critical problem, so incremental remediation is effective.

## Report Breakdown Details

Assessment reports include detailed breakdowns by risk level:

- `number_of_pass_high / number_of_pass_medium / number_of_pass_low / number_of_pass_info` — Passing checks by severity
- `number_of_error_high / number_of_error_medium / number_of_error_low / number_of_error_info` — Failing checks by severity
- `number_of_warning_high / number_of_warning_medium / ...` — Warnings by severity
- `number_of_psirt_high / number_of_psirt_medium / ...` — PSIRT findings by severity

**Other report fields:**

- `number_of_confs` — number of distinct configuration files assessed
- `number_of_confs_deadbeef` — number of configuration files flagged as deadbeef (stale)
- `number_of_checks` — total checks run across assessment, exceptions, and deadbeef files
- `number_of_checks_exceptions` — total checks run against the exceptions file
- `number_of_pass_exceptions / number_of_error_exception / number_of_warning_exception / number_of_psirt_exception` — pass/error/warning/psirt counts from the exceptions file
- `number_of_nist_pass / number_of_nist_error / number_of_nist_warning` — pass/error/warning counts restricted to checks that have a NIST 800-53 mapping
- `number_of_psirt / number_of_psirt_clear` — vulnerable PSIRT results (high risk only) / PSIRT results not affected (medium, low, info), as in the html report; the `number_of_psirt_<risk>` lines above still split all PSIRT results by risk
- `number_of_nist_psirt` — always reported as `0 (0.0%)`; PSIRT findings are not currently mapped to NIST controls

**What this tells you:**
- High pass counts indicate strong security posture in those areas
- Error distribution shows where your biggest gaps are (high errors = critical gaps, low errors = edge cases)
- Warning counts reveal configurations that pass but are suboptimal or approaching risk
- PSIRT findings track known vulnerability patterns — these should be treated with urgency if present

# cawk compliance framework indicators

cawk supports compliance framework indicators that are automatically calculated and displayed in assessment
summary reports. these indicators track compliance against recognized security standards:

## NIST 800-53 Coverage

**Overall Coverage Metric:**
- `nist_ref_coverage` = (reference NIST controls with mapped tests / total reference NIST controls) × 100%
- Displayed in summary reports with total and covered count (e.g., "nist_ref_coverage = 85.3% (201 total, 171 covered)")

**Family-Level Coverage:**
cawk tracks coverage by the 16 NIST 800-53 control families, each representing a security domain:

| Family Code | Family Name | Examples | Coverage Shows |
|-------------|------------|----------|-----------------|
| AC | Access Control | authentication, authorization, session management | user access restrictions working |
| AU | Audit and Accountability | logging, audit trails, accountability | events recorded and traceable |
| AT | Awareness and Training | security training, user education | personnel prepared for security |
| CA | Security Assessment & Authorization | security assessments, authorization | compliance validated regularly |
| CM | Configuration Management | baselines, change control, inventory | configuration integrity maintained |
| IA | Identification and Authentication | user identification, multi-factor auth | identity verification working |
| IR | Incident Response | incident handling, preparation, recovery | incidents managed effectively |
| MA | Maintenance | system maintenance, software updates | systems kept current and secure |
| MP | Media Protection | data protection, sanitization, encryption | sensitive data protected |
| PE | Physical and Environmental Protection | physical access, environmental controls | facilities secured |
| PL | Planning | security planning, strategy, policies | roadmap defined and enforced |
| PS | Personnel Security | background checks, termination procedures | personnel vetted properly |
| RA | Risk Assessment | risk analysis, vulnerability management | risks identified and quantified |
| SA | System and Services Acquisition | procurement, supply chain security | systems acquired securely |
| SC | System and Communications Protection | encryption, network security, isolation | communications protected |
| SI | System and Information Integrity | malware protection, patch management, integrity | systems kept clean and whole |

**Report Example:**
```
nist_access_control = 92.3% (13/14)
nist_configuration_management = 87.5% (7/8)
nist_system_and_communications_protection = 100% (6/6)
```

**What This Means:**
- 100% coverage in a family = all controls in that domain have tests
- Partial coverage = some controls are tested, others may need supplemental verification
- Gaps indicate areas where compliance is untested by cawk (requires manual verification or additional tests)
- Use family-level scores to identify which security domains need attention or additional testing

**Integration:**
Compliance framework indicators are automatically calculated during the assessment reporting phase and included in summary reports (.all.*.txt, .all.*.csv, .all.*.json) via [report.gawk.template](common/report.gawk.template)

## Error Stats Section

Assessment summary reports end with an `---- error stats ----` block listing every failing test, grouped by
risk level (high, medium, low, info) and sorted by descending error count within each group:

```
---------------------
---- error stats ----
---------------------
number_of_error_high = 12
	aaa_user_notset.cisco-ios.gawk (ref nist ia-2 identification and authentication) = 8
	acl_defref_set.cisco-ios.gawk = 4
number_of_error_medium = 3
	...
```

Each entry shows the `test_name`, its NIST 800-53 reference when the test is mapped (`ref nist <id> <control>`),
and the number of configuration files that failed that test. This helps prioritize remediation on the
tests causing the most findings.

## Assessment Report Structure

The full text summary report is organized into these literal sections, in order:

- `---- assessment stats ----` — check counts, pass/error/warning/psirt totals and percentages (overall, NIST-scoped, and exceptions-scoped)
- `---- security key indicators ----` — `security_compliance`, `error_avg_perdevice`, `error_high_ratio`
- `---- information key indicators ----` — `security_info_compliance`
- `---- nist sp 800-53 key indicators ----` — `nist_ref_coverage` and per-family coverage
- `---- error stats ----` — failing tests ranked by count, see [Error Stats Section](#error-stats-section)

# cawk databases

cawk allows to manage flat file databases in order to use cawk options like sync confs,
sending emails, etc. this is only available for audit=AUDIT_NAME assessment
	
	- gmake database_view : view all the databases (collect, sync, email, postaudit), each one preceded
	  by its succinct field format (format : audit ...), like the database_view_* targets
	- gmake database_view_collect : view only the collect database
	- gmake database_view_sync : view only the sync database
	- gmake database_view_email : view only the email database
	- gmake database_view_postaudit : view only the postaudit database

## sync database

cawk sync database format is the following where fields are separated by spaces :

	each time sync_run audit=AUDIT_NAME target is called, database/scripts/database_sync.script
	is launched allowing to update device scope files that can be used as the field number 4 described 
	hereafter. these file inventory scopes are/must be stored in database/sync_scopes with the name :
	audit(=AUDIT_NAME assessment)_inventory_sync_scope.txt

		- 1 field is the audit name (i.e. audit=AUDIT_NAME)
		- 2 field is the various sync paths separated by comma (no space) 
		    like /conf/ or /conf/cawk/,/conf/cawk_2/ (i.e. dir=SYNC_PATH_DIR)
		- 3 field is an extended regex to select inventory (field 4) lines pattern matching 
		    like .* or .*switch.* (i.e. regexinventory=REGEX_INVENTORY) -- only applied when field 4
		    (scope) is set to an actual file; if scope=none, this field has no effect and
		    every file found under the sync paths (field 2) is synced
		- 4 field is a file containing a list of devices matching a device scope based on internal inventory
		    the file is located in database/sync_scopes directory and generated by database/scripts/database_sync.script
			audit(=AUDIT_NAME assessment)_inventory_sync_scope.txt
		- 5 field is an extended regex to select os pattern matching
		    like (cisco-ios|cisco-xr) or .* (i.e. regexos=REGEX)
		- 6 field is an extended regex to exclude some specific paths or device names if required 
		    like (_home_|_earth) or .* (i.e. regexpathexclude=REGEX)
		- 7 field is an extended regex to exclude inventory (field 4) lines pattern matching,
		    same "only applied with a scope file" restriction as field 3
		    like (_home_|_earth) or none (i.e. regexinventoryexclude=REGEX/none)

		note : common/sync_cawk_conf.gawk script is in charge to apply the database configuration 
		per audit=AUDIT_NAME

	- gmake database_view_sync : view only the cawk sync database

	- gmake database_sync_(add,update) audit=AUDIT_NAME dir=SYNC_PATH regexinventory=REGEX_PATTERN/.* scope=SCOPE_FILE/none
	  regexos=REGEX_PATTERN/.* regexpathexclude=REGEX_PATTERN/none regexinventoryexclude=REGEX_PATTERN/none: 
	  add/update an entry in the cawk sync database

	  note : when a scope file (field 4) is used, regexinventory/regexinventoryexclude may allow to build
		     sub-scopes of an assessment like audit=cawk_customer1_router with regexinventory matching only
			 routers, audit=cawk_customer1_switch with regexinventory matching only switches
	
	- gmake database_sync_del audit=AUDIT_NAME : delete an entry in the cawk sync database
	
## collect database

cawk collect database (database/db_collect.txt) format is the following where fields are separated by spaces :

		- 1 field is the audit name (i.e. audit=AUDIT_NAME)
		- 2 field is the collector name, the script database/collectors/<name>.collector.sh
		    (i.e. collector=scp|rsync|local)
		- 3 field is the collector arguments, key=value pairs separated by comma (no space, no comma
		    in a value) or none (i.e. args=host=192.0.2.10,user=cawk,remote_path=/srv/confs/,key=/home/cawk/.ssh/id_ed25519)

	- gmake create_audit audit=AUDIT_NAME adds the default entry "AUDIT_NAME none none" (collector none, no collection), 
	  delete_audit removes it; database_collect_(add,update) replaces the default entry

	- gmake database_view_collect : view only the cawk collect database

	- gmake database_collect_(add,update) audit=AUDIT_NAME collector=COLLECTOR_NAME args=ARGS/none [sync=yes] :
	  add/update an entry in the cawk collect database (add refuses an audit that already has a collector),
	  sync=yes also references confs/collect_AUDIT_NAME in the sync database (see database_collect_sync)

	- gmake database_collect_del audit=AUDIT_NAME : delete an entry in the cawk collect database

## email database

cawk email sync database format is the following where fields are separated by spaces :

		- 1 field is the audit name
		- 2 field is the dst list of emails separated by comma (no space) like email1,email2,email3
		- 3 field is the cc list of emails separated by comma (no space) like email1,email2,email3 or none

	- gmake database_view_email : view only the cawk email database

	- gmake database_email_(add,update) audit=AUDIT_NAME dst=EMAIL_LIST/none cc=EMAIL_LIST/none: 
	  add/update an entry in the cawk email database

	- gmake database_email_del audit=AUDIT_NAME : delete an entry in the cawk email database

## postaudit database

cawk postaudit database format follows the same structure where fields are separated by spaces:

		each time postaudit_run audit=AUDIT_NAME target is called, database/scripts/database_postaudit.script
		is launched allowing to run specific tasks like to generate helpdesk tickets, etc.

		- 1 field is the audit name (i.e. audit=AUDIT_NAME)

	- gmake database_view_postaudit : view only the cawk postaudit database

	- gmake database_postaudit_(add,update,del) audit=AUDIT_NAME :
	  add/update/delete an entry in the cawk postaudit database

	- gmake postaudit_run audit=AUDIT_NAME :
	  run database/scripts/database_postaudit.script for audit=AUDIT_NAME (skipped if the script does not exist)

	- gmake postaudit_run_audit :
	  run database/scripts/database_postaudit.script for all audit=AUDIT_NAMEs in the cawk postaudit database

## NIST 800-53 compliance database

cawk NIST 800-53 compliance database (database/db_nist800-53.txt) contains official
NIST 800-53 controls reference data with the following format (semicolon-separated fields):

		- 1 field is the NIST control ID (e.g., cm-7, cm-7(1), etc.)
		- 2 field is the NIST control category (e.g., Configuration Management, etc.)
		- 3 field is the control description
		- 4 field is comma-separated list of applicable suppliers (or . for all)

	- NIST controls are applied during assessment reporting phase to calculate compliance metrics:
		- Control coverage mapping: tests are mapped to NIST 800-53 controls via @nist800-53_ref metadata
		- Coverage percentage calculated as: (tests mapped to NIST controls / total NIST controls) × 100%
		- NIST coverage automatically included in summary reports (.all.*.txt, .all.*.csv, .all.*.json)
		- Coverage percentage displayed as compliance framework indicator in assessment summaries

	- gmake nist_coverage_official : display official NIST 800-53 controls with coverage metrics
	  gmake nist_coverage_repo : calculate coverage percentage for repo assessment
	  gmake nist_coverage_run [audit=AUDIT_NAME] : calculate coverage for run or named audit

## exceptions database

cawk exceptions database (database/db_exception.txt) is a centralized exception rules
repository with the following format (semicolon-separated fields):

		- 1 field is the audit name (i.e. audit=AUDIT_NAME)
		- 2 field is the supplier/platform (e.g., cisco-ios, juniper-junos)
		- 3 field is the exception ID for tracking and audit purposes
		- 4 field is the approver name (person who authorized the exception)
		- 5 field is the approval date (YYYY-MM-DD format)
		- 6 field is the reason for the exception

	- exception sources and matching logic:

		- exceptions/repo/*.m4 files : source definitions with metadata (@exception_id, @approver, @date, @reason)
			Contains m4_cawk_exception() macros with device, test_name, error_pattern matching rules
		- exceptions/run/*.m4 files : editable copy for default assessment
		- exceptions/run_audit/*.m4 files : per-audit custom exceptions

	- automatic integration and lifecycle:

		- exceptions_build triggered automatically by create_audit and delete_audit workflows
		- Ensures database/db_exception.txt stays synchronized with audit lifecycle
		- Exceptions applied to summary and final reports (.all.*.csv, .all.*.json)
		- Exception matching evaluated during assessment based on configured patterns in .m4 files

	- gmake exceptions_build : rebuild database/db_exception.txt from all .m4 exception files
	  gmake exceptions_build_repo : build exception database for repo/ only
	  gmake exceptions_build_run audit=AUDIT_NAME : build exception database for specific audit

## info database ----

cawk info database (database/db_info.txt) contains comprehensive test metadata compiled
from all test source files. Format: semicolon-separated fields (9 fields)

		- 1 field is the audit context (repo or audit name)
		- 2 field is the supplier/platform (e.g., cisco-ios, juniper-junos)
		- 3 field is the test_name (unique test identifier, must match compiled .gawk filename)
		- 4 field is the purpose (one-line purpose of the test)
		- 5 field is the description (detailed description of what the test checks)
		- 6 field is the actions (recommended remediation actions)
		- 7 field is the nist800-53_ref (NIST 800-53 control reference, e.g., cm-7(1) | configuration management)
		- 8 field is the risk_level (high, medium, low, info, or pipe-separated for multi-aspect tests)
		- 9 field is the authors (test authors, comma-separated if multiple)

	- test metadata sources:

		- extracted from @metadata tags in test template source files (*.gawk.template, *.gawk.m4, *.gawk.include)
		- metadata tags: @test_name, @supplier, @purpose, @description, @actions, @nist800-53_ref, @risk_level, @authors
		- see CLAUDE.md for metadata tag format and guidelines

	- automatic integration and lifecycle:

		- gmake catalog_build : rebuild database/db_info.txt from the test source files (*.gawk.template, *.gawk.m4, *.gawk.include)
		- triggered automatically by create_audit and delete_audit workflows
		- ensures database stays synchronized with test and audit lifecycle
		- used for generating catalog displays and NIST coverage reports

# cawk sync audit=AUDIT_NAME assessment

cawk allows to sync confs only for audit=AUDIT_NAME assessments. the way of working is:

	- use the gmake database_sync_(add,del,update) targets to update the cawk sync database
	  for audit=AUDIT_NAME assessment

	- gmake sync_run audit=AUDIT_NAME 	

	(CAUTION) local confs of the audit=AUDIT_NAME are removed 

	confs soft links from the central confs repositories to cawk confs/run_audit/confs.os 
	are automatically built and pushed in the right confs.os directory. In fact, each conf 
	is analyzed and os detected like cisco-ios, cisco-xe, etc.

	- gmake sync_run_audit (sync all the audit=AUDIT_NAMEs)

	- gmake sync_psirt : build psirt inventory to be used by psirt tests, the file MUST BE
	database/psirt_scopes/psirt_os_inventory_scope.txt to work well with the psirt tests

	- gmake sync_teststoconfs_run : to sync tests to confs for <audit=AUDIT_NAME> assessment.
	To be used after <sync_run> to reduce tests supplier scope to confs supplier scope. renames test
	directories (and .psirt directories) to zz.sync.save.* for suppliers that have no corresponding
	configuration in confs/run_AUDIT_NAME (preserving them for audit trail). in case of issue, you may
	copy tests sources from repo by gmake tests_run_copy audit=AUDIT_NAME

	- gmake sync_teststoconfs_run_audit : to sync tests to confs for only all <audit=AUDIT_NAME>
	assessments. To be used after <sync_run_audit> to reduce tests supplier scope to confs supplier
	scope. renames orphaned test directories with zz.sync.save.* prefix for all audits. in case of
	issue, you may copy tests sources from repo by gmake tests_run_audit_copy

	- gmake sync_exceptionstoconfs_run audit=AUDIT_NAME : to sync exceptions to confs for
	<audit=AUDIT_NAME> assessment. To be used after <sync_run> to reduce exceptions supplier scope
	to confs supplier scope. renames exception files to zz.sync.save.* for suppliers that have no
	corresponding configuration in confs/run_AUDIT_NAME (preserving them for audit trail)

	- gmake sync_exceptionstoconfs_run_audit : to sync exceptions to confs for all <audit=AUDIT_NAME>
	assessments. To be used after <sync_run_audit> to reduce exceptions supplier scope to confs
	supplier scope for all audits. renames orphaned exception files with zz.sync.save.* prefix

note : we do recommend that the central confs repository is owned by a different user than
the cawk package in order to enforce that the cawk user can only read the central confs
repository.

# cawk collect audit=AUDIT_NAME assessment

cawk can optionally fetch the confs itself from a central unix/linux system (one account on one host, holding
one file per device) with collectors (scp, rsync, local). cawk still needs only
gawk, gmake and m4: a collector is an external script of database/collectors, only used when it is configured
in the collect database and only needing its own tool (scp, rsync, cp). nothing changes when no collector is used.

A collector only fills confs/collect_AUDIT_NAME (one file per device, named after the device). the existing sync
links these files into confs/run_AUDIT_NAME, so the sync database (sync_paths, field 2) must reference
../collect_AUDIT_NAME/ :

	collector --> confs/collect_AUDIT_NAME/device <--(sync_paths ../collect_AUDIT_NAME/)-- sync_run
	          --> confs/run_AUDIT_NAME/confs.os/device (soft link, os detected by the sync)

the way of working is:

	- gmake database_collect_add audit=AUDIT_NAME collector=COLLECTOR_NAME args=ARGS sync=yes

	- gmake collect_run audit=AUDIT_NAME : run the collector of the audit, warns when the sync database does
	  not reference ../collect_AUDIT_NAME/ (fix it with gmake database_collect_sync audit=AUDIT_NAME)

	- gmake collect_run_audit : run the collectors of all the audits of the collect database

	- gmake sync_run audit=AUDIT_NAME COLLECT=yes : collect then sync (COLLECT=no by default); a collection
	  failure does not stop the sync, which uses the previously collected confs

	- gmake check_collect : non-regression of the collectors (no network, scp and rsync are replaced by shims, local runs for real in a temporary directory)

collectors (database/collectors/<name>.collector.sh, arguments are key=value pairs separated by comma):

	scp and rsync log in to the central system with an address (host=), an account (user=) and a key or
	the ssh agent (key=, optional), never a password:

	- scp       host=ADDRESS,user=USER,remote_path=REMOTE_DIR[,key=IDENTITY_FILE][,port=N][,timeout=SECONDS][,hostkey=yes|accept-new][,options=OPTS] :
	            copies the files of the directory REMOTE_DIR (absolute, one file per device) with scp -rp, the
	            copy is automatic (nothing to write); with OpenSSH 9.0 or later scp transfers with the sftp
	            protocol, so only the sftp subsystem is needed on the central system
	- rsync     host=ADDRESS,user=USER,remote_path=REMOTE_DIR[,key=IDENTITY_FILE][,port=N][,timeout=SECONDS][,hostkey=yes|accept-new][,options=OPTS] :
	            pulls the files of the directory REMOTE_DIR (absolute, one file per device) with rsync -rt over
	            ssh, the copy is automatic (nothing to write)

	- local     source_path=LOCAL_DIR :
	            copies with cp -p the regular files of the directory LOCAL_DIR (absolute, one file per device) of the
	            cawk machine itself, no network and no ssh (i.e. confs exported there by another tool, an nfs mount)

	options are extra scp options (scp collector) or rsync options (rsync collector) added to the automatic
	command, words separated by + because an arg has no space: options=-4+-o+ServerAliveInterval=5 or
	options=-J+bastion (scp), options=--bwlimit=1000+--compress (rsync); only letters, digits and ._=:/@%+- are allowed.

	host is an IP address or a name, the host key must be known (hostkey=yes, the default) unless
	hostkey=accept-new is given. only the regular files at the top of the central directory are collected, each
	one is a device named after its file.

example (central system 192.0.2.10, account cawk, confs in /srv/confs, audit toto):

	- the central system holds one file per device: /srv/confs/cisco-ios1, /srv/confs/junos1, /srv/confs/forti1

	- gmake create_audit audit=toto
	- gmake database_collect_add audit=toto collector=rsync args=host=192.0.2.10,user=cawk,remote_path=/srv/confs/,key=/home/cawk/.ssh/id_ed25519 sync=yes
	  or collector=scp args=host=192.0.2.10,user=cawk,remote_path=/srv/confs/,key=/home/cawk/.ssh/id_ed25519
	  or collector=local args=source_path=/srv/confs/
	- gmake collect_run audit=toto : the confs are in confs/collect_toto/ (cisco-ios1, junos1, forti1)
	- gmake sync_run audit=toto : they are linked into confs/run_toto/confs.cisco-ios/cisco-ios1,
	  confs/run_toto/confs.juniper-junos/junos1 and confs/run_toto/confs.fortinet-fortios/forti1

common behaviour: a device configuration is only replaced by a non-empty one (a failing collection keeps the previous
files and gives exit code 1), files of devices that are no longer on the central system are removed only after a
fully successful run, the file modification time is kept (deadbeef scan), CR characters are removed by the scp
collector, the names of the collected files build database/sync_scopes/collect_AUDIT_NAME.txt (usable as the field 4
of the sync database). a collector must be called from the cawk root as <name>.collector.sh AUDIT DEST_DIR [ARGS]

CAUTION: confs/collect_AUDIT_NAME holds raw confs with secrets: it is not saved by backup, not touched by
gmake clean, removed by delete_audit; use gmake censor_run before sharing confs.

# cawk psirt tests

compared to standard tests, psirt tests are located in tests.<os>.psirt directories and have 
<*.gawk.include> suffix. within a test, you can setup advanced checks like:
	
	- device name pattern matching
	- os patterns matching (os_version chassis cpu) / these regex are compared with the 
	  central psirt scope located in database/psirt_scopes/psirt_os_inventory_scope.txt 
	- LINE(s) pattern matching
	- BLOCK(s) pattern matching 
	- Build a combined logic to detect vulnerable devices 

a psirt test can also be written with the macros of m4/cawk_psirt.m4, in a <*.gawk.include.m4> file
(both formats coexist, the demo is CVEyyy_xxxm4_psirt.<os>.gawk.include.m4). the macros number the
patterns and give a name to every line and block, the logic uses these names:

	psirt_begin
	psirt_device(`^.*')
	psirt_os_between(`15.0', `16.99')                 version range (os_version of the inventory)
	psirt_os_lt(`12.4(24)T5')                         also eq, le, gt, ge, optional platform regex
	psirt_line(`has_vty', `line vty')
	psirt_block(`intf', `^interface ', `^!')
	psirt_block_line(`intf', `intf_noshut', `^ no shutdown')
	psirt_logic(`has_vty == 1 && intf == 1 && intf_noshut == 0')
	psirt_end

the arguments are always quoted. the version of a comparison is split in numeric and alphabetic
components (15.4(3)T1 = 15 4 3 T 1): 15.4(3) < 15.4(3)T < 15.4(3)T1, a train letter (T, M, SE) is
compared alphabetically, so bound a range with the same train. a .gawk.include can use the same
comparisons with OS_CMP[n]["op"|"min"|"max"|"platform"]. gmake clean removes the generated
<*.gawk.include.gen>, which is not versioned.

every psirt result keeps the status psirt (one psirt report), the risk_level tells what it means:

	- high   : vulnerable, the configuration logic and an OS pattern are matched
	- low    : an OS pattern is matched but the configuration logic is not (version in scope, not exposed)
	- info   : not vulnerable (OS pattern not matched)
	- medium : skipped, no information (device pattern not matched, inventory file or inventory entry
	           missing, invalid os_device format) - a coverage gap to fix in psirt_os_inventory_scope.txt

only high is a vulnerability: the html report counts high as "PSIRT vulnerable", the other levels as
"PSIRT not affected". line_nb of a high result is the first line matching a LINE or BLOCK pattern.

# cawk email audit=AUDIT_NAME assessment

cawk allows to email audit=AUDIT_NAME assessments in zip file format. the way of working is:

	- use the gmake database_email_(add,del,update) targets to update the cawk email database
	  for audit=AUDIT_NAME assessment

	- gmake email_send audit=AUDIT_NAME : send email by refering to cawk email database 	

	- gmake email_send_audit (email all the audit=AUDIT_NAMEs)

# cawk postaudit audit=AUDIT_NAME assessment

cawk allows to run a post-audit script only for audit=AUDIT_NAME assessments, for example to
generate helpdesk tickets once a report has been reviewed/emailed. the way of working is:

	- use the gmake database_postaudit_(add,update,del) targets to register audit=AUDIT_NAME in the
	  cawk postaudit database

	- gmake postaudit_run audit=AUDIT_NAME : run database/scripts/database_postaudit.script for
	  audit=AUDIT_NAME (skipped if the script does not exist)

	- gmake postaudit_run_audit (run the postaudit script for all audit=AUDIT_NAMEs registered
	  in the cawk postaudit database)

# cawk backup/restore audit=AUDIT_NAME assessment

cawk allows to build backup/restore only for audit=AUDIT_NAME assessments. 
it saves all tests, exceptions, confs, reports linked to this assessment. 

## backup one audit assessment
for example, to backup an audit=cawk assessment, execute : 
 - gmake backup_run audit=cawk
   the backup file is stored in backup/run_audit_cawk_<date>.tar.gz

## restore one audit assessment
copy your backup in the cawk backup directory, execute: 
 - gmake restore_run audit=cawk file=backup_path_file 
as such, the audit=cawk assessment is restored.

## backup all audit assessments
you can backup cawk database and all your audit=AUDIT_NAME assessments in one command, execute :
 - gmake backup_run_audit
   the backup file is stored in backup/run_audit_<date>.tar.gz

## restore all audit assessments
copy your backup in the cawk backup directory, execute: 
 - gmake restore_run_audit file=backup_path_file 
as such, all the assessments are restored.

# cawk catalog targets

cawk provides catalog targets to build and display comprehensive test metadata catalogs:

	- gmake catalog_build : rebuild the test catalog databases from the test metadata
	  - database/db_info.txt : test information catalog (compiled from the test source files)
	  - database/db_nist_mappings.json : NIST 800-53 control mappings (compiled from @nist800-53_ref metadata)

	- gmake catalog_repo : display catalog information for repo assessment

	- gmake catalog_run [audit=AUDIT_NAME] : display catalog information for run or specific audit

	- gmake catalog_exceptions_repo : display exception catalog for repo (organized by supplier)
	  gmake catalog_exceptions_run [audit=AUDIT_NAME] : display exception catalog for run or specific audit

	- gmake nist_coverage_official : display official NIST 800-53 controls with coverage metrics
	  gmake nist_coverage_repo : calculate coverage percentage for repo assessment
	  gmake nist_coverage_run [audit=AUDIT_NAME] : calculate coverage for run or specific audit

	note : catalogs are automatically built during create_audit and delete_audit workflows to ensure
	consistency with the audit lifecycle

# cawk censor

	- gmake censor_repo : censor confs/repo/confs.<supplier> into confs/repo/confs.<supplier>.censored
	  gmake censor_run : same for confs/run
	  gmake censor_run audit=AUDIT_NAME : same for confs/run_AUDIT_NAME
	  gmake censor_run_audit : same for every named audit
	  (supplier=SUPPLIER restricts the censoring to one supplier ; without supplier= the suppliers with no
	  confs directory are skipped, with supplier= a missing confs.<supplier> directory is an error)

	- gmake censor_file in=PATH_FILE out=PATH_FILE_OUT : censor one file into one file (out must differ from in)
	  gmake censor_stdout in=PATH_FILE : censor one file to the standard output
	  gmake censor_check in=PATH_FILE_OR_DIR : fail (exit 1) while a text the regexes would censor is still
	  there, the guard run before sharing a file or a censored directory

	- gmake censor_logs_repo : censor logs/repo into logs/repo.censored
	  gmake censor_logs_run : same for logs/run
	  gmake censor_logs_run audit=AUDIT_NAME : same for logs/run_AUDIT_NAME
	  gmake censor_logs_run_audit : same for every named audit

	- gmake censor_report_repo : censor reports/repo into reports/repo.censored (an assessment result line
	  holds the configuration line it is about)
	  gmake censor_report_run : same for reports/run
	  gmake censor_report_run audit=AUDIT_NAME : same for reports/run_AUDIT_NAME
	  gmake censor_report_run_audit : same for every named audit

	- gmake clean_censor_repo : remove confs/repo/confs.<supplier>.censored
	  gmake clean_censor_run : same for confs/run
	  gmake clean_censor_run audit=AUDIT_NAME : same for confs/run_AUDIT_NAME
	  gmake clean_censor_run_audit : same for every named audit
	  (supplier=SUPPLIER restricts the cleaning to one supplier)
	  gmake clean_censor_logs_repo : remove logs/repo.censored
	  gmake clean_censor_logs_run : same for logs/run
	  gmake clean_censor_logs_run audit=AUDIT_NAME : same for logs/run_AUDIT_NAME
	  gmake clean_censor_logs_run_audit : same for every named audit
	  gmake clean_censor_report_repo : remove reports/repo.censored
	  gmake clean_censor_report_run : same for reports/run
	  gmake clean_censor_report_run audit=AUDIT_NAME : same for reports/run_AUDIT_NAME
	  gmake clean_censor_report_run_audit : same for every named audit

	database/censor/censor_regex.m4 is the only file to edit to control the censor module : the regexes
	are written in it with the macros of m4/cawk_censor.m4 (one per line, not nested, the argument is a
	quoted extended regex) and built by gmake into database/censor/censor_regex (generated file, never
	edit it : it is overwritten at the next censor_*), applied in order on every line of the configurations :
	  - censor_after(`regex') : censors the text following the regex, up to the end of line
	    (snmp-server community public RO : gives "snmp-server community CENSORED") ;
	    a line with nothing after the regex is left untouched
	  - censor_match(`regex') : censors the text matched by the regex (its blanks included)
	  - censor_line(`regex') : censors the whole line containing a match of the regex
	  - censor_ignore(`regex') : like censor_match, the case is ignored
	  every macro except censor_ignore takes an optional second argument : `lowercaseuppercase' ignores the case of the regex
	  (e.g. censor_after(` password ', `lowercaseuppercase'))
	  (the censored text is replaced by CENSORED)
	every macro also takes an optional third argument, its distribution level : internal (default) or external
	  (e.g. censor_match(`ip address [0-9.]+', `', `external')) ; censor_ignore(`regex', `', `external') leaves its
	  second argument empty, the level is always the third
	every macro also takes an optional fourth argument, the word printed in place of the censored text : CENSORED (default)
	  (e.g. censor_match(`password +[^ ]+', `', `internal', `XXXX')) ; it must not hold a tab
	  - gmake censor_repo (CENSOR_LEVEL=internal, the default) : only the regexes of level internal are applied
	  - gmake censor_repo CENSOR_LEVEL=external : the regexes of level internal AND external are applied
	  any other CENSOR_LEVEL value, like any other level in a macro, is an error
	default regexes : one regex per section, line by line, merging the syntaxes of the suppliers :
	  - internal : ADMIN, AUTHENTICATION, CRYPTO, SECRET (passwords, keys, hashes, service password-encryption), MONITORING (snmp communities and users), CERTIFICATE (PEM and hexadecimal bodies)
	  - external : IDENTITY (hostname, description, contact, location), TOPOLOGY (IPv4, IPv6 and MAC addresses, netmasks included)
	  a keyword of the SECRET and ADMIN regexes must follow a space (indented line), validate/censor/run.sh checks every section (validate/censor/cases.tsv)

	the censored directories are regenerated at each run and are ignored by the assessments,
	the catalogs and gitcheck ; the line count, the end of line and the files with nothing to censor
	are preserved

# cawk Makefile

Starting with v3.7.0, the central Makefile has been split into several modular
Makefile.support.*.mk files to enhance maintainability and performance.

Each file is self-contained with its own `.PHONY` declarations and targets:

| File | Purpose |
|------|---------|
| Makefile | Main entry point, includes all support files |
| support/Makefile.support.mk | Core variables, paths, options, compilation rules |
| support/Makefile.support.help.mk | Help and information targets |
| support/Makefile.support.audit.mk | Audit creation/deletion/management |
| support/Makefile.support.database.mk | Database entry management |
| support/Makefile.support.postaudit.mk | Post-audit execution |
| support/Makefile.support.email.mk | Email notification |
| support/Makefile.support.backup.mk | Backup, restore, migrate |
| support/Makefile.support.sync.mk | Config synchronization |
| support/Makefile.support.tests.mk | Test compilation and validation |
| support/Makefile.support.view.mk | Report viewing (view_repo, view_run) |
| support/Makefile.support.archive.mk | Archive management |
| support/Makefile.support.clean.mk | Cleanup targets (reports, archives, logs, censored confs) |
| support/Makefile.support.catalog.mk | Test catalog and NIST mapping |
| support/Makefile.support.censor.mk | Configuration censoring (censor_repo, censor_run, censor_run_audit ; the clean_censor_* targets are in the clean file) |
| support/Makefile.support.exceptions.mk | Exception rule management |
| support/Makefile.support.check.mk | Assessment and validation (check, check_parallel, check_update) |
| support/Makefile.support.check.scope.mk | check_repo and check_run (one recipe for repo, run and audit, sequential and parallel) |
| support/Makefile.support.git.mk | Git and CI/CD integration |

# cawk support/Makefile.support.mk

You may thanks to the file support/Makefile.support.mk control all the cawk options like PSIRT_ONLY,
DEADBEEF, etc. Please note that all these options can be called with gmake like:
gmake check_repo DEADBEEF=yes PSIRT_ONLY=yes ....

Note on PSIRT_ONLY (assessment mode, formerly PSIRT):
	- PSIRT_ONLY=no (default): run standard tests + psirt tests
	- PSIRT_ONLY=yes        : run ONLY psirt tests (standard tests are skipped)
	psirt tests are always compiled; this flag only selects which tests run at assessment time.

Note on STANDARD_ONLY (mirror of PSIRT_ONLY):
	- STANDARD_ONLY=no (default): run standard tests + psirt tests
	- STANDARD_ONLY=yes         : run ONLY standard tests (psirt tests are skipped)
	STANDARD_ONLY=yes and PSIRT_ONLY=yes exclude each other and are rejected.

# cawk version migration

## manually
1) backup all your audit=AUDIT_NAME assessments and save it in a secure directory 
	- gmake backup_run_audit
2) install a new version of cawk
3) copy your backup filename (previously done) in the new version of cawk backup directory
4) restore your all audit=AUDIT_NAME assessments
	- gmake restore_run_audit file=backup/backup_filename
5) to update the tests only for audit=AUDIT_NAME assessments, you may use the target :
	- tests_run_copy audit=AUDIT_NAME (ref one run_audit)
	- tests_run_audit_copy (ref all run_audit)

	it allows to copy/update tests from repo to run_audit in order to have the lastest set of 
	tests from repo linked to your audit=AUDIT_NAME assessments :
		- if you have coded additional tests, we will remain there
		- if you have changed existing tests, they will be changed to repo tests

6) gmake clean clean_common tests_run_audit

the migrate target allows to reach this goal in such a way:
1) backup all your audit=AUDIT_NAME assessments and save it in a secure directory 
	- gmake backup_run_audit
2) install a new version of cawk
3) gmake migrate file=backup_filename_path and all the next steps above are done automatically

## Makefile.cawk.version
The Makefile.cawk.version file provides installation and version management targets:
	- install - First time installation of cawk
		- required: `CAWK_VERSION=x.y.y`
	- reinstall - Reinstall current cawk version with audit backup and restore
		- required: `CAWK_VERSION=x.y.y`
	- update - Install new cawk version with automatic backup and restore from previous version
		- required: `CAWK_VERSION=x.y.y CAWK_NEXT_VERSION=x.y.y`

	note: This Makefile must be located in the parent directory of cawk installations.

# cawk docker

first of all, you need to install:
- docker
- buildx

the cawk docker files:
- docker/Dockerfile : allow to build a cawk image
- docker/dockerfile_cawk_run.sh : script runned when running the cawk container
- Makefile.docker : contains all the commands to manage cawk container and persistent data storage

to know all the available commands:

- gmake -f Makefile.docker : provide all the available target commands
	IMAGE NAME     : cawk-docker:$(CAWK_VERSION)
	CONTAINER NAME : cawk-container-$(CAWK_VERSION)
	VOLUME NAME    : cawk-persistent-volume-$(CAWK_VERSION)

some useful commands are :

- gmake -f Makefile.docker status : provide a status of the cawk container and persistent data storage
	cawk container status ----
	sudo docker ps -a --filter name=cawk-container-v3.2.0 || echo "No containers found"
	CONTAINER ID   IMAGE                COMMAND                  CREATED         STATUS         PORTS     NAMES
	2dbee2c723b3   cawk-image:v3.2.0   "/app/cawk/dockerfil…"   9 minutes ago   Up 9 minutes             cawk-container-v3.2.0

	cawk volume status ----
	sudo docker volume ls --filter name=cawk || echo "No cawk volumes found"
	DRIVER    VOLUME NAME
	local     cawk-persistent-volume-v3.2.0

- gmake -f Makefile.docker info-volume
	cawk volume information ----
	sudo docker volume inspect cawk-persistent-volume-v3.2.0 || echo "Volume cawk-persistent-volume-v3.2.0 not found"
	[
		{
			"CreatedAt": "2025-12-03T18:24:02+01:00",
			"Driver": "local",
			"Labels": null,
			"Mountpoint": "/var/lib/docker/volumes/cawk-persistent-volume-v3.2.0/_data",
			"Name": "cawk-persistent-volume-v3.2.0",
			"Options": null,
			"Scope": "local"
		}
	]

- to run an assessment, just launch this command and check in persistent data storage the results
	sudo docker exec cawk-container-v3.2.0 sh -c "cd /app/cawk && gmake check_repo >> /app/cawk/logs/cawk-check.log 2>&1"
	sudo docker exec cawk-container-v3.2.0 sh -c "cd /app/cawk && gmake check_run audit=<AUDIT_NAME> >> /app/cawk/logs/cawk-check-<AUDIT_NAME>.log 2>&1"
	sudo ls /var/lib/docker/volumes/cawk-persistent-volume-v3.2.0/_data/

# Test Metadata Tags Reference

When creating or modifying tests, the following metadata tags are **required** at the top of every test file. These tags are extracted during `gmake catalog_build` to populate the test database and NIST coverage reports.

## Required Metadata Tags

All tests must include these tags as comments (format: `# @tag_name : value`):

| Tag | Required | Format | Example |
|-----|----------|--------|---------|
| `@test_name` | Yes | Must match compiled `.gawk` filename (without suffix) | `aaa_user_notset.juniper-junos` |
| `@supplier` | Yes | Vendor/platform name | `juniper-junos`, `cisco-ios` |
| `@purpose` | Yes | One-line summary of test objective | `Verify forbidden AAA users are not configured` |
| `@description` | Yes | Detailed explanation of what is checked and why | `Checks that no user accounts matching [...] appear in the configuration. This prevents unauthorized...` |
| `@risk_level` | Yes | Single level or pipe-separated list for multi-aspect tests | `high` or `high \| medium \| info` |
| `@actions` | Yes | Recommended remediation steps | `Remove forbidden user accounts; configure only approved users` |
| `@nist800-53_ref` | Yes | NIST control ID(s) with pipe-separated category and description | `IA-2 \| Identification and Authentication \| Multi-factor...` |
| `@authors` | Yes | Comma-separated author names | `Alice Smith, Bob Johnson` |

## Metadata Format Rules

- **Pipe separator (`|`)** — Use for multi-value fields (multiple NIST refs, multiple risk levels)
- **No commas in multi-value fields** — Use pipes, not commas, for field separation
- **Match test filename exactly** — The `@test_name` must match the compiled `.gawk` filename
- **NIST reference format** — Use lowercase control IDs (e.g., `IA-2(1)`, not `ia-2(1)`); separate ID, category, and description with pipes

## Example Test Header

```
# @test_name : aaa_userclass_notset.juniper-junos
# @supplier : juniper-junos
# @purpose : Verify user class assignments are configured
# @description : Ensures all configured AAA users have an assigned user class (required for privilege enforcement). User class defines permissions and capabilities on Junos devices.
# @risk_level : high
# @actions : Assign user-class to each configured user; verify class permissions align with job requirements
# @nist800-53_ref : IA-2 | Identification and Authentication | Multi-factor authentication and strong access controls
# @authors : Security Team, Network Operations
```

## Multi-Aspect Tests

For tests that check multiple security aspects with different risk levels, use pipe-separated risk_level and nist800-53_ref:

```
# @risk_level : high | medium | low
# @nist800-53_ref : AC-3 | Access Control | [...] | SC-7 | System Communications Protection | [...]
```

# cawk specific system

The CAWK_SYSNAME environment variable can be set to implement cawk <_special> function calls. Below is a list of 
<_special> functions that can be called:

If CAWK_SYSNAME environment variable is set, all functions related to these files call their <_special> functions:

	- common/common.gawk.template functions are replaced by special functions in database/common/special_common.gawk.template
 	  (special functions can be coded specifically for your system and will be backed up and restored)

# Contributing to cawk

We welcome contributions from the community! If you'd like to:

- **Report a bug** — Open an issue with details and reproduction steps
- **Suggest a feature** — Describe your idea and use case
- **Submit a test or enhancement** — Follow our contribution guidelines

## Getting Started

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for:

- Pull request procedure and branch naming conventions
- Code style and formatting guidelines
- Testing requirements before submission
- Documentation update checklist
- Local validation steps

For security vulnerabilities, please see [SECURITY.md](SECURITY.md) for responsible disclosure.

## Community Standards

We are committed to providing a welcoming and inclusive environment. Please review our [Code of Conduct](CODE_OF_CONDUCT.md).

---

Approved contributions will be:
- Added to the cawk package
- Credited in the [AUTHORS](AUTHORS.md) list
- Acknowledged in the [ChangeLog](ChangeLog.md)

Enjoy participating in cawk or simply using it!

**cedric llorens**