* Panel Data Models in Stata
* Copyright 2016 by Andre Albuquerque

clear all
set more off

* It only works in the ~\Documents directory
cd C:\Users\ADMIN\Documents\SovereignRatingDifferences
cd v0.9_UP_DW_RtgAverage_Separated
import delimited using DW_MF_InvGrade_PanelData_WithAvgRating, delimiters(";") clear

* We can't xtset string variables, so we have to generate a new numeric column
* countryno based on the country2code value
encode country2code, gen(countryno)

global id countryno
global t year
global ylist diff_dw_mf
global allx_list ngdpdpc_var ngdp_rpch extdebtpercgni_var ggxwdg_ngdp_var ggxwdn_ngdp_var budgetbal_ngdp_var ggsb_npgdp pcpipch defaultlastyear defaultlast2years defaultlast5years defaultlast10years

* Gross debt have more 5% +- observations than net debt
* Gross debt and net debt are correlated with budget balance, so have to be regressed in separate
* Structural balance is also correlated with budget balance, so have to be regressed (to confirm?!)

* These lists only have gross debt
global xlist_grossdebt_deflast1 ngdpdpc_var ngdp_rpch extdebtpercgni_var ggxwdg_ngdp_var pcpipch defaultlastyear
global xlist_grossdebt_deflast2 ngdpdpc_var ngdp_rpch extdebtpercgni_var ggxwdg_ngdp_var pcpipch defaultlast2years
global xlist_grossdebt_deflast5 ngdpdpc_var ngdp_rpch extdebtpercgni_var ggxwdg_ngdp_var pcpipch defaultlast5years
global xlist_grossdebt_deflast10 ngdpdpc_var ngdp_rpch extdebtpercgni_var ggxwdg_ngdp_var pcpipch defaultlast10years

* These lists only have net debt
global xlist_netdebt_deflast1 ngdpdpc_var ngdp_rpch extdebtpercgni_var ggxwdn_ngdp_var pcpipch defaultlastyear
global xlist_netdebt_deflast2 ngdpdpc_var ngdp_rpch extdebtpercgni_var ggxwdn_ngdp_var pcpipch defaultlast2years
global xlist_netdebt_deflast5 ngdpdpc_var ngdp_rpch extdebtpercgni_var ggxwdn_ngdp_var pcpipch defaultlast5years
global xlist_netdebt_deflast10 ngdpdpc_var ngdp_rpch extdebtpercgni_var ggxwdn_ngdp_var pcpipch defaultlast10years

* These lists only have budget balance
global xlist_budgetbal_deflast1 ngdpdpc_var ngdp_rpch extdebtpercgni_var budgetbal_ngdp_var pcpipch defaultlastyear
global xlist_budgetbal_deflast2 ngdpdpc_var ngdp_rpch extdebtpercgni_var budgetbal_ngdp_var pcpipch defaultlast2years
global xlist_budgetbal_deflast5 ngdpdpc_var ngdp_rpch extdebtpercgni_var budgetbal_ngdp_var pcpipch defaultlast5years
global xlist_budgetbal_deflast10 ngdpdpc_var ngdp_rpch extdebtpercgni_var budgetbal_ngdp_var pcpipch defaultlast10years

* These lists only have structural balance
global xlist_structbal_deflast1 ngdpdpc_var ngdp_rpch extdebtpercgni_var ggsb_npgdp pcpipch defaultlastyear
global xlist_structbal_deflast2 ngdpdpc_var ngdp_rpch extdebtpercgni_var ggsb_npgdp pcpipch defaultlast2years
global xlist_structbal_deflast5 ngdpdpc_var ngdp_rpch extdebtpercgni_var ggsb_npgdp pcpipch defaultlast5years
global xlist_structbal_deflast10 ngdpdpc_var ngdp_rpch extdebtpercgni_var ggsb_npgdp pcpipch defaultlast10years


describe $id $t $ylist $xlist
summarize $id $t $ylist $xlist

* Set data as panel data
sort $id $t
xtset $id $t
xtdescribe
xtsum $id $t $ylist $xlist

* Using Random-effects ordered probit model applied to the observations where
* Moody's rating is HIGHER than Fitch, using Robust standard errors
* estimates store is for the estout
* eststo is for esttab
* outreg2 shows an enormous table on word

* gross debt
* eststo: quietly xtoprobit $ylist $allx_list, vce(robust)
* estimates store mall, title (Model All)

