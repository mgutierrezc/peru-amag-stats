cls
/*=============================
Regressions for Peru Amag II

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
Selection on observables
=====*/
	orth_out position_* course_* gender_1 Age_rounded using "$tables\selection.xlsx", by(en_Estado_de_Cuestionario) pcompare stars se sheet(selection_en) sheetreplace
	orth_out position_* course_* gender_1 Age_rounded using "$tables\selection.xlsx", by(bs_Estado_de_Cuestionario) pcompare stars se sheet(selection_bs) sheetreplace


/*=====
Changes in Behavior: Motivated reasoning, 
Curiosity and Confirmation Bias
=====*/	

	do "$modules\motiv_curios_conf_bias.do"

	
/*=====
Changes in Behavior: Gender Biases
IAT
=====*/

	do "$modules\iat_treatment_effs.do"
	
	
/*=====
Trolley 
=====*/

	do "$modules\trolley_regs.do"


/*=====
Book Choices 
=====*/

	do "$modules\book_regs.do"
	

/*=====
Merge with Judges Outcomes DBs
=====*/

*	do "$modules\book_regs.do"