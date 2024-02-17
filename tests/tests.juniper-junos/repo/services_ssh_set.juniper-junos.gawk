#!/usr/bin/env -S gawk -f

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : this test check if the services block has setup ssh protocol
# ------------------------------------------------------------

@include "common/common.gawk"

BEGIN {
}

BEGINFILE {
	block_system = 0;
	block_services = 0;
	pass = 0;
}

/^system {/ {
        block_system = 1;
	next;
}

/^    services {/ && block_system == 1 {
	block_services = 1;
	next;
}

/^        ssh( |;)/ && block_services == 1 {
	print_err("services_ssh_set.juniper-junos.gawk",rm_last_char(rm_blank_before($0)),FNR,"high","pass");
	pass = 1;
	nextfile;
}

/^SED_BK_JUNI%}$/ && block_services == 1 {
	block_services = 0;
	next;
}

/^}$/ {
	block_system = 0;
}

ENDFILE {
	if ( !pass ) print_err("services_ssh_set.juniper-junos.gawk","services must activate ssh service",0,"high","error");
}

END {
}
