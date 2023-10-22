cls
/*=============================
Validation of Peru Amag II

---
author: Ronak Jain, Mayumi Cornejo, 
Jose Maria Rodriguez Valadez
editor: Marco Gutierrez
=============================*/

clear all
set more off
program drop _all

/*=====
Setting up directories
=====*/

*di `"Please, input the main path where the required data for running this dofile is stored into the COMMAND WINDOW and then press ENTER  "'  _request(path)
global path "D:\Accesos directos\Trabajo\World Bank\Peru Amag\peru-amag-stats"
global data "$path\Data"
global judges_outcomes "$data\judges-outcomes\final"
global output "$path\output"
global modules "$path\Code\Analysis\Modules"
global hr_judges "D:\Dropbox (Daniel Chen)\Peru_Justice\02_Data\04_Poder_Judicial\02_Raw"
global judges_outcomes "D:\Accesos directos\Trabajo\World Bank\Peru Amag\peru-amag-stats\Data\judges-outcomes\raw"

global docs "$output\eval_regs"
cap mkdir "$docs"

global tables "$docs\tables"
cap mkdir "$tables"

global graphs "$docs\graphs"
cap mkdir "$graphs"

cd "$data"
use "Clean_Full_Data12.dta"   /// stata 12 friendly


/*=====
Cleaning and variable generation
=====*/
	do "$modules\cleaner_gen.do"
	rename age2 Age_squared
	

/*=====
Merging with list of judges
=====*/
	
	**Current judges
	preserve
		import delimited "$hr_judges\HR_present.csv", clear
		rename dni DNI
		save "$judges_outcomes\hr_present", replace
	restore

	**Merging with current judges
	drop if DNI == .
	merge 1:1 DNI using "$judges_outcomes\hr_present"
	