eststo: quietly xtoprobit $ylist $xlist_grossdebt_deflast1, vce(robust)
estimates store m1, title (Model DefLastY)

eststo: quietly xtoprobit $ylist $xlist_grossdebt_deflast2, vce(robust)
estimates store m2, title (Model DefLast2Y)

eststo: quietly xtoprobit $ylist $xlist_grossdebt_deflast5, vce(robust)
estimates store m3, title (Model DefLast5Y)

eststo: quietly xtoprobit $ylist $xlist_grossdebt_deflast10, vce(robust)
estimates store m4, title (Model DefLast10Y)

* showing in a nice format and storing it in a .csv file to import to Word
* estout mall m1 m2 m3 m4, cells(b(star fmt(3)) se(par fmt(2))) legend label varlabels(_cons Constant)
estout m1 m2 m3 m4, starlevels(* 0.10 ** 0.05 *** 0.01) cells(b(star fmt(3)) se(par fmt(2))) legend label varlabels(_cons Constant)
esttab using DW_MF_gross_debt_InvGrade_results.csv, replace star(* 0.10 ** 0.05 *** 0.01)

* clear the stored results to run again
eststo clear
estimates clear

* net debt
eststo: quietly xtoprobit $ylist $xlist_netdebt_deflast1, vce(robust)
estimates store m1, title (Model DefLastY)

eststo: quietly xtoprobit $ylist $xlist_netdebt_deflast2, vce(robust)
estimates store m2, title (Model DefLast2Y)

eststo: quietly xtoprobit $ylist $xlist_netdebt_deflast5, vce(robust)
estimates store m3, title (Model DefLast5Y)

eststo: quietly xtoprobit $ylist $xlist_netdebt_deflast10, vce(robust)
estimates store m4, title (Model DefLast10Y)

* showing in a nice format and storing it in a .csv file to import to Word
estout m1 m2 m3 m4, starlevels(* 0.10 ** 0.05 *** 0.01) cells(b(star fmt(3)) se(par fmt(2))) legend label varlabels(_cons Constant)
esttab using DW_MF_net_debt_InvGrade_results.csv, replace star(* 0.10 ** 0.05 *** 0.01)

* clear the stored results to run again
eststo clear
estimates clear

* budget bal
eststo: quietly xtoprobit $ylist $xlist_budgetbal_deflast1, vce(robust)
estimates store m1, title (Model DefLastY)

eststo: quietly xtoprobit $ylist $xlist_budgetbal_deflast2, vce(robust)
estimates store m2, title (Model DefLast2Y)

eststo: quietly xtoprobit $ylist $xlist_budgetbal_deflast5, vce(robust)
estimates store m3, title (Model DefLast5Y)

eststo: quietly xtoprobit $ylist $xlist_budgetbal_deflast10, vce(robust)
estimates store m4, title (Model DefLast10Y)

* showing in a nice format and storing it in a .csv file to import to Word
estout m1 m2 m3 m4, starlevels(* 0.10 ** 0.05 *** 0.01) cells(b(star fmt(3)) se(par fmt(2))) legend label varlabels(_cons Constant)
esttab using DW_MF_budgetbal_InvGrade_results.csv, replace star(* 0.10 ** 0.05 *** 0.01)

* clear the stored results to run again
eststo clear
estimates clear

* struct bal
eststo: quietly xtoprobit $ylist $xlist_structbal_deflast1, vce(robust)
estimates store m1, title (Model DefLastY)

eststo: quietly xtoprobit $ylist $xlist_structbal_deflast2, vce(robust)
estimates store m2, title (Model DefLast2Y)

eststo: quietly xtoprobit $ylist $xlist_structbal_deflast5, vce(robust)
estimates store m3, title (Model DefLast5Y)

eststo: quietly xtoprobit $ylist $xlist_structbal_deflast10, vce(robust)
estimates store m4, title (Model DefLast10Y)

* showing in a nice format and storing it in a .csv file to import to Word
estout m1 m2 m3 m4, starlevels(* 0.10 ** 0.05 *** 0.01) cells(b(star fmt(3)) se(par fmt(2))) legend label varlabels(_cons Constant)
esttab using DW_MF_structbal_InvGrade_results.csv, replace star(* 0.10 ** 0.05 *** 0.01)

* clear the stored results to run again
eststo clear
estimates clear
