.PHONY: check

check:
	@echo "generic formatted acl -------------------------"
	./fw_generic-check_generic.gawk ./rules	
	@echo "cisco-ios acl std oneline ---------------------"
	./fw_acl-stdline-check_cisco-ios.gawk ./rules_stdline_cisco-ios	
	@echo "cisco-ios acl std -----------------------------"
	./fw_acl-std-check_cisco-ios.gawk ./rules_std_cisco-ios	
