BEGIN {
	cawk_init_hypercube_rules()
	cawk_add_hypercube_rules("t", "r1", "pass", "in", "em0", "all", "10.0.0.0", "8", 0, 0, "any", "any", 0, 0, "tcp", "", "A", 10)
	cawk_add_hypercube_rules("t", "r2", "pass", "in", "em0", "all", "10.0.0.0", "9", 0, 0, "any", "any", 0, 0, "tcp", "", "B", 20)
	cawk_add_hypercube_rules("t", "r3", "pass", "in", "em0", "all", "10.1.0.0", "16", 0, 0, "any", "any", 0, 0, "tcp", "", "C", 30)
	cawk_add_hypercube_rules("t", "r4", "block", "in", "em0", "all", "10.1.1.1", "host", 0, 0, "any", "any", 0, 0, "tcp", "", "D", 40)
	print "cube verdict : " (( cawk_hypercube_rules_assessment() ) ? "pass" : "found")
}
