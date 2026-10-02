#%SED_GAWK_PATH%

# -------------------------------------------------------------------
# cawk is subject to a MIT open-source licence
# please refer to the MIT licence file for further information
#
# for %SED_VAR% change like GAWK_PATH, etc. please refer to
# file support/tests.sed for further information
#
# @test_name : int_ipv6redirects_notset.cisco-ios.gawk
# @supplier : cisco-ios
# @purpose : check if an interface with IPv6 has <no ipv6 redirects>
# @description : ipv6 redirects are enabled by default and can be spoofed to redirect traffic through attacker-controlled nodes, enabling man-in-the-middle attacks
# @actions : set <no ipv6 redirects> on all interfaces with IPv6 addressing (please refer to engineering/operations guidelines for further information)
# @nist800-53_ref : SI-2 | System and Information Integrity | Ensure flaw remediation and patching is configured
# @risk_level : high
# @authors : cedric llorens
# -------------------------------------------------------------------

@include %SED_INCLUDE_PATH%

# ----

include(`cawk.m4')

BEGIN {
}

BEGINFILE {
	pass = 1;
}

dnl MACRO BEGIN --------------------------

m4_cawk_parse_block(

dnl level 0 --
`/^interface .*$/ && !/[Ll]oopback/',`
	interface = $0;
	interfaceno = FNR;
	has_ipv6 = 0;
	ipv6redirects_disabled = 0;
	ipv6_addr = "";
	is_shutdown = 0;
',
`/^!$/', `
	if ( has_ipv6 == 1 && ipv6redirects_disabled == 0 && is_shutdown == 0 ) {
		print_err("int_ipv6redirects_notset.cisco-ios.gawk",interface" "ipv6_addr" <no ipv6 redirects> is not set",interfaceno,"high","error");
		pass = 0;
	}
',

dnl level 1 --
`/^ (ipv6 address|no ipv6 redirects|shutdown)/',`
	if ($0 ~ /^ ipv6 address/) { has_ipv6 = 1; ipv6_addr = $3; }
	if ($0 ~ /^ no ipv6 redirects/) ipv6redirects_disabled = 1;
	if ($0 ~ /^ shutdown/) is_shutdown = 1;
',
`', `'

)

dnl MACRO END ---------------------------

ENDFILE {
	if ( pass ) print_err("int_ipv6redirects_notset.cisco-ios.gawk","interface <no ipv6 redirects> is properly set",0,"high","pass");
}

END {
}
