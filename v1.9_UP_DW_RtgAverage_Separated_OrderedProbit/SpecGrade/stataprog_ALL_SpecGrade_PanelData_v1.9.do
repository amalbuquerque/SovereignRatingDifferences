* Panel Data Models in Stata
* Copyright 2016 by Andre Albuquerque

* It only works in the ~\Documents directory
cd C:\Users\ADMIN\Documents\SovereignRatingDifferences
cd v1.9_UP_DW_RtgAverage_Separated_OrderedProbit
cd SpecGrade

* 2016/09/11 12:43:49, AA: easier to maintain one script than dozens
foreach pair in up_mf up_sm up_sf dw_mf dw_sm dw_sf {

clear all
set more off
* set trace on


* import delimited using UP_MF_PanelData, delimiters(";") clear
import delimited using `pair'_SpecGrade_PanelData_WithAvgRating, delimiters(";") clear

* We can't xtset string variables, so we have to generate a new numeric column
* countryno based on the country2code value
encode country2code, gen(countryno)

global id countryno
global t year
* global ylist diff_up_mf
global ylist diff_`pair'
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

foreach s in grossdebt netdebt budgetbal structbal {

    foreach y in 1 2 5 10 {
        * running the ordered probit
        quietly xtoprobit $ylist ${xlist_`s'_deflast`y'}, vce(robust)
        * estimates store oprob, title (DefLastY)
        eststo `s'_OP_`y', title (`s'Default`y')

        * getting the marginal effects
        * when ratingDiff = 0-2, 0-2.diff_up_mf
        foreach o in 0 1 2 {
            quietly margins, dydx(*) predict(pu0 outcome(`o')) post
            eststo `s'_ME`o'_Def`y', title (MERat`o'_`s'_Def`y')
            estimates restore `s'_OP_`y'
        }
    }

    * showing in a nice format and storing it in a .csv file to import to Word

    * 2016/09/11 08:42:13, AA: From http://www.statalist.org/forums/forum/general-stata-discussion/general/1328362-writing-to-a-file-using-esttab-r-coefs-transpose IT WORKED BUT WITHOUT SIGNIFICANCE STARS
    *esttab using r, mtitles replace star(* 0.10 ** 0.05 *** 0.01) pr2 legend label varlabels(_cons Const)

    * 2016/09/10 23:28:09, AA: al-sakka show the t-statistics, so we show it as well
    * the default way is to place each model on each column
    * esttab using UP_MF_`s'_results_wide.csv, mtitles replace star(* 0.10 ** 0.05 *** 0.01) pr2 legend label varlabels(_cons Const)
    esttab using `pair'_`s'_SpecGrade_results_wide.csv, mtitles replace star(* 0.10 ** 0.05 *** 0.01) pr2 legend label varlabels(_cons Const)

    mat list r(coefs)
    mat rename r(coefs) foo`pair'`s'
    mat list foo`pair'`s'
    * to get the results transposed
    esttab matrix(foo`pair'`s', transpose) using `pair'_`s'_SpecGrade_results_transpose.csv, mtitles replace star(* 0.10 ** 0.05 *** 0.01) pr2 legend label varlabels(_cons Const)

    * clear the stored results to run again
    eststo clear
    estimates clear
}

* ends the foreach from the 9th line
}
