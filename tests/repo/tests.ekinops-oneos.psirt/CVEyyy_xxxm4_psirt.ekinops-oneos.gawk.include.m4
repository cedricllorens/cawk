include(`cawk_psirt.m4')dnl
# ====================================================================================
# PSIRT VULNERABILITY ASSESSMENT - macros of m4/cawk_psirt.m4 (compiled to a .gawk.include)
# ====================================================================================
# the macros number the patterns, every line and block gets a name used in psirt_logic()
#   psirt_device(regex)                      file name of the configuration
#   psirt_os(regex)                          regex on "version chassis cpu" (inventory value)
#   psirt_os_eq|lt|le|gt|ge(v [,platform])   version comparison, platform = regex on "chassis cpu"
#   psirt_os_between(min, max [,platform])   min <= version <= max
#   psirt_line(name, regex)                  a line of the configuration
#   psirt_block(name, start, end)            a block (exists when start and end are found)
#   psirt_block_line(block, name, regex)     a line inside the block
#   psirt_logic(expression)                  expression of the names above, 1 = present, 0 = absent
# the arguments are always quoted, a name must not be a m4 builtin
#
# @test_name : CVEyyy_xxxm4_psirt.ekinops-oneos.gawk
# @supplier : ekinops-oneos
# @purpose : PSIRT vulnerability assessment template (m4 macros) for Ekinops OneOS
# @description : generic pattern-based vulnerability detection tool (m4 macros) for Ekinops OneOS devices - configure CVE-specific OS patterns, line patterns, block patterns, and logic in the USER section
# @actions : configure CVE-specific patterns in the USER section (please refer to engineering/operations guidelines for further information)
# @nist800-53_ref : SI-2 | System and Information Integrity | Ensure flaw remediation and patching is configured
# @risk_level : high | medium | low | info
# @authors : cedric llorens
# ====================================================================================

psirt_begin
psirt_device(`^.*')

dnl version range instead of the regexes 2\\..* .* .* / 3\\..* .* .*
psirt_os_between(`2.0', `3.99')

psirt_line(`line_1', `systemFAKE hostname')
psirt_line(`line_2', `port name')

psirt_block(`block_1', `^serviceFAKE ', `^$')
psirt_block_line(`block_1', `block_1_line_1', `^ bandwidth')
psirt_block_line(`block_1', `block_1_line_2', `^ priority')

psirt_block(`block_2', `^interface ', `^$')
psirt_block_line(`block_2', `block_2_line_1', `^  mtu')
psirt_block_line(`block_2', `block_2_line_2', `^  enabled')

psirt_logic(`line_1 == 1 && line_2 == 1 && block_1 == 1 && block_1_line_1 == 0')
psirt_end
