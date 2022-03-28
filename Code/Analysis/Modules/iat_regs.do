/***********
**IAT and IAT 'forced'
regressions

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
	global controls6 i.en_Course Age_rounded Age_squared i.en_Gender i.en_Position bs_iat_score
	//global controls6iv i.en_Course Age_rounded Age_squared i.en_Gender i.en_Position (bs_iat_score=iat_option_take_or_not) 
	global controls7 i.en_Course Age_rounded Age_squared i.en_Gender i.en_Position iat_option_take_or_not  //iat_feedback_option_or_not
	**iat_option_take_or_not: player is given option to skip iat

	local i = 1
	foreach y in en_iat_player_skipped en_iat_score iat_score_change en_iat_want_feedback en_iat_feedback_level {
		qui sum `y', d
		local mean = round(`r(mean)', 0.001) 
		
		reg `y' $controls1 ,  cluster(Course) 
		if(`i'==1){
			outreg2 using "$tables\iat_regs.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label
			} 
		else{
			outreg2 using "$tables\iat_regs.xls", append stats(coef pval ) level(95) addtext(mean, `mean') label
			}
					
		local i = `i' + 1
					
		reg `y' $controls2 ,  cluster(Course) 
		outreg2 using "$tables\iat_regs.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
					
		reg `y' $controls6 ,  cluster(Course) 
		outreg2 using "$tables\iat_regs.xls", append stats(coef pval ) level(95)  addtext(mean, `mean', ctrls, "6") label

		reg `y' $controls7 ,  cluster(Course) 
		outreg2 using "$tables\iat_regs.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
	}

	***Looking at IAT results of only those who were forced to take the IAT - no selection issues at all
	local i = 1
	foreach y in en_iat_score iat_score_change en_iat_want_feedback en_iat_feedback_level {
		qui sum `y', d
		local mean = round(`r(mean)', 0.001) 
		
		reg `y' $controls1 if iat_option_take_or_not==0,  cluster(Course) 
		if(`i'==1){
			outreg2 using "$tables\iat_regs_forced.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label
			} 
		else{
			outreg2 using "$tables\iat_regs_forced.xls", append stats(coef pval ) level(95) addtext(mean, `mean') label
			}
					
		local i = `i' + 1
					
		reg `y' $controls2 if iat_option_take_or_not==0,  cluster(Course) 
		outreg2 using "$tables\iat_regs_forced.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
					
		reg `y' $controls6 if iat_option_take_or_not==0,  cluster(Course) 
		outreg2 using "$tables\iat_regs_forced.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label

		//ivreg2 `y' $controls6iv if iat_option_take_or_not==0,  cluster(Course) 
		//outreg2 using iat_regs_forced.xls, append stats(coef pval ) level(95)  addtext(mean, `mean') label

		reg `y' $controls7 if iat_option_take_or_not==0,  cluster(Course) 
		outreg2 using "$tables\iat_regs_forced.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label
	}
	
	
	/*-----
	IAT Interaction effects and IV approach
	-----*/
	
	global controls6iv  (i.bs_iat_player_skipped=i.iat_option_take_or_not) i.en_Course Age_rounded Age_squared i.en_Gender i.en_Position  
// 		global controls7iv  (i.seen_iat_feedback  = i.iat_feedback_option_or_not) i.en_Course Age_rounded i.en_Gender i.en_Position 
	
	*if player didn't choose whether to take the iat, it'll be considered as if he didn't skip it on baseline
	replace  bs_iat_player_skipped  = 0 if   iat_option_take_or_not ==0

	*regression counter
	local i = 1
	foreach y in en_iat_score iat_score_change en_iat_want_feedback en_iat_feedback_level {
		
		*labels for plots
		local mylabel : variable label `y'
		*------------------------------*
		* IVreg Model 2: skip test
		*------------------------------ *
		ivreg2 `y' $controls6iv , r
		if(`i'==1){
			outreg2 using "$tables\iat_regs_iv.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label
			} 
		else{
			outreg2 using "$tables\iat_regs_iv.xls", append stats(coef pval ) level(95) addtext(mean, `mean') label
			}
			
		local i = `i' + 1

	}