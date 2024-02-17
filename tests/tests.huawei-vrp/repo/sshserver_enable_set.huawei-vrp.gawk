#!/usr/bin/env -S gawk -f

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : this test generates an error if ssh server is no set
# ------------------------------------------------------------

@include "common/common.gawk"

BEGIN {
}

BEGINFILE {
	pass = 0 ;
}

/^ssh server enable/ {
	print_err("sshserver_enable_set.huawei.gawk",$0,FNR,"high","pass");
	pass = 1;
	nextfile;
}

ENDFILE {
	if ( !pass ) print_err("sshserver_enable_set.huawei.gawk","ssh server is not set",0,"high","error");
}

END {
}
