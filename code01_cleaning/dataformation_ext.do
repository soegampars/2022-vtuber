clear
set more off

local datestamp: di %tdCYND daily("$S_DATE", "DMY")

global suser = c(username)

if(inlist("$suser", "satya")){
	cd "D:\"
}

global localraw 	"database\vtuber\raw\extended"
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
import delimited $localraw\videos2.csv, encoding("utf-8") bindq(nobind) clear

** Destring numerical data

** Destring date

** Define debut date and career length variable

** Drop short videos

** Creating author and agency variable

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
	
	replace contenttype = "Music" if ustrregexm(title, "cover", 1) > 0 | ustrregexm(title, "song", 1) > 0 | ustrregexm(title, "カバー", 1) > 0 | ustrregexm(title, "歌ってみた", 1) > 0

	replace contenttype = "Music" if ustrregexm(title, "cover", 1) > 0 
	
** Generate early talent identifier (Latest: Iofi Debut/HOLOLIVE-ID first gen debut)
	gen early = datedebut <= 22017
	
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
