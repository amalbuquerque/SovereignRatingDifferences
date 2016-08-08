* Panel Data Models in Stata
* Copyright 2016 by Andre Albuquerque

clear all
set more off

* It only works in the ~\Documents directory
cd C:\Users\ADMIN\Documents\SovereignRatingDifferences
cd v0.2_UP_DW_Joined
import delimited using SM_PanelData, delimiters(";") clear

* We can't xtset string variables, so we have to generate a new numeric column
* countryno based on the country2code value
encode country2code, gen(countryno)

global id countryno
global t year
global ylist diff_sm
global xlist ngdpdpc ngdp_rpch extdebtpercgni ggxwdg_ngdp ggxwdn_ngdp ggsb_npgdp defaultlastyear defaultlast2years defaultlast5years defaultlast10years pcpipch

global xlist_grossdebt_deflast1 ngdpdpc ngdp_rpch extdebtpercgni ggxwdg_ngdp ggsb_npgdp defaultlastyear pcpipch
global xlist_grossdebt_deflast2 ngdpdpc ngdp_rpch extdebtpercgni ggxwdg_ngdp ggsb_npgdp defaultlast2years pcpipch
global xlist_grossdebt_deflast5 ngdpdpc ngdp_rpch extdebtpercgni ggxwdg_ngdp ggsb_npgdp defaultlast5years pcpipch
global xlist_grossdebt_deflast10 ngdpdpc ngdp_rpch extdebtpercgni ggxwdg_ngdp ggsb_npgdp defaultlast10years pcpipch

global xlist_netdebt_deflast1 ngdpdpc ngdp_rpch extdebtpercgni ggxwdn_ngdp ggsb_npgdp defaultlastyear pcpipch
global xlist_netdebt_deflast2 ngdpdpc ngdp_rpch extdebtpercgni ggxwdn_ngdp ggsb_npgdp defaultlast2years pcpipch
global xlist_netdebt_deflast5 ngdpdpc ngdp_rpch extdebtpercgni ggxwdn_ngdp ggsb_npgdp defaultlast5years pcpipch
global xlist_netdebt_deflast10 ngdpdpc ngdp_rpch extdebtpercgni ggxwdn_ngdp ggsb_npgdp defaultlast10years pcpipch


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
eststo: quietly xtoprobit $ylist $xlist, vce(robust)
estimates store mall, title (Model All)

eststo: quietly xtoprobit $ylist $xlist_grossdebt_deflast1, vce(robust)
estimates store m1, title (Model DefLastY)

eststo: quietly xtoprobit $ylist $xlist_grossdebt_deflast2, vce(robust)
estimates store m2, title (Model DefLast2Y)

eststo: quietly xtoprobit $ylist $xlist_grossdebt_deflast5, vce(robust)
estimates store m3, title (Model DefLast5Y)

eststo: quietly xtoprobit $ylist $xlist_grossdebt_deflast10, vce(robust)
estimates store m4, title (Model DefLast10Y)

* showing in a nice format and storing it in a .rtf file to import to Word
estout mall m1 m2 m3 m4, cells(b(star fmt(3)) se(par fmt(2))) legend label varlabels(_cons Constant)
esttab using SM_gross_debt_results.rtf, replace

* clear the stored results to run again
eststo clear
estimates clear

eststo: quietly xtoprobit $ylist $xlist, vce(robust)
estimates store mall, title (Model All)

eststo: quietly xtoprobit $ylist $xlist_netdebt_deflast1, vce(robust)
estimates store m1, title (Model DefLastY)

eststo: quietly xtoprobit $ylist $xlist_netdebt_deflast2, vce(robust)
estimates store m2, title (Model DefLast2Y)

eststo: quietly xtoprobit $ylist $xlist_netdebt_deflast5, vce(robust)
estimates store m3, title (Model DefLast5Y)

eststo: quietly xtoprobit $ylist $xlist_netdebt_deflast10, vce(robust)
estimates store m4, title (Model DefLast10Y)

* showing in a nice format and storing it in a .rtf file to import to Word
estout mall m1 m2 m3 m4, cells(b(star fmt(3)) se(par fmt(2))) legend label varlabels(_cons Constant)
esttab using SM_net_debt_results.rtf, replace

