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

*******************************************************

** Data loading
use $gitoutput/dataset, clear

xtset author careerlength

** Model definition
local model1 views 	careerlength 
local model2 views 	careerlength i.gender
local model3 views 	careerlength i.gender i.content_type
local model4 views 	careerlength i.gender i.content_type i.agency
local model5 views 	careerlength i.gender i.content_type i.agency i.author
local model6 views 	careerlength i.gender i.content_type i.agency i.author i.author##i.content_type

/*
Varible not ready:
-gender
-content_type
*/

** Data analysis - OLS

forval x = 1/6{

	qui: reg `model`x'', robust
	eststo model`x'_ols
}

** Data analysis - FE

forval x = 1/6{

	xtreg `model`x'', fe robust
	eststo model`x'_fe
}

esttab *_ols, star(* 0.1 ** 0.5 *** 0.01) b(%7.2f) 
esttab *_fe, star(* 0.1 ** 0.5 *** 0.01) b(%7.2f) 