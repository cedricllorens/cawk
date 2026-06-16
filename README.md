# cawk README

> **cawk is subject to an MIT open-source license**  
> Please refer to the LICENSE file for further information
> **cawk is Copyright (C) 2024-2026 by Cedric Llorens**

# cawk introduction

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

- scripts : contains scripts used for various usages as described : generally it requires the
use of the internal inventory

	- each time sync_run audit=AUDIT_NAME target is called, database_sync.script is launched
	allowing to update device scope files. these file scopes are/must be stored in sync_scopes with
	the name audit(=AUDIT_NAME)_inventory_sync_scope.txt
	
	- sync_scopes : sync scopes files generated by the scripts described above. It could be useful
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
	  and the final reports have the substrings (.all(.security./.audit./.psirt./.exception./.deadbeef.))
	
	- for all the final reports (.all.security. or .all.audit. or .all.psirt. or .all.exception.), a timeline 
	  report is also generated in order to be injected into microsoft powerbi, grafana, etc. as it includes a 
	  timestamp for each error modifying the line format (day, month, year, week, number of devices assessed)
	  (please refer to cawk assessment format for further information)

	- for the final reports, the concept of deadbeef that can be also activated in Makefile.support.mk or by 
	  calling gmake with DEADBEEF like (gmake check_run audit=cawk DEADBEEF=yes):
		- if DEAEDBEEF is set to "yes", then the deadbeef final report is generated and the deadbeef devices 
		  are removed from the others final reports (.all.security.,.all.audit.,.all.psirt.,all.exception.)
		- if DEAEDBEEF is set to "no", then the deadbeef final report is generated and the deadbeef devices 
		  are kept in the others final reports (.all.security.,.all.audit.,.all.psirt.,all.exception.)
		- a device is considered by default as deadbeef if the configuration is older than the days value 
		set in DEADBEEF_THRESHOLD_DAYS  (default value is 30 days)

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

cawk computes three key security indicators in the summary report:
	- security compliance (scope pass/error) : expressed as a percentage between 0% and 100% (100% is best)
	- high risk error ratio (scope error) : expressed as a percentage between 0% and 100% (0% is best)
	- average errors per device (scope error) : measured from 0 upward with no upper bound (0 is best)

# cawk compliance framework indicators

cawk supports compliance framework indicators that are automatically calculated and displayed in assessment
summary reports. these indicators track compliance against recognized security standards:

	- NIST 800-53 compliance coverage : percentage of official NIST 800-53 controls mapped to cawk tests
	  - calculated as: (tests mapped to NIST controls / total NIST controls) × 100%
	  - automatically included in summary reports (.all.*.txt, .all.*.csv, .all.*.json)
	  - displayed as a compliance framework indicator in assessment summaries

	note : compliance framework indicators are automatically integrated into report generation via
	updated report.gawk.template and report_sumjson.gawk.template. these indicators are calculated
	during the assessment reporting phase and provide visibility into compliance posture

# cawk databases

cawk allows to manage flat file databases in order to use cawk options like sync confs,
sending emails, etc. this is only available for audit=AUDIT_NAME assessment
	
	- gmake database_view : view all the databases

## sync database

cawk sync database format is the following where fields are separated by spaces :

	each time sync_run audit=AUDIT_NAME target is called, database/scripts/database_sync.script
	is launched allowing to update device scope files that can be used as the field number 4 described 
	hereafter. these file inventory scopes are/must be stored in database/sync_scopes with the name :
	audit(=AUDIT_NAME assessment)_inventory_sync_scope.txt

		- 1 field is the audit name (i.e. audit=AUDIT_NAME)
		- 2 field is the various sync paths separated by comma (no space) 
		    like /conf/ or /conf/cawk/,/conf/cawk_2/ (i.e. dir=SYNC_PATH_DIR)
		- 3 field is an extended regex to select devices pattern matching 
		    like .* or .*switch.* (i.e. regex=REGEX_DEVICE)
		- 4 field is a file containing a list of devices matching a device scope based on internal inventory
		    the file is located in database/sync_scopes directory and generated by database_postaudit.script
			audit(=AUDIT_NAME assessment)_inventory_sync_scope.txt
		- 5 field is an extended regex to select os pattern matching
		    like (cisco-ios|cisco-xr) or .* (i.e. regexos=REGEX)
		- 6 field is an extended regex to exclude some specific paths if required 
		    like (_home_|_earth) or .* (i.e. regexpathexclude=REGEX)

		note : common/sync_cawk_conf.gawk script is in charge to apply the database configuration 
		per audit=AUDIT_NAME

	- gmake database_sync_(add,update) audit=AUDIT_NAME dir=SYNC_PATH regex=REGEX_PATTERN/.* scope=SCOPE_FILE/none: 
	  add/update an entry in the cawk sync database

	  note : regex may allow to build sub-scope of an assessment like
		     audit=cawk_customer1_router with regex matching only routers
			 audit=cawk_customer1_switch with regex matching only switches
	
	- gmake database_sync_del audit=AUDIT_NAME : delete an entry in the cawk sync database
	
