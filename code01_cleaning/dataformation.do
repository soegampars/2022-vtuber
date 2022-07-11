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

** Supporting Data Import

import delimited $gitraw/author_gender, encoding("utf-8") clear

tempfile gender
save `gender'

** Main Data Import
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
gen debut = ustrregexm(title, "debut", 1) > 0 & nvideo <=10 & lengthseconds > 1000
	replace debut = 1 if nvideo <= 2 & lengthseconds > 1000
by author: gen datedebut1 = date if debut == 1
	format date %td
	by author: egen datedebut = min(datedebut1)
	drop datedebut1
	format datedebut %td
replace debut = 1 if datedebut == . & nvideo == 1
replace datedebut = date if datedebut == . & nvideo == 1

gen careerlength = date-datedebut
gen careerlength_sq = careerlength^2
	
drop if careerlength < 0

** Drop short videos
drop if lengthseconds <= 60

** Creating author list
rename author author3
gen author2 = substr(author3,84,.)
gen author = substr(author2,1,length(author2)-4)

gen agency = ""
	replace agency = "NIJISANJI ID" if strpos(author,"NIJISANJI") > 0 | author == "Azura Cecillia Ch."
	replace agency = "HOLOLIVE ID" if strpos(author,"hololive") > 0
	replace agency = "MAHA5" if strpos(author,"MAHA5") > 0 | author == "NANARIKA Channel"
	
drop author2 author3

** Merge: Gender
merge m:1 author using `gender', nogen

** Generate content type
gen contenttype = "Others"
	replace contenttype = "Freetalk" if	ustrregexm(title,"freetalk", 1) > 0 | ustrregexm(title,"free talk", 1) > 0 | ///
										ustrregexm(title, "hero talk", 1) > 0
								
	replace contenttype = "Minecraft" if ustrregexm(title, "minecraft", 1) > 0
	
	replace contenttype = "Phasmo" if ustrregexm(title, "phasmo", 1) > 0
	
	replace contenttype = "Fall Guys" if ustrregexm(title, "fall guys", 1) > 0 | ustrregexm(title, "fallguys", 1) > 0
	
	replace contenttype = "Genshin/Honkai" if ustrregexm(title, "genshin", 1) > 0 | ustrregexm(title, "honkai", 1) > 0 
	
	replace contenttype = "Valorant" if	ustrregexm(title, "valorant", 1) > 0
	
	replace contenttype = "Apex" if ustrregexm(title, "apex", 1) > 0
	
	replace contenttype = "Karaoke" if ustrregexm(title, "karaoke", 1) > 0
	
	replace contenttype = "Music" if ustrregexm(title, "cover", 1) > 0 | ustrregexm(title, "song", 1) > 0 | ustrregexm(title, "カバー", 1) > 0

	replace contenttype = "Music" if ustrregexm(title, "cover", 1) > 0 
	
encode contenttype, generate(contenttype_code)
encode author, generate(author_code)
encode agency, generate(agency_code)

la var datestr 				"Date-StringVar"
la var date 				"Date"
la var nvideo 				"Video number ordered by publish sequence"
la var debut 				"Debut video (dummy)"
la var datedebut 			"Date of debut"
la var careerlength 		"Days since debut video"
la var careerlength_sq 		"Days since debut video (squared)"
la var author 				"Author"
la var agency 				"Agency"
la var female 				"Female (dummy)"
la var contenttype 			"Content type"
la var contenttype_code 	"Content type (encoded)"
la var author_code 			"Author (encoded)"
la var agency_code 			"Agency (encoded)"

** Save data to .dta format
compress
save $gitoutput/dataset, replace
