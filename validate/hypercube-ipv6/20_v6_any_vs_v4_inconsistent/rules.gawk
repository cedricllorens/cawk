BEGIN {
	cawk_init_hypercube_rules()
	cawk_add_hypercube_rules("t", "r1", "permit", "none", "none", "all", "any", "any", 0, 0, "any", "any", 0, 0, "ip")
	cawk_add_hypercube_rules("t", "r2", "deny", "none", "none", "all", "192.0.2.1", "host", 0, 0, "2001:db8::1", "host", 0, 0, "ip")
	print "cube verdict : " (( cawk_hypercube_rules_assessment() ) ? "pass" : "found")
}
