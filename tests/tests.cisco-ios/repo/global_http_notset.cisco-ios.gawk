#!/usr/bin/env -S gawk -f

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : this test generates an error if a http statement is set
# ------------------------------------------------------------

@include "common/common.gawk"

BEGIN {
}

BEGINFILE {
	pass = 1;
}

/^(ip )?http(s)? / {
	print_err("global_http_notset.cisco-ios.gawk",$0,FNR,"high","error");
        pass = 0;
}

ENDFILE {
        if ( pass ) print_err("global_http_notset.cisco-ios.gawk","http statement not set",0,"high","pass");
}

END {
}
