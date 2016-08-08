* Panel Data Models in Stata
* Copyright 2016 by Andre Albuquerque

clear all
set more off

cd C:\dados\projectos\SovereignRatingDifferences
import delimited using UP_MF_PanelData, delimiters(";") clear

global id country2code
global t year
global ylist diff_up_mf
global xlist ngdpdpc ngdp_rpch extdebtpercgni ggxwdg_ngdp ggxwdn_ngdp ggsb_npgdp defaultlastyear defaultlast2years defaultlast5years defaultlast10years pcpipch


describe $id $t $ylist $xlist
summarize $id $t $ylist $xlist

* Set data as panel data
sort $id $t
xtset $id $t
xtdescribe
xtsum $id $t $ylist $xlist

* Using Random-effects ordered probit model applied to the observations where
* Moody's rating is HIGHER than Fitch, using Robust standard errors
xtoprobit $ylist $xlist, vce(robust)
