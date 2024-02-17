#!/usr/bin/env -S gawk -f

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : this test generates an error if snmp v1v2 write mode is set
# ------------------------------------------------------------

@include "common/common.gawk"

BEGIN {
}

BEGINFILE {
	pass = 1;
	block_snmp = 0;
}

/^snmp {/ {
	block_snmp = 1;
	block_community = 0;
	next;
}

/^    community / && block_snmp == 1 {
	block_community = 1;
	next;
}

/^        authorization write/ && block_community == 1 {
	print_err("snmp_v1v2rw_notset.juniper-junos.gawk",rm_blank_before(rm_last_char($0)),FNR,"high","error");
        pass = 0;
	nextfile;
}

/^    }$/ && block_community == 1 {
	block_community = 0;
	next;
}

/^}/ {
	block_snmp = 0;
}

ENDFILE {
        if ( pass ) print_err("snmp_v1v2rw_notset.juniper-junos.gawk","snmp v1v2 write mode is not set",0,"high","pass");
}

END {
}
