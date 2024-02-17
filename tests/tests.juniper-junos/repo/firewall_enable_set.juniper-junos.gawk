#!/usr/bin/env -S gawk -f

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : this test check if a firewall block has been defined
# ------------------------------------------------------------

@include "common/common.gawk"

BEGIN {
}

BEGINFILE {
	pass = 0;
}

/^firewall {/ {
	print_err("firewall_enable_set.juniper-junos.gawk",$0,FNR,"high","pass");
        pass = 1;
}

ENDFILE {
        if ( ! pass ) print_err("firewall_enable_set.juniper-junos.gawk","firewall block has not been detected",0,"high","error");
}

END {
}
