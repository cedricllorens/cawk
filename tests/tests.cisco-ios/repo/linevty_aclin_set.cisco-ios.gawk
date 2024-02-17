#!/usr/bin/env -S gawk -f

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : this test generate an error if a line vty has no access-class in
# ------------------------------------------------------------

@include "common/common.gawk"

# ----

function acl_summary() {
	if ( aclin == 0 ) {
		print_err("linevty_aclin_set.cisco-ios.gawk",linevty" : acl in missing",linenovty,"high","error");
		pass = 0;
	}
}

# ----

BEGIN {
}

BEGINFILE {
	block_vty = 0;
	pass = 1;
}

/^line vty .*$/ {
	if ( block_vty == 1 ) acl_summary();
	linevty = $0;
	linenovty = FNR;
	aclin = 0;
        block_vty = 1;
	next;
}

/^ access-class .* in/ && block_vty == 1 {
	aclin = 1;
	next;
}

/^!$/ && block_vty == 1 {
	acl_summary();
	block_vty = 0;
}

ENDFILE {
	if ( pass ) print_err("linevty_aclin_set.cisco-ios.gawk","line vty acls in are set",0,"high","pass");
}

END {
}
