#!/usr/bin/env -S gawk -f

# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
#
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# purpose : this test generate an error when an filter is def and not ref
# purpose : this test generate an error when an filter is ref and not def
# ------------------------------------------------------------

@include "common/common.gawk"

BEGIN {
}

BEGINFILE {
	pass = 1;
	delete filter_ref;
	delete filter_def;
}

# def ----

/^[ ]+filter [^ ]+ {/ {
	filter_def[$2] = rm_last_char(rm_blank_before($0));
	next;
}

# ref ----

/^[ ]+(input|output) [^ ]+;/ {
	filter_ref[$2] = rm_last_char(rm_blank_before($0));
	next;
}

ENDFILE {

	# acl def and not ref ----
	for (id in filter_def) {
		if ( !(id in filter_ref) ) {
			print_err("filter_defref_set.juniper-junos.gawk",id" : filter def but not ref :"filter_def[id],0,"low","error");
			pass = 0;
		}
	}

	# acl ref and not def ----
	for (id in filter_ref) {
		if ( !(id in filter_def) ) {
			print_err("filter_defref_set.juniper-junos.gawk",id" : filter ref but not def :"filter_ref[id],0,"high","error");
			pass = 0;
		}
	}

	if ( pass ) print_err("filter_defref_set.juniper-junos.gawk","all filters defs are refs and the reverse",0,"high","pass");
}

END {
}
