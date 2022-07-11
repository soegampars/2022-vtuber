clear
set more off

local datestamp: di %tdCYND daily("$S_DATE", "DMY")

global suser = c(username)

if(inlist("$suser", "satya")){
	cd "D:\"
}

global localraw 	"database\vtuber\raw"
global gitraw		"GitHub\2022-vtuber\data01_raw"
global gitoutput	"GitHub\2022-vtuber\data02_processed"
global gitcode01	"GitHub\2022-vtuber\code01_cleaning"
global gitcode02	"GitHub\2022-vtuber\code02_analysis"

capture: log close
est clear
*******************************************************

/*
Temporary notes:
1. Check for heterogeneity in results between agencies
2. Check for results in OLS, clustered OLS, and FE

Temporary result:
1. 	Apparently from the analysis of ln_views, there's a quadratic growth pattern in views for NIJISANJI
	No clear trend whatsoever for MAHA5 and HOLOLIVE.
*/

** Data loading
use $gitoutput/dataset, clear

** Create long-run trend variable

collapse (mean) views (max) female agency_code debut careerlength, by(date author_code)

xtset author_code date

gen careerlength_sq = careerlength^2
gen ln_views = ln(views)
// pfilter views, method(hp) trend(trend_views40) smooth(40)

** Specifying model
local model1 ln_views	careerlength careerlength_sq i.debut
local model2 ln_views	careerlength careerlength_sq i.debut i.female
local model3 ln_views	careerlength careerlength_sq i.debut i.agency_code
local model4 ln_views	careerlength careerlength_sq i.debut i.female i.agency_code
// local model5 trend_views40	careerlength careerlength_sq i.debut
// local model6 trend_views40	careerlength careerlength_sq i.debut i.female
// local model7 trend_views40	careerlength careerlength_sq i.debut i.agency_code
// local model8 trend_views40	careerlength careerlength_sq i.debut i.female i.agency_code

forval ag = 1/3{

forval x = 1/4{

	qui: xtreg `model`x'' if agency_code == `ag', fe robust
	eststo model`x'

}

esttab model*, star(* 0.10 ** 0.05 *** 0.01) se(%7.2f) nobase l
est clear

}

/*
forval x = 5/8{

	qui: xtreg `model`x'', fe robust
	eststo model`x'

}

esttab model*, star(* 0.10 ** 0.05 *** 0.01) b(%7.2f) nobase l
est clear
*/
