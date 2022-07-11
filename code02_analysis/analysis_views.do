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