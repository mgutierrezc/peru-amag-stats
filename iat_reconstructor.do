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
pagetime_files = [f for f in pagetime_files if "PageTimes" in f] # omitting unnecessary files

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
		scalar counter = `=counter' + 1
}

********
**Creating a single file of unique codes
********
use "$aux_path\participant_ids_1", clear
	append using "$aux_path\participant_ids_2"
	duplicates report // verifying file consistency
	
	save "$out_path\participant_codes", replace
	
