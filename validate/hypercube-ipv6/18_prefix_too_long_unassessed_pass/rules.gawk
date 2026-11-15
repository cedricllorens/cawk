BEGIN {
	cawk_init_hypercube_rules()
	cawk_add_hypercube_rules("t", "r1", "permit", "none", "none", "all", "10.0.0.1", "33", 0, 0, "any", "any", 0, 0, "ip")
	cawk_add_hypercube_rules("t", "r2", "deny", "none", "none", "all", "10.0.0.1", "host", 0, 0, "any", "any", 0, 0, "ip")
	cawk_add_hypercube_rules("t", "r3", "deny", "none", "none", "all", "2001:db8::1", "129", 0, 0, "any", "any", 0, 0, "ip")
	cawk_add_hypercube_rules("t", "r4", "permit", "none", "none", "all", "2001:db8::1", "host", 0, 0, "any", "any", 0, 0, "ip")
	print "cube verdict : " (( cawk_hypercube_rules_assessment() ) ? "pass" : "found")
}
