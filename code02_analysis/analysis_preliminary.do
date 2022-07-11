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
*******************************************************

** Data loading
use $gitoutput/dataset, clear

// xtset author_code careerlength

** Model definition
local modela1 views 	i.debut careerlength 
local modela2 views 	i.debut careerlength i.female
local modela3 views 	i.debut careerlength i.female b1.agency_code 
local modela4 views 	i.debut careerlength i.author_code
local modelb1 views 	i.debut careerlength careerlength_sq 
local modelb2 views 	i.debut careerlength careerlength_sq i.female
local modelb3 views 	i.debut careerlength careerlength_sq i.female b1.agency_code 
local modelb4 views 	i.debut careerlength careerlength_sq i.author_code

// local model5 views 	careerlength i.female b1.agency_code i.author_code i.contenttype_code
// local model6 views 	careerlength i.female b1.agency_code i.author_code i.contenttype_code i.author_code#i.contenttype_code

/*
Varible not ready:
-gender
-contenttype
*/

** Data analysis - OLS

forval x = 1/4{

	qui: reg `modela`x'', robust
	eststo modela`x'_ols
}

forval x = 1/4{

	qui: reg `modelb`x'', robust
	eststo modelb`x'_ols
}


forval x = 1/4{

	qui: reg `modela`x'', robust cluster(author_code)
	eststo modela`x'_cluster
}

forval x = 1/4{

	qui: reg `modelb`x'', robust cluster(author_code)
	eststo modelb`x'_cluster
}

/*
** Data analysis - FE

forval x = 1/6{

	xtreg `model`x'', fe robust
	eststo model`x'_fe
}
*/

forval x = 1/4{
	
	dis "MODEL SET `x'"
	esttab modela`x'_ols modelb`x'_ols, star(* 0.10 ** 0.05 *** 0.01) b(%7.2f) nobase l

}

forval x = 1/4{

	esttab modela`x'_cluster modelb`x'_cluster, star(* 0.10 ** 0.05 *** 0.01) b(%7.2f) nobase l

}

// esttab *_fe, star(* 0.10 ** 0.05 *** 0.01) b(%7.2f) 

** ATTEMPT ON PANEL SETTING

est clear

// collapse (mean) views (max)debut female agency_code content_type, by(author_code careerlength)
duplicates drop author_code careerlength, force
xtset author_code careerlength

** Model Redefinition
local modela1 views 	i.debut careerlength 
local modela2 views 	i.debut careerlength i. female
local modela3 views 	i.debut careerlength i. female i.agency_code
local modela4 views 	i.debut careerlength i. female i.agency_code b7.contenttype_code
local modelb1 views 	i.debut careerlength careerlength_sq 
local modelb2 views 	i.debut careerlength careerlength_sq i.female
local modelb3 views 	i.debut careerlength careerlength_sq i.female i.agency_code
local modelb4 views 	i.debut careerlength careerlength_sq i.female i.agency_code b7.contenttype_code

forval x = 1/4{

	xtreg `modela`x'', fe robust
	eststo modela`x'_fe
}

forval x = 1/4{

	xtreg `modelb`x'', fe robust
	eststo modelb`x'_fe
}

log using $gitcode02/results_fe.log, replace

forval x = 1/4{

	esttab modela`x'_fe modelb`x'_fe, star(* 0.10 ** 0.05 *** 0.01) b(%7.2f) se(%7.2f) nobase l

}
log close
	
/*
forval x = 1/4{

	esttab modela`x'_fe modelb`x'_fe, star(* 0.10 ** 0.05 *** 0.01) b(%7.2f) nobase l

}
*/
