BEGIN {
	cawk_init_hypercube_rules()
	cawk_add_hypercube_rules("t", "r1", "pass", "in", "em0", "inet6", "::ffff:192.0.2.1", "host", 0, 0, "any", "any", 0, 0, "tcp")
	cawk_add_hypercube_rules("t", "r2", "pass", "in", "em0", "inet6", "::ffff:192.0.2.1", "host", 0, 0, "any", "any", 0, 0, "tcp")
	print "cube verdict : " (( cawk_hypercube_rules_assessment() ) ? "pass" : "found")
}
