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

** Data loading
use $gitoutput/dataset, clear

** Model specification
local model1 views	careerlength careerlength_sq i.debut
local model2 views	careerlength careerlength_sq i.debut i.female
local model3 views	careerlength careerlength_sq i.debut i.agency_code
local model4 views	careerlength careerlength_sq i.debut i.female i.agency_code i.author_code##i.contenttype_code

** Analysis - General
forval x = 1/4{

qui: reg `model`x'', robust
eststo model`x'

}

log using $gitoutput/log_ols_general.log, replace

esttab model*, star(* 0.10 ** 0.05 *** 0.01) se(%7.2f) nobase l
est clear

log close

** Analysis - Heterogeneity: Agency
forval ag = 1/3{

forval x = 1/4{

qui: reg `model`x'' if agency_code == `ag', robust
eststo model`x'

}

log using $gitoutput/log_ols_agency`ag'.log, replace

esttab model*, star(* 0.10 ** 0.05 *** 0.01) se(%7.2f) nobase l
est clear

log close

}

** Analysis - Heterogeneity: Gender
forval gd = 0/1 {

forval x = 1/4{

qui: reg `model`x'' if female == `gd', robust
eststo model`x'

}

log using $gitoutput/log_ols_gender`gd'.log, replace

esttab model*, star(* 0.10 ** 0.05 *** 0.01) se(%7.2f) nobase l
est clear

log close
}


** Analysis - Cluster: Authors
forval x = 1/4{

qui: reg `model`x'', robust cluster(author_code)
eststo model`x'

}

log using $gitoutput/log_ols_clustauth.log, replace

esttab model*, star(* 0.10 ** 0.05 *** 0.01) se(%7.2f) nobase l
est clear

log close