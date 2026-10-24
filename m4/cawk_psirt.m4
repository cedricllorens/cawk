dnl ------------------------------------------------------------
dnl cawk is subject to a MIT open-source licence
dnl please refer to the MIT licence file for further information
dnl ------------------------------------------------------------

dnl ---------------------------------------------------
dnl Declarative macros of a psirt test (*.gawk.include.m4)
dnl they generate the load_psirt_config() of a *.gawk.include,
dnl indexes are automatic and every LINE/BLOCK/BLOCK_LINE gets a name
dnl usable in psirt_logic().
dnl
dnl Always quote the arguments (`name'): a name already defined is expanded.
dnl Do not use a name of a m4 builtin (index, len, format, ...).
dnl ---------------------------------------------------

define(`_PSIRT_OSN', 0)
define(`_PSIRT_CMPN', 0)
define(`_PSIRT_LINEN', 0)
define(`_PSIRT_BLKN', 0)

dnl psirt_begin / psirt_end : the function of the generated include
define(`psirt_begin', `function load_psirt_config() {
dnl')
define(`psirt_end', `}
dnl')

dnl psirt_device(regex) : regex matching the configuration file name
define(`psirt_device', `    DEVICE = "$1"
dnl')

dnl psirt_os(regex) : regex matching "version chassis cpu"
define(`psirt_os', `define(`_PSIRT_OSN', incr(_PSIRT_OSN))    OS[_PSIRT_OSN] = "$1"
dnl')

dnl _psirt_os_cmp(op, min, max, platform) : version comparison, platform = optional regex matching "chassis cpu"
define(`_psirt_os_cmp', `define(`_PSIRT_CMPN', incr(_PSIRT_CMPN))    OS_CMP[_PSIRT_CMPN]["op"] = "$1"
    OS_CMP[_PSIRT_CMPN]["min"] = "$2"
ifelse(`$3', `', `', `    OS_CMP[_PSIRT_CMPN]["max"] = "$3"
')ifelse(`$4', `', `', `    OS_CMP[_PSIRT_CMPN]["platform"] = "$4"
')dnl')

dnl psirt_os_eq / lt / le / gt / ge (version [, platform]) : version ==, <, <=, >, >= version
define(`psirt_os_eq', `_psirt_os_cmp(`eq', `$1', `', `$2')')
define(`psirt_os_lt', `_psirt_os_cmp(`lt', `$1', `', `$2')')
define(`psirt_os_le', `_psirt_os_cmp(`le', `$1', `', `$2')')
define(`psirt_os_gt', `_psirt_os_cmp(`gt', `$1', `', `$2')')
define(`psirt_os_ge', `_psirt_os_cmp(`ge', `$1', `', `$2')')

dnl psirt_os_between(min, max [, platform]) : min <= version <= max
define(`psirt_os_between', `_psirt_os_cmp(`between', `$1', `$2', `$3')')

dnl psirt_line(name, regex) : a line of the configuration, name -> LINE[n]
define(`psirt_line', `define(`_PSIRT_LINEN', incr(_PSIRT_LINEN))define(`$1', `LINE['_PSIRT_LINEN`]')    LINE[_PSIRT_LINEN] = "$2"
dnl')

dnl psirt_block(name, start_regex, end_regex) : a block of the configuration, name -> BLOCK[n] (the block exists)
define(`psirt_block', `define(`_PSIRT_BLKN', incr(_PSIRT_BLKN))define(`_PSIRT_BLKIDX_$1', _PSIRT_BLKN)define(`_PSIRT_BLKLN_$1', 0)define(`$1', `BLOCK['_PSIRT_BLKN`]')    BLOCK[_PSIRT_BLKN]["start"] = "$2"
    BLOCK[_PSIRT_BLKN]["end"] = "$3"
dnl')

dnl psirt_block_line(block, name, regex) : a line inside a declared block, name -> BLOCK_LINE[n][m]
define(`_psirt_blk_chk', `ifelse(defn(`_PSIRT_BLKIDX_$1'), `', `errprint(`cawk error: psirt_block_line: undeclared block <$1>
')m4exit(1)')')
define(`psirt_block_line', `_psirt_blk_chk(`$1')define(`_PSIRT_BLKLN_$1', incr(indir(`_PSIRT_BLKLN_$1')))define(`$2', `BLOCK_LINE['indir(`_PSIRT_BLKIDX_$1')`]['indir(`_PSIRT_BLKLN_$1')`]')    BLOCK[indir(`_PSIRT_BLKIDX_$1')]["match"][indir(`_PSIRT_BLKLN_$1')] = "$3"
dnl')

dnl psirt_logic(expression) : boolean expression of the names above
define(`psirt_logic', `    LOGIC = "$1"
dnl')
