BEGIN {
	cawk_init_hypercube_rules()
	cawk_add_hypercube_rules("t", "r1", "permit", "none", "none", "all", "10.1.0.0", "255.255.0.0", 0, 0, "any", "any", 0, 0, "ip")
	cawk_add_hypercube_rules("t", "r2", "permit", "none", "none", "all", "10.1.2.0", "24", 0, 0, "any", "any", 0, 0, "ip")
	cawk_add_hypercube_rules("t", "r3", "permit", "none", "none", "all", "10.2.0.0", "24", 0, 0, "any", "any", 0, 0, "ip")
	print "cube verdict : " (( cawk_hypercube_rules_assessment() ) ? "pass" : "found")
}
