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
	orth_out position_* course_* gender_1 Age_rounded using "$tables\iat_selection.xlsx" if iat_option_take_or_not==1, by(en_iat_player_skipped) pcompare stars se sheet(selection_iat_takeup) sheetreplace

	orth_out position_* course_* gender_1 Age_rounded using "$tables\iat_selection.xlsx" if iat_feedback_option_or_not==1, by(en_ignore_feedback) pcompare stars se sheet(selection_iat_feedback) sheetreplace

	
	/*-----
	IAT regressions
	-----*/
	
	**Fourth set of controls
	global controls i.en_Course Age_rounded Age_squared i.en_Gender i.en_Position bs_iat_score
	
	local i = 1
	eststo clear
	foreach y in z_iat_score_change z_en_iat_score en_iat_want_feedback {
		qui sum `y' if iat_option_take_or_not==0, d 
		local mean = round(`r(mean)', 0.001) 
		
		qui:reg `y' iat_option_take_or_not, vce(cluster Course)
		if(`i'==1){
			outreg2 using "$tables\iat_option_take_or_not.xls", replace stats(coef pval ) level(95) addtext("Individual Controls", "No", "Mean of dep var. ctrl.", `mean') label keep(iat_option_take_or_not) nocons nor2
			} 
		else{
			outreg2 using "$tables\iat_option_take_or_not.xls", append stats(coef pval ) level(95) addtext("Individual Controls", "No", "Mean of dep var. ctrl.", `mean') label keep(iat_option_take_or_not) nocons nor2
		}
		
		qui:reg `y' iat_option_take_or_not $controls, vce(cluster Course)
		outreg2 using "$tables\iat_option_take_or_not.xls", append stats(coef pval ) level(95) addtext("Individual Controls", "Yes", "Mean of dep var. ctrl.", `mean') label keep(iat_option_take_or_not) nocons nor2
		local i = `i' + 1
	}
	
	