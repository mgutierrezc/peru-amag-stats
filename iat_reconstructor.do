/***********
**Reconstructing if player saw 
IAT Feedback

Project: Peru-Amag
Programmer: Marco Gutierrez 
***********/


/*----------------------
Initiating script configuration
-----------------------*/
cls
clear all
set more off

**setting up paths
global path "D:\Accesos directos\Trabajo\World Bank\Repos\peru-amag-stats"

global aux_path "$path\aux_output" // for auxiliary files
cap mkdir "$aux_path"

global out_path "$path\output"
cap mkdir "$out_path"

cd "$path" // defining main dir


/*----------------------
Getting all csv files from main path
-----------------------*/
python:
from sfi import Macro
from os import listdir
from os.path import isfile, join

# setting up paths
path = Macro.getGlobal("path")

# getting pagetime file names
pagetime_files = [f for f in listdir(path) if isfile(join(path, f))]
pagetime_files = [f for f in pagetime_files if "PageTimes" in f and ".csv" in f and "#" not in f] # omitting unnecessary files

# calculating num files
num_pagetime_files = len(pagetime_files)

# storing the file names as stata global
Macro.setGlobal("pagetime_files", " ".join(pagetime_files))
end


/*----------------------
Finding all participant codes
-----------------------*/

********
**Storing codes per group of sessions
********
scalar counter = 1 // file counter
foreach file of global pagetime_files{ // iterating accross pagetime_files
	import delimited `file', clear
		
		* keeping only participant codes
		keep participant_code
		duplicates drop
		
		save "$aux_path\participant_ids_`=counter'", replace
		scalar counter = `=counter' + 1 // updating file counter
}

scalar num_pagetime_files = `=counter' - 1 // total number of pagetime_files

********
**Creating a single file of unique codes
********
use "$aux_path\participant_ids_1", clear
	
	forvalues i=2/`=num_pagetime_files'{ // appending all id files
		append using "$aux_path\participant_ids_`i'"
		save "$out_path\participant_codes", replace		
	}
	

/*----------------------
Generating binary IAT Feedback indicator
-----------------------*/

********
**Checking players who have seen the IAT Feedback page (ResultI)
********
scalar counter = 1 // file counter
foreach file of global pagetime_files{ // iterating accross pagetime_files
	import delimited `file', clear
		
		*keeping the codes of participants who played the IAT
		keep if page_name == "ResultI"
		keep participant_code 
		gen seen_iat_feedback = 1 // binary indicator for iat feedback
		
		duplicates drop //dropping repeated obs
		
		save "$aux_path\iat_feedback_codes_`=counter'", replace
		scalar counter = `=counter' + 1 // updating file counter
}

********
**Creating a single file of unique codes from iat feedback participants
********
use "$aux_path\iat_feedback_codes_1", clear
	
	forvalues i=2/`=num_pagetime_files'{ // appending all iat id files
		append using "$aux_path\iat_feedback_codes_`i'"	
		save "$out_path\iat_feedback_codes", replace
	}

********
**Matching iat feedback data with participant_codes
********	
use "$out_path\participant_codes", clear
	merge 1:1 participant_code using "$out_path\iat_feedback_codes", nogen
	replace seen_iat_feedback = 0 if missing(seen_iat_feedback)
