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

*******************************************************

** Data Import
import delimited $localraw\videos.csv, encoding("utf-8") bindq(nobind) clear
	drop if inlist(views,"","0")
	keep title author lengthseconds published views likes

** Destring numerical data
destring lengthseconds views likes, replace ignore(",") force

gen datestr = substr(published, 1, 10)
gen date = date(datestr,"YMD")
format date %td

sort author date 
drop in 1/2
by author: gen nvideo = _n
gen debut = nvideo == 1
by author: gen datedebut1 = date if nvideo == 1
	format date %td
	by author: egen datedebut = max(datedebut1)
	drop datedebut1
gen careerlength = date-datedebut

** Save data to .dta format
compress
save $gitoutput/dataset, replace

