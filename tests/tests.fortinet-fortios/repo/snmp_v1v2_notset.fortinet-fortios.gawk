#!/usr/bin/env -S gawk -f

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : this test generates an error if snmp v1v2 is set
# ------------------------------------------------------------

@include "common/common.gawk"

BEGIN {
}

BEGINFILE {
	pass = 1 ;
	block_snmp = 0;
}

/^config system snmp community/ {
	block_snmp = 1;
	next;
}

/^    [ ]*set / && block_snmp == 1 {
	print_err("snmp_v1v2_notset.fortinet.gawk",rm_blank_before($0),FNR,"high","error");
	pass = 0;	
	nextfile;
}

/^end$/ {
	block_snmp = 0;
}

ENDFILE {
	if ( pass ) print_err("snmp_v1v2_notset.fortinet.gawk","snmp v1v2 is not set",0,"high","pass");
}

END {
}
