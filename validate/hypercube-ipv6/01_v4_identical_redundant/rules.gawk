BEGIN {
	cawk_init_hypercube_rules()
	cawk_add_hypercube_rules("t", "r1", "pass", "in", "em0", "all", "10.0.0.0", "8", 0, 0, "any", "any", 0, 0, "tcp")
	cawk_add_hypercube_rules("t", "r2", "pass", "in", "em0", "all", "10.0.0.0", "8", 0, 0, "any", "any", 0, 0, "tcp")
	print "cube verdict : " (( cawk_hypercube_rules_assessment() ) ? "pass" : "found")
}
