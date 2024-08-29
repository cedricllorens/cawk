dnl ------------------------------------------------------------
dnl cawk is subjet to a MIT open-source licence
dnl please refer to the MIT licence file for further information
dnl ------------------------------------------------------------

dnl ---------------------------------------------------
dnl m4_cawk_exception($1,$2,$3)
dnl  $1 : device name   : extended regex
dnl  $2 : test name     : extended regex
dnl  $3 : error message : extended regex
dnl ---------------------------------------------------

define(`m4_cawk_exception', `
ifelse($1,`',`[^;]*',`[^;]*'$1`[^;]*')`;'ifelse($2,`',`[^;]*',`[^;]*'$2`[^;]*')`;'ifelse($3,`',`[^;]*',`[^;]*'$3`[^;]*')`;'
')

dnl ---------------------------------------------------
dnl m4_cawk_parse_block macro generates awk pgm
dnl while managing block level automatically (bl_level)
dnl ---------------------------------------------------

define(`BL_LEVEL', 0)

define(`m4_cawk_parse_block', `
ifelse($#, 1, `', `
ifelse(eval(BL_LEVEL>=1),1,`$1 && bl_level == BL_LEVEL {', `$1 {')
    ifelse($3,`',`bl_level = BL_LEVEL;',`define(`BL_LEVEL', incr(BL_LEVEL))bl_level = BL_LEVEL;')
    $2
    ifelse(BL_LEVEL,`0',`',`next;')
}
ifelse($3,`',`',`
ifelse(eval(BL_LEVEL>=1),1,`$3 && bl_level == BL_LEVEL {', `$3 {')
    define(`BL_LEVEL', decr(BL_LEVEL))bl_level = BL_LEVEL;define(`BL_LEVEL', incr(BL_LEVEL))
    $4
    next;
}')
m4_cawk_parse_block(shift(shift(shift(shift($@)))))'
)')
