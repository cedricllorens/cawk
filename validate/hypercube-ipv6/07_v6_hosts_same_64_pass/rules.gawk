BEGIN {
	cawk_init_hypercube_rules()
	cawk_add_hypercube_rules("t", "r1", "pass", "in", "em0", "inet6", "2001:db8:0:f00d::1", "host", 0, 0, "any", "any", 0, 0, "tcp")
	cawk_add_hypercube_rules("t", "r2", "pass", "in", "em0", "inet6", "2001:db8:0:f00d::2", "host", 0, 0, "any", "any", 0, 0, "tcp")
	print "cube verdict : " (( cawk_hypercube_rules_assessment() ) ? "pass" : "found")
}
