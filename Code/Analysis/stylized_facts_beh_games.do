cls
/*=============================
Regressions for Peru Amag II

---
author: Marco Gutierrez
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
Merging with Grades data
=====*/

	drop if DNI == .
	merge 1:1 DNI using "$data\grades_clean"

	
/*=====
Stylized facts 
=====*/

	set scheme plotplain // scheme configuration

	**Dictator
	foreach dictator_var in bs_dictator_decision en_dictator_decision{
		cap gen `dictator_var'_st = `dictator_var'*10
	}
	
	***Baseline
	sum bs_dictator_decision_st if en_dictator_decision != . // Mean and SD

	// Histogram
	label var bs_dictator_decision_st "Dictator Choice (Baseline)"
	kdensity bs_dictator_decision_st if en_dictator_decision != ., title("Distribution of Dictator choices (Baseline)", size (medsmall)) note("Considering only participants in both baseline and endline")

	***Endline
	sum en_dictator_decision_st if bs_dictator_decision != . // Mean and SD
		
	// Histogram
	label var en_dictator_decision_st "Dictator Choice (Endline)"
	kdensity en_dictator_decision_st if bs_dictator_decision != ., title("Distribution of Dictator choices (Endline)", size (medsmall)) note("Considering only participants in both baseline and endline")	
	
	**IAT	
	preserve
		***Baseline
		keep if iat_score_change !=. //keeping participants in both bs and en
		sum bs_iat_score
		kdensity en_iat_score if iat_option_take_or_not == 0, addplot(kdensity en_iat_score if iat_option_take_or_not == 1,  recast(line) lpattern(dash)) ///
		legend(order(1 "Option to Take IAT = 0 " 2 "Option to Take IAT = 1") size(small)) ///
		title("Distribution of IAT scores (Endline)", size (medsmall))  ///
		note("")

		graph export "$plots/density_eniat.png", replace
	
		***Endline
		sum en_iat_score 
		kdensity bs_iat_score if iat_option_take_or_not == 0, addplot(kdensity bs_iat_score if iat_option_take_or_not == 1,  recast(line) lpattern(dash)) ///
		legend(order(1 "Option to Take IAT = 0 " 2 "Option to Take IAT = 1") size(small)) ///
		title("Distribution of IAT scores (Endline)", size (medsmall))  ///
		note("")

		graph export "$plots/density_eniat.png", replace
	restore
		