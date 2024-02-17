#!/usr/bin/env -S gawk -f

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : this test generates an error if snmp v1v2 is using forbidden communities (public, etc.)
# ------------------------------------------------------------

@include "common/common.gawk"

BEGIN {
}

BEGINFILE {
	pass = 1 ;
}

/^snmp-agent community/ && /(private|public)/{
	print_err("snmp_v1v2forbidcommunity_notset.huawei.gawk",$0,FNR,"high","error");
	pass = 0;
}

ENDFILE {
	if ( pass ) print_err("snmp_v1v2forbidcommunity_notset.huawei.gawk","snmp v1v2 do not use forbidden communities",0,"high","pass");
}

END {
}