## email database

cawk email sync database format is the following where fields are separated by spaces :

		- 1 field is the audit name"
		- 2 field is the dst list of emails separated by comma (no space) like email1,email2,email3"
		- 3 field is the cc list of emails separated by comma (no space) like email1,email2,email3"

	- gmake database_email_(add,update) audit=AUDIT_NAME dst=EMAIL_LIST/none cc=EMAIL_LIST/none: 
	  add/update an entry in the cawk email database

	- gmake database_email_del audit=AUDIT_NAME : delete an entry in the cawk email database

## postaudit database

cawk postaudit database format follows the same structure where fields are separated by spaces:

		each time postaudit_run audit=AUDIT_NAME target is called, database/scripts/database_postaudit.script
		is launched allowing to run specific tasks like to generate helpdesk tickets, etc.

		- 1 field is the audit name (i.e. audit=AUDIT_NAME)

	- gmake database_postaudit_(add,del) audit=AUDIT_NAME :
	  add/delete an entry in the cawk postaudit database

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
	  gmake exceptions_build_repo : build exception database for repo/ and run/
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

		- gmake catalog_build : rebuild database/db_info.txt from all .gawk source files
		- triggered automatically by create_audit and delete_audit workflows
		- ensures database stays synchronized with test and audit lifecycle
		- used for generating catalog displays and NIST coverage reports

# cawk catalog targets

cawk provides catalog targets to build and display comprehensive test metadata catalogs:

	- gmake catalog_build : rebuild all catalog databases from test and exception metadata
	  - database/db_info.txt : test information catalog (compiled from all .gawk source files)
	  - database/db_exception.txt : exception catalog (compiled from all .m4 files)
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

# cawk email audit=AUDIT_NAME assessment

cawk allows to email audit=AUDIT_NAME assessments in zip file format. the way of working is:

	- use the gmake database_email_(add,del,update) targets to update the cawk email database
	  for audit=AUDIT_NAME assessment

	- gmake email_send audit=AUDIT_NAME : send email by refering to cawk email database 	

	- gmake email_send_audit (email all the audit=AUDIT_NAMEs)

# cawk psirt tests

compared to standard tests, psirt tests are located in tests.<os>.psirt directories and have 
<*.gawk.include> suffix. within a test, you can setup advanced checks like:
	
	- device name pattern matching
	- os patterns matching (os_version chassis cpu) / these regex are compared with the 
	  central psirt scope located in database/psirt_scopes/psirt_os_inventory_scope.txt 
	- LINE(s) pattern matching
	- BLOCK(s) pattern matching 
	- Build a combined logic to detect vulnerable devices 

# cawk Makefile.support.mk

you may thanks to the file Makefile.support.mk control all the cawk options like PSIRT,
DEADBEEF, etc. please note that all these options can be called with gmake like:
gmake check_repo DEADBEEF=yes PSIRT=yes ....

note on PSIRT (assessment mode):
	- PSIRT=no (default): run standard tests + psirt tests
	- PSIRT=yes        : run ONLY psirt tests (standard tests are skipped)
	psirt tests are always compiled; this flag only selects which tests run at assessment time.

# cawk backup/restore audit=AUDIT_NAME assessment

cawk allows to build backup/restore only for audit=AUDIT_NAME assessments. 
it saves all tests, exceptions, confs, reports linked to this assessment. 

## backup one audit assessment
for example, to backup an audit=cawk assessment, execute : 
 - gmake backup_run audit=cawk
   the backup file is stored in backup/run_cawk.<date>.tar.gz

## restore one audit assessment
copy your backup in the cawk backup directory, execute: 
 - gmake restore_run audit=cawk file=backup_path_file 
as such, the audit=cawk assessment is restored.

## backup all audit assessments
you can backup cawk database and all your audit=AUDIT_NAME assessments in one command, execute :
 - gmake backup_run_audit
   the backup file is stored in backup/run_audit.<date>.tar.gz

## restore all audit assessments
copy your backup in the cawk backup directory, execute: 
 - gmake restore_run_audit file=backup_path_file 
as such, all the assessments are restored.

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
- Dockerfile : allow to build a cawk image
- cawk_docker_run.sh : script runned when running the cawk container
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
	2dbee2c723b3   cawk-image:v3.2.0   "/app/cawk/cawk_dock…"   9 minutes ago   Up 9 minutes             cawk-container-v3.2.0

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