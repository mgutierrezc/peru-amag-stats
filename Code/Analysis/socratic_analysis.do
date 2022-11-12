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
Regressions on Educational Attainment
=====*/

	global controls_ed i.en_Course Age_rounded Age_squared i.en_Gender i.en_Position 
	global outcomes_ed attendance grade pass
	
	local i = 1
	foreach var_ed in $outcomes_ed {
		sum `var_ed' if socratic_actual != .
		local mean = round(`r(mean)', 0.001) 		
		
		reg `var_ed' socratic_actual, cluster(Course)
		if(`i'==1){
			outreg2 using "$tables\educ_at.tex", replace stats(coef pval ) level(95) addtext("Controls", "No", "Mean of dep var. ctrl.", `mean') label keep(socratic_actual) nocons nor2			
		}
		else {
			outreg2 using "$tables\educ_at.tex", append stats(coef pval ) level(95) addtext("Controls", "No", "Mean of dep var. ctrl.", `mean') label keep(socratic_actual) nocons nor2			
		}
			
		sum `var_ed' if socratic_actual != .
		local mean = round(`r(mean)', 0.001) 		
		reg `var_ed' socratic_actual $controls_ed , cluster(Course)
		outreg2 using "$tables\educ_at.tex", append stats(coef pval ) level(95) addtext("Controls", "Yes", "Mean of dep var. ctrl.", `mean') label keep(socratic_actual) nocons nor2 // storing r						
		local i = `i' + 1
	}
		

/*=====
Regressions on Behavioral Biases

- IAT outcome: probability of being biased Male-Career/Female-Family (bs iat score included as control)
- Behavioral games outcomes: 
	- Dictator outcomes (add gender variation as control)
	- Ultimatum game (add framing and externality, separate it between proposer/receiver roles)
=====*/

	/*-----
	IAT 
	-----*/
	
	**Slight to Strong Male Career bias
	gen male_career_sl_str = (en_iat_score < -0.15) 
	replace male_career_sl_str = . if en_iat_score == .
	**Moderate to Strong Male Career bias
	gen male_career_mod_str = (en_iat_score < -0.35)
	replace male_career_mod_str = . if en_iat_score == .
	**Strong Male Career bias (not used as only 3 obs)
	gen male_career_str = (en_iat_score < -0.65)
	replace male_career_str = . if en_iat_score == .
		
	global outcomes_iat male_career_sl_str male_career_mod_str
	global controls_iat i.en_Course Age_rounded Age_squared i.en_Gender i.en_Position bs_iat_score
		
	local i = 1
	foreach var_iat in $outcomes_iat {
		sum `var_iat' if socratic_actual != .
		local mean = round(`r(mean)', 0.001) 
		
		reg `var_iat' socratic_actual, cluster(Course)
		if(`i'==1){
			outreg2 using "$tables\socratic_iat.tex", replace stats(coef pval ) level(95) addtext("Controls", "No", "Mean of dep var. ctrl.", `mean') label keep(socratic_actual) nocons nor2			
		}
		else {
			outreg2 using "$tables\socratic_iat.tex", append stats(coef pval ) level(95) addtext("Controls", "No", "Mean of dep var. ctrl.", `mean') label keep(socratic_actual) nocons nor2			
		}

		sum `var_iat' if socratic_actual != . & bs_iat_score != .
		local mean = round(`r(mean)', 0.001) 		
		reg `var_iat' socratic_actual $controls_iat , cluster(Course)
		outreg2 using "$tables\socratic_iat.tex", append stats(coef pval ) level(95) addtext("Controls", "Yes", "Mean of dep var. ctrl.", `mean') label keep(socratic_actual) nocons nor2 // storing r			
		local i = `i' + 1
	}
		

	/*-----
	Dictator game
	-----*/

	global outcomes_dic en_dictator_decision dictator_decision_change
	global controls_dic i.en_Course Age_rounded Age_squared i.en_Gender i.en_Position en_dictator_pgender_num bs_dictator_decision
		
	local i = 1
	foreach var_dic in $outcomes_dic {
		sum `var_dic' if socratic_actual != .
		local mean = round(`r(mean)', 0.001) 
		
		reg `var_dic' socratic_actual, cluster(Course)
		if(`i'==1){
			outreg2 using "$tables\socratic_dic.tex", replace stats(coef pval ) level(95) addtext("Controls", "No", "Mean of dep var. ctrl.", `mean') label keep(socratic_actual) nocons nor2
		}
		else {
			outreg2 using "$tables\socratic_dic.tex", append stats(coef pval ) level(95) addtext("Controls", "No", "Mean of dep var. ctrl.", `mean') label keep(socratic_actual) nocons nor2			
		}

		sum `var_dic' if socratic_actual != . & dictator_decision_change != .
		local mean = round(`r(mean)', 0.001) 		
		reg `var_dic' socratic_actual $controls_dic , cluster(Course)
		outreg2 using "$tables\socratic_dic.tex", append stats(coef pval ) level(95) addtext("Controls", "Yes", "Mean of dep var. ctrl.", `mean') label keep(socratic_actual) nocons nor2 // storing r			
			
		local i = `i' + 1
	}
			
	
