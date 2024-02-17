#!/usr/bin/env -S gawk -f

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : this test generates an error if service-password encryption is not set
# ------------------------------------------------------------

@include "common/common.gawk"

BEGIN {
}

BEGINFILE {
	pass = 1;
}

/^service password-encryption/ {
	print_err("global_servicepassword_set.cisco-ios.gawk",$0,FNR,"high","pass");
	pass = 0;
	nextfile;
}

ENDFILE {
	if ( pass ) print_err("global_servicepassword_set.cisco-ios.gawk","service password-encryption is not set",0,"high","error");
}

END {
}
