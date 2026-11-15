BEGIN {
	cawk_init_hypercube_rules()
	cawk_add_hypercube_rules("t", "r1", "pass", "in", "em0", "all", "10.0.0.0", "8", 0, 0, "any", "any", 22, 0, "tcp", "", 10)
	cawk_add_hypercube_rules("t", "r2", "block", "in", "em0", "all", "any", "any", 0, 0, "10.1.0.0", "16", 0, 0, "tcp", "", 20)
	print "cube verdict : " (( cawk_hypercube_rules_assessment() ) ? "pass" : "found")
}
