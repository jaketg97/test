* Outputs latex table to designated file path with correlation matrix results
* Syntax: corr_tex [list of variables in a string] [path and name of output file][all columns width, except first]
program corr_tex 
    local corr_vars `1'
    local out_file `2'
    local width_all `3'

    local num_vars: di wordcount("`corr_vars'")
    local extra_counter = `num_vars' + 1
    corr `corr_vars'
    mat A = r(C)

    local col_heads 
    foreach var of varlist `corr_vars' {
        local col_heads "`col_heads' & ``var''"
    }

    file open corrmat using "`out_file'", write replace
    file write corrmat "\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \begin{tabular}{@{\extracolsep{2pt}}{l}*{4}{>{\raggedright\arraybackslash}m{`width_all'cm}}@{}}  \toprule" _n  
    file write corrmat "\toprule"
    file write corrmat "  `col_heads'  \\     " _n         
    file write corrmat "\midrule" _n 

    local i = 1

    foreach var of varlist `corr_vars' {

        local varlab ``var''

        foreach j of numlist 1/`num_vars' {
            local col_`j': di %7.3f A[`i', `j']
        }


        local i = `i' + 1

        foreach blank of numlist `i'/`num_vars' {
            local col_`blank' ""
        }

        if `i' == `extra_counter' {
            local col_`num_vars' 1.000
        }

        local row "`varlab' "
        foreach k of numlist 1/`num_vars' {
            local row "`row' & `col_`k''"
        }

        file write corrmat "`row' \\ \addlinespace[3pt]" _n
    }

    file write corrmat "\bottomrule "
    file write corrmat "\end{tabularx}" _n 
    file close corrmat

end 