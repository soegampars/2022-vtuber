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

** Table 1: General Model & Linear/Non-Linear Comparison

	** Model Specification
	local model1 ln_views	i.debut i.agency_code i.female i.author_code##i.contenttype_code careerlength
	local model2 ln_views	i.debut i.agency_code i.female i.author_code##i.contenttype_code careerlength nvideo 
	local model3 ln_views	i.debut i.agency_code i.female i.author_code##i.contenttype_code careerlength careerlength_sq nvideo nvideo_sq 

	local model1title "Linear w/o n Video"
	local model2title "Linear w/ n Video"
	local model3title "Non-Linear"

	** Analysis
	forval x = 1/3{

	qui: reg `model`x'', robust
	eststo model`x'_ols, t(`model`x'title')

	}
	
	esttab model*, star(* 0.10 ** 0.05 *** 0.01) se(%7.2f) nobase l keep(careerlength* nvideo* 1.female 1.debut _cons) order(careerlength* nvideo* 1.female 1.debut _cons) r2 aic mti ti("Table 1. General Model & Linear/Non-Linear Comparison")
	est clear

** Table 2: Early Starters vs Newcomers

	forval a = 0/1{

	qui: reg `model3' if early == `a', robust
	eststo model`a'_ols

	}
	
	esttab model*, star(* 0.10 ** 0.05 *** 0.01) se(%7.2f) nobase l keep(careerlength careerlength_sq 1.debut *.agency_code nvideo) r2 aic
	est clear

