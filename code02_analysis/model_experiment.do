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

** Generate additional variables 

gen ln_views = ln(views)
gen ln_careerlength = ln(careerlength)
gen ln_careerlength_sq = ln(careerlength_sq) 
gen nvideo_sq = nvideo^2

** Model specification
// local model1 ln_views	ln_careerlength ln_careerlength_sq i.debut i.female
// local model2 ln_views	ln_careerlength ln_careerlength_sq i.debut i.female i.agency_code
// local model3 ln_views	ln_careerlength ln_careerlength_sq i.debut i.female i.agency_code i.author_code##i.contenttype_code

// local model1 ln_views	careerlength careerlength_sq i.debut i.agency_code i.female
// local model1 ln_views	i.debut i.agency_code i.author_code##i.contenttype_code careerlength careerlength_sq
// local model2 ln_views	i.debut i.agency_code i.author_code##i.contenttype_code nvideo 
// local model3 ln_views	i.debut i.agency_code i.author_code##i.contenttype_code nvideo nvideo_sq 
// local model4 ln_views	i.debut i.agency_code i.author_code##i.contenttype_code careerlength careerlength_sq nvideo 
// local model5 ln_views	i.debut i.agency_code i.author_code##i.contenttype_code careerlength careerlength_sq nvideo nvideo_sq 

local model1 ln_views	i.debut i.agency_code i.author_code##i.contenttype_code careerlength careerlength_sq
local model2 ln_views	i.debut i.agency_code i.author_code##i.contenttype_code careerlength careerlength_sq nvideo 
local model3 ln_views	i.debut i.agency_code i.author_code##i.contenttype_code careerlength careerlength_sq nvideo nvideo_sq 

// local model3 views	careerlength careerlength_sq i.debut i.female i.agency_code i.author_code##i.contenttype_code

******************************
** CROSS-SECTIONAL ANALYSIS **
******************************

** General Sample

	** OLS
	forval x = 1/3{
// 	forval x = 1/5{

	qui: reg `model`x'', robust
	eststo model`x'_ols
// 	predict yhat`x'
//	
// 	twoway line yhat* careerlength || scatter ln_views careerlength, msize(tiny)
// 	graph export $gitcode02/ols_general_`x'.png, replace

	}
	
	esttab model*, star(* 0.10 ** 0.05 *** 0.01) se(%7.2f) nobase l keep(careerlength careerlength_sq 1.debut *.agency_code nvideo _cons) r2 aic
	est clear
	
** Heterogeneity Analysis

	** OLS: By Gender
	forval a = 0/1{

	forval x = 1/3{
// 	forval x = 1/5{

		qui: reg `model`x'' if female == `a', robust
		eststo model`x'_ols

		}
		
		esttab model*, star(* 0.10 ** 0.05 *** 0.01) se(%7.2f) nobase l keep(careerlength careerlength_sq 1.debut *.agency_code nvideo) r2 aic
		est clear

	
	}
	
	** OLS: By Agency
	forval a = 1/3{

	forval x = 1/3{
// 	forval x = 1/5{

		qui: reg `model`x'' if agency_code == `a', robust
		eststo model`x'_ols

		}
		
		esttab model*, star(* 0.10 ** 0.05 *** 0.01) se(%7.2f) nobase l keep(careerlength careerlength_sq 1.debut *.agency_code nvideo) r2 aic
		est clear

	
	}
	
	** OLS: By Early Starter
	forval a = 0/1{

	forval x = 1/3{
// 	forval x = 1/5{

		qui: reg `model`x'' if early == `a', robust
		eststo model`x'_ols

		}
		
		esttab model*, star(* 0.10 ** 0.05 *** 0.01) se(%7.2f) nobase l keep(careerlength careerlength_sq 1.debut *.agency_code nvideo) r2 aic
		est clear

	
	}

local model1 ln_views	i.debut i.author_code##i.contenttype_code careerlength careerlength_sq
local model2 ln_views	i.debut i.author_code##i.contenttype_code careerlength careerlength_sq nvideo 
local model3 ln_views	i.debut i.author_code##i.contenttype_code careerlength careerlength_sq nvideo nvideo_sq 

	** OLS: By Subs Category
	forval a = 1/3{

	forval x = 1/3{
// 	forval x = 1/5{

		qui: reg `model`x'' if subscat == `a', robust
		eststo model`x'_ols

		}
		
		esttab model*, star(* 0.10 ** 0.05 *** 0.01) se(%7.2f) nobase l keep(careerlength careerlength_sq 1.debut nvideo) r2 aic
		est clear

	
	}
