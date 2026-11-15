BEGIN {
	cawk_init_hypercube_rules()
	cawk_add_hypercube_rules("t", "r1", "permit", "none", "none", "all", "obj_servers", "host", 0, 0, "any", "any", 0, 0, "ip")
	cawk_add_hypercube_rules("t", "r2", "deny", "none", "none", "all", "0.0.0.0", "host", 0, 0, "any", "any", 0, 0, "ip")
	cawk_add_hypercube_rules("t", "r3", "permit", "none", "none", "all", "10.0.0.300", "host", 0, 0, "any", "any", 0, 0, "ip")
	print "cube verdict : " (( cawk_hypercube_rules_assessment() ) ? "pass" : "found")
}
