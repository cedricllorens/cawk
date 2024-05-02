#!/usr/bin/env -S gawk -f
# ------------------------------------------------------------
# cawk is subjet to a MIT open-source licence
# please refer to the MIT licence file for further information
# ------------------------------------------------------------
#

@include "firewall_function.include"

# -------------------------------

BEGIN {
	cawk_init_fw_rules()
}

/^.*$/ {

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
        # ----
        # file format ----------------------------------

	cawk_add_fw_rules("fw_generic-check_generic.gawk","filter_name",$1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
}

END { 
	cawk_fw_rules_assessment()
}

