#!/usr/bin/env -S gawk -f

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : this test check if the services block has not setup forbidden protocols
# ------------------------------------------------------------

@include "common/common.gawk"

BEGIN {
}

BEGINFILE {
	block_system = 0;
	block_services = 0;
	pass = 1;
}

/^system {/ {
        block_system = 1;
	next;
}

/^    services {/ && block_system == 1 {
	block_services = 1;
	next;
}

/^        (telnet|ftp)( |;)/ && block_services == 1 {
	print_err("services_forbidproto_notset.juniper-junos.gawk",rm_last_char(rm_blank_before($0)),FNR,"high","error");
	pass = 0;
	next;
}

/^    }$/ && block_services == 1 {
	block_services = 0;
	next;
}

/^}$/ {
	block_system = 0;
}

ENDFILE {
	if ( pass ) print_err("services_forbidproto_notset.juniper-junos.gawk","services has no setup forbidden protocols",0,"high","pass");
}

END {
}
