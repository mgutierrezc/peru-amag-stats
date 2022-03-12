cls
/***********
**Reconstructing if player saw 
IAT Feedback

Project: Peru-Amag
Programmer: Marco Gutierrez 
***********/


/*----------------------
Initiating script configuration
-----------------------*/
clear all
set more off

**setting up paths
global main "D:\Accesos directos\Trabajo\World Bank\Peru Amag\peru-amag-stats"
global data "$main\Data"
global baseline "$data\Baseline raw"

global out_path "$main\output"
cap mkdir "$out_path"

global aux_path "$out_path\aux_output" // for auxiliary files
cap mkdir "$aux_path"

cd "$baseline" // defining main dir


/*----------------------
Getting all csv files from main path
-----------------------*/
python:
from sfi import Macro
from os import listdir
from os.path import isfile, join

# setting up paths
path = Macro.getGlobal("baseline")

# getting pagetime file names
pagetime_files = [f for f in listdir(path) if isfile(join(path, f))]
pagetime_files = [f for f in pagetime_files if "PageTimes" in f and ".csv" in f and "#" not in f] # omitting unnecessary files

# getting behavioral data file names
behavioral_files = [f for f in listdir(path) if isfile(join(path, f))]
behavioral_files = [f for f in behavioral_files if "all_apps_wide" in f and ".csv" in f and "#" not in f] # omitting unnecessary files

# storing the file names as stata global
Macro.setGlobal("pagetime_files", " ".join(pagetime_files))
Macro.setGlobal("behavioral_files", " ".join(behavioral_files))
end


/*----------------------
Finding all participant codes/DNIs
-----------------------*/

********
**Storing participant codes per group of sessions
********
scalar counter = 1 // file counter
foreach file of global pagetime_files{ // iterating accross pagetime_files
	import delimited `file', clear
		
		codebook participant_code
		
		* keeping only participant codes
		keep participant_code session_code
		rename session_code session_code_pagetime
		duplicates drop
		
		save "$aux_path\participant_ids_`=counter'", replace
		scalar counter = `=counter' + 1 // updating file counter
}

scalar num_pagetime_files = `=counter' - 1 // total number of pagetime_files


********
**Storing DNIs per group of sessions
********
scalar counter = 1 // file counter
foreach file of global behavioral_files{ // iterating accross pagetime_files
	import delimited `file', clear varnames(1)
		
		di "`file'"
		* keeping only participant codes
		keep participantlabel participantcode sessioncode
		
		* dropping unnecessary observations
		cap gen DNI = int(real(participantlabel))
		cap rename participantlabel DNI
		cap drop participantlabel
		*destring(DNI), replace
		
		drop if missing(DNI)
		
		duplicates drop
		codebook DNI
		
		* renaming vars for future merges
		rename participantcode participant_code
		
		
		save "$aux_path\participant_dnis_`=counter'", replace
		scalar counter = `=counter' + 1 // updating file counter
}

scalar num_behavioral_files = `=counter' - 1 // total number of pagetime_files


********
**Creating a single file of unique codes
********
use "$aux_path\participant_ids_1", clear
	
	forvalues i=2/`=num_pagetime_files'{ // appending all id files
		append using "$aux_path\participant_ids_`i'"
		save "$aux_path\participant_codes", replace		
	}
	
	save "$aux_path\participant_codes", replace

	
********
**Creating a single file of unique codes
********
use "$aux_path\participant_dnis_1", clear
	
	forvalues i=2/`=num_behavioral_files'{ // appending all id files
		di `i'
		append using "$aux_path\participant_dnis_`i'"
		save "$aux_path\participant_dnis", replace		
	}
	
	duplicates drop
	save "$aux_path\participant_dnis", replace


/*----------------------
Generating binary IAT Feedback indicator
-----------------------*/

********
**Checking players who have seen the IAT Feedback page (ResultI)
********
scalar counter = 1 // file counter
foreach file of global pagetime_files{ // iterating accross pagetime_files
	import delimited `file', clear
		
		di "`file'"
		codebook participant_code
		
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
		save "$aux_path\iat_feedback_codes", replace
	}
	
	duplicates drop
	save "$aux_path\iat_feedback_codes", replace

	
********
**Matching iat feedback data with participant_codes
********	
use "$aux_path\participant_codes", clear
	merge m:1 participant_code using "$aux_path\iat_feedback_codes", nogen
	replace seen_iat_feedback = 0 if missing(seen_iat_feedback)
	
	duplicates drop
	save "$aux_path\participants_iat_feedback", replace
	
	
********
**Matching iat feedback data with participant_dnis
********
use "$aux_path\participant_dnis", clear
	
	merge m:1 participant_code using "$aux_path\participants_iat_feedback", gen(consistency_identifier)
	sort consistency_identifier
	
	*recovering missing session codes from pagetime data
	replace sessioncode = session_code_pagetime if sessioncode==""
	drop session_code_pagetime
	rename sessioncode session_code
	
	*labeling data according to consistency
	label define consistency_labels 1 "Only on behavioral data" 2 "Only on pagetime data" 3 "Consistent" 
	label values consistency_identifier consistency_labels 

	*keep if consistency_identifier == 3
	*drop consistency_identifier
	
	*droping duplicates based on DNI (only 1 obs in baseline with same value for seen iat)
	*duplicates drop DNI, force
	
	save "$out_path\players_iat_feedback", replace

	
********
**Deleting aux data
********

!rmdir "$aux_path" /s /q