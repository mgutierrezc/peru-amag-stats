/***********
**IAT regressions for detection
of treatment effects

Project: Peru-Amag
Programmer: Marco Gutierrez
***********/

	/*-----
	Selection on observables for takeup
	
	---
	Notes:
	-Analyze selection on observables for those who choose to take the test 
	-Analyze selection on observables for receiving feedback or not
	-----*/
	orth_out position_* course_* gender_1 Age_rounded using "$tables\iat_selection.xlsx" if iat_option_take_or_not==1, by(en_iat_player_skipped) pcompare stars sheet(selection_iat_takeup) sheetreplace

	orth_out position_* course_* gender_1 Age_rounded using "$tables\iat_selection.xlsx" if iat_feedback_option_or_not==1, by(en_ignore_feedback) pcompare stars sheet(selection_iat_feedback) sheetreplace

	
	/*-----
	IAT regressions
	-----*/
	
	**sets of variables
	global iat_outcomes en_iat_want_feedback z_en_iat_feedback_level z_iat_score_change z_en_iat_score 
	global treatments iat_option_take_or_not iat_feedback_option_or_not
	global controls i.en_Course Age_rounded Age_squared i.en_Gender i.en_Position bs_iat_score
	global controls_miss "en_Course, Age_rounded, Age_squared, en_Gender, en_Position ,bs_iat_score"
	
	/*---
	Randomization 1st level: Option to take IAT
	---*/
	
	local reg_counter = 1
	foreach y in $iat_outcomes {
		qui sum `y' if iat_option_take_or_not==0, d // mean y control group
		local mean = round(`r(mean)', 0.001) 
		
		qui:reg `y' iat_option_take_or_not, vce(cluster Course) // regression no controls
		if(`reg_counter'==1){ // creating outreg file
			outreg2 using "$tables\iat_option_take_or_not.xls", replace stats(coef pval ) level(95) addtext("Controls", "No", "Mean of dep var. ctrl.", `mean') label keep(iat_option_take_or_not) nocons nor2
			} 
		else{ // storing reg output in outreg file
			outreg2 using "$tables\iat_option_take_or_not.xls", append stats(coef pval ) level(95) addtext("Controls", "No", "Mean of dep var. ctrl.", `mean') label keep(iat_option_take_or_not) nocons nor2
		}
		
		qui sum `y' if iat_option_take_or_not==0 & !missing($controls_miss), d // mean y control group
		local mean = round(`r(mean)', 0.001) 
		qui:reg `y' iat_option_take_or_not $controls, vce(cluster Course) // regression with controls
		outreg2 using "$tables\iat_option_take_or_not.xls", append stats(coef pval ) level(95) addtext("Controls", "Yes", "Mean of dep var. ctrl.", `mean') label keep(iat_option_take_or_not) nocons nor2 // storing r
		local reg_counter = `reg_counter' + 1
	}
	
	
	/*---
	Randomization 2nd level: Option to receive feedback
	---*/
	
	global iat_outcomes_nf z_iat_score_change z_en_iat_score // no feedback outcomes
	
	local reg_counter = 1
	foreach y in $iat_outcomes_nf{
		qui sum `y' if iat_feedback_option_or_not==0, d // mean y control group
		local mean = round(`r(mean)', 0.001) 
		
		qui:reg `y' iat_feedback_option_or_not, vce(cluster Course) // regression no controls
		if(`reg_counter'==1){ // creating outreg file
			outreg2 using "$tables\iat_feedback_option_or_not.xls", replace stats(coef pval ) level(95) addtext("Controls", "No", "Mean of dep var. ctrl.", `mean') label keep(iat_feedback_option_or_not) nocons nor2
			} 
		else{ // storing reg output in outreg file
			outreg2 using "$tables\iat_feedback_option_or_not.xls", append stats(coef pval ) level(95) addtext("Controls", "No", "Mean of dep var. ctrl.", `mean') label keep(iat_feedback_option_or_not) nocons nor2
		}
		
		qui sum `y' if iat_feedback_option_or_not==0 & !missing($controls_miss), d // mean y control group
		local mean = round(`r(mean)', 0.001) 
		qui:reg `y' iat_feedback_option_or_not $controls, vce(cluster Course) // regression with controls
		outreg2 using "$tables\iat_feedback_option_or_not.xls", append stats(coef pval ) level(95) addtext("Controls", "Yes", "Mean of dep var. ctrl.", `mean') label keep(iat_feedback_option_or_not) nocons nor2 // storing r
		local reg_counter = `reg_counter' + 1
	}
	
	
	/*---
	Randomization 1st and 2nd level: Interaction of Option to take IAT
	and Option to receive feedback
	---*/
	
	local reg_counter = 1
	foreach y in $iat_outcomes{
		qui sum `y' if iat_interaction==0, d // mean y control group
		local mean = round(`r(mean)', 0.001) 
		
		qui:reg `y' iat_option_take_or_not iat_feedback_option_or_not iat_interaction, vce(cluster Course) // regression no controls
		if(`reg_counter'==1){ // creating outreg file
			outreg2 using "$tables\iat_interaction.xls", replace stats(coef pval ) level(95) addtext("Controls", "No", "Mean of dep var. ctrl.", `mean') label keep(iat_option_take_or_not iat_feedback_option_or_not iat_interaction) nocons nor2
			} 
		else{ // storing reg output in outreg file
			outreg2 using "$tables\iat_interaction.xls", append stats(coef pval ) level(95) addtext("Controls", "No", "Mean of dep var. ctrl.", `mean') label keep(iat_option_take_or_not iat_feedback_option_or_not iat_interaction) nocons nor2
		}
		
		qui sum `y' if iat_interaction==0 & !missing($controls_miss), d // mean y control group
		local mean = round(`r(mean)', 0.001) 
		qui:reg `y' iat_option_take_or_not iat_feedback_option_or_not iat_interaction $controls, vce(cluster Course) // regression with controls
		outreg2 using "$tables\iat_interaction.xls", append stats(coef pval ) level(95) addtext("Controls", "Yes", "Mean of dep var. ctrl.", `mean') label keep(iat_option_take_or_not iat_feedback_option_or_not iat_interaction) nocons nor2 // storing r
		local reg_counter = `reg_counter' + 1
	}
	
	