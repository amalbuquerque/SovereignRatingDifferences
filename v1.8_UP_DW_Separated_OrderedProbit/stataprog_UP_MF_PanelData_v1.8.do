* Panel Data Models in Stata
* Copyright 2016 by Andre Albuquerque

clear all
set more off
* set trace on


* 2016/09/11 09:17:55, AA: From esttab documentation (don't work)
capture program drop transpose_esttab
program define transpose_esttab

matrix C = r(coefs)

eststo clear

local rnames : rownames C

local models : coleq C

local models : list uniq models

local i 0

foreach name of local rnames {
    local ++i
    local j 0
    capture matrix drop b
    capture matrix drop se
    foreach model of local models {
        local ++j
        matrix tmp = C[`i', 2*`j'-1]
        if tmp[1,1]<. {
            matrix colnames tmp = `model'
            matrix b = nullmat(b), tmp
            matrix tmp[1,1] = C[`i', 2*`j']
            matrix se = nullmat(se), tmp
        }
    }
    ereturn post b
    quietly estadd matrix se
    eststo `name'
}

end

* It only works in the ~\Documents directory
cd C:\Users\ADMIN\Documents\SovereignRatingDifferences
cd v0.8_UP_DW_Separated_OrderedProbit
import delimited using UP_MF_PanelData, delimiters(";") clear

* We can't xtset string variables, so we have to generate a new numeric column
* countryno based on the country2code value
encode country2code, gen(countryno)

global id countryno
global t year
global ylist diff_up_mf
global allx_list ngdpdpc_var ngdp_rpch extdebtpercgni_var ggxwdg_ngdp_var ggxwdn_ngdp_var budgetbal_ngdp_var ggsb_npgdp pcpipch defaultlastyear defaultlast2years defaultlast5years defaultlast10years

* Gross debt have more 5% +- observations than net debt
* Gross debt and net debt are correlated with budget balance, so have to be regressed in separate
* Structural balance is also correlated with budget balance, so have to be regressed (to confirm?!)

* These lists only have gross debt
global xlist_grossdebt_deflast1 c.ngdpdpc_var c.ngdp_rpch c.extdebtpercgni_var c.ggxwdg_ngdp_var c.pcpipch i.defaultlastyear
global xlist_grossdebt_deflast2 c.ngdpdpc_var c.ngdp_rpch c.extdebtpercgni_var c.ggxwdg_ngdp_var c.pcpipch i.defaultlast2years
global xlist_grossdebt_deflast5 c.ngdpdpc_var c.ngdp_rpch c.extdebtpercgni_var c.ggxwdg_ngdp_var c.pcpipch i.defaultlast5years
global xlist_grossdebt_deflast10 c.ngdpdpc_var c.ngdp_rpch c.extdebtpercgni_var c.ggxwdg_ngdp_var c.pcpipch i.defaultlast10years

* These lists only have net debt
global xlist_netdebt_deflast1 c.ngdpdpc_var c.ngdp_rpch c.extdebtpercgni_var c.ggxwdn_ngdp_var c.pcpipch i.defaultlastyear
global xlist_netdebt_deflast2 c.ngdpdpc_var c.ngdp_rpch c.extdebtpercgni_var c.ggxwdn_ngdp_var c.pcpipch i.defaultlast2years
global xlist_netdebt_deflast5 c.ngdpdpc_var c.ngdp_rpch c.extdebtpercgni_var c.ggxwdn_ngdp_var c.pcpipch i.defaultlast5years
global xlist_netdebt_deflast10 c.ngdpdpc_var c.ngdp_rpch c.extdebtpercgni_var c.ggxwdn_ngdp_var c.pcpipch i.defaultlast10years

* These lists only have budget balance
global xlist_budgetbal_deflast1  c.ngdpdpc_var c.ngdp_rpch c.extdebtpercgni_var c.budgetbal_ngdp_var c.pcpipch i.defaultlastyear
global xlist_budgetbal_deflast2  c.ngdpdpc_var c.ngdp_rpch c.extdebtpercgni_var c.budgetbal_ngdp_var c.pcpipch i.defaultlast2years
global xlist_budgetbal_deflast5  c.ngdpdpc_var c.ngdp_rpch c.extdebtpercgni_var c.budgetbal_ngdp_var c.pcpipch i.defaultlast5years
global xlist_budgetbal_deflast10 c.ngdpdpc_var c.ngdp_rpch c.extdebtpercgni_var c.budgetbal_ngdp_var c.pcpipch i.defaultlast10years

* These lists only have structural balance
global xlist_structbal_deflast1  c.ngdpdpc_var c.ngdp_rpch c.extdebtpercgni_var c.ggsb_npgdp c.pcpipch i.defaultlastyear
global xlist_structbal_deflast2  c.ngdpdpc_var c.ngdp_rpch c.extdebtpercgni_var c.ggsb_npgdp c.pcpipch i.defaultlast2years
global xlist_structbal_deflast5  c.ngdpdpc_var c.ngdp_rpch c.extdebtpercgni_var c.ggsb_npgdp c.pcpipch i.defaultlast5years
global xlist_structbal_deflast10 c.ngdpdpc_var c.ngdp_rpch c.extdebtpercgni_var c.ggsb_npgdp c.pcpipch i.defaultlast10years

* Set data as panel data
sort $id $t
xtset $id $t
xtdescribe
* xtsum $id $t $ylist $xlist_grossdebt_deflast1
* xtsum $id $t $ylist $xlist_grossdebt_deflast2
* xtsum $id $t $ylist $xlist_grossdebt_deflast5
* xtsum $id $t $ylist $xlist_grossdebt_deflast10

foreach s in grossdebt {
* foreach s in grossdebt netdebt budgetbal structbal {

    foreach y in 1 2 {
    * foreach y in 1 2 5 10 {
        quietly xtoprobit $ylist ${xlist_`s'_deflast`y'}, vce(robust)
        * estimates store oprob, title (DefLastY)
        eststo `s'_OP_`y', title (`s'Default`y')

        * when ratingDiff = 0-2, 0-2.diff_up_mf
        foreach o in 0 1 2 {
            quietly margins, dydx(*) predict(pu0 outcome(`o')) post
            eststo `s'_ME`o'_Def`y', title (MERat`o'_`s'_Def`y')
            estimates restore `s'_OP_`y'
        }
    }

    * showing in a nice format and storing it in a .csv file to import to Word

    * 2016/09/11 08:42:13, AA: From http://www.statalist.org/forums/forum/general-stata-discussion/general/1328362-writing-to-a-file-using-esttab-r-coefs-transpose IT WORKED BUT WITHOUT SIGNIFICANCE STARS
    * esttab using r, mtitles replace star(* 0.10 ** 0.05 *** 0.01) pr2 legend label varlabels(_cons Const)
    * mat list r(coefs)
    * mat rename r(coefs) foo
    * mat list foo
    * esttab matrix(foo, transpose) using UP_MF_`s'_results_dynamic_CHECK3.csv, mtitles replace star(* 0.10 ** 0.05 *** 0.01) pr2 legend label varlabels(_cons Const)

    esttab, mtitles replace star(* 0.10 ** 0.05 *** 0.01) pr2 legend label varlabels(_cons Const)
    transpose_esttab

    * 2016/09/10 23:28:09, AA: al-sakka show the t-statistics, so we show it as well
    esttab using UP_MF_`s'_results_dynamic_CHECK4.csv, mtitles replace star(* 0.10 ** 0.05 *** 0.01) pr2 legend label varlabels(_cons Const)

    * clear the stored results to run again
    eststo clear
    estimates clear
}
