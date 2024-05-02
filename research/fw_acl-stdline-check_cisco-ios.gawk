#!/usr/bin/env -S gawk -f
# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
#

# file format ----------------------------------
# action           : permit/deny
# src@             : ip
# src_net@         : cird/netmask
# port_src         : port_src		set 0 if empty
# port_src_range   : port_src_range	set 0 if empty
# dst@             : ip			set 0 if empty
# dst_net@         : cird/netmask	set 0 if empty
# port_dst         : port_dst		set 0 if empty
# port_dst_range   : port_dst_range	set 0 if empty
# protocol         : protocol		set none if empty
# file format ----------------------------------

@include "firewall_function.include"

BEGIN {
}

BEGINFILE {
	cawk_init_fw_rules();
	acl = "";
}

/^access-list [0-9]+ (permit|deny) ([0-9\.]+ [0-9\.]+|any)$/ {
	if ( acl != $2 ) {
		if ( cawk_fw_rules_assessment() && acl != "" ) {
			print_err("fw_acl-stdline-check_cisco-ios.gawk","access-list "acl" has no redundant/inconsistent rules",FNR,"high","pass");
		}
		cawk_init_fw_rules();
	}
	acl = $2;
	cawk_add_fw_rules("fw_acl-stdline-check_cisco-ios.gawk","access-list "acl,$3,$4,$5,0,0,0,0,0,0,none)
}

/^(!|end)$/ && acl != "" {
	if ( cawk_fw_rules_assessment() ) {
		print_err("fw_acl-stdline-check_cisco-ios.gawk","access-list "acl" has no redundant/inconsistent rules",FNR,"high","pass");
	}
	acl = "";
}

ENDFILE { 
}

END {
}
