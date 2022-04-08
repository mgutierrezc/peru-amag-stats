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
		
		reg `y' iat_option_take_or_not, vce(cluster Course) // regression no controls
		estimates store var`reg_counter'_r1_1 // storing results randomization lev 1 reg 1
		
		reg `y' iat_option_take_or_not $controls, vce(cluster Course) // regression with controls
		estimates store var`reg_counter'_r1_2 // storing results randomization lev 1 reg 2
		
		local reg_counter = `reg_counter' + 1
	}
	
	
	/*---
	Randomization 2nd level: Option to receive feedback
	---*/
	
	global iat_outcomes_nf z_iat_score_change z_en_iat_score // no feedback outcomes
	
	local reg_counter = 1
	foreach y in $iat_outcomes_nf{
		
		reg `y' iat_feedback_option_or_not, vce(cluster Course) // regression no controls
		estimates store var`reg_counter'_r2_1 // storing results randomization lev 2 reg 1
		
		reg `y' iat_feedback_option_or_not $controls, vce(cluster Course) // regression with controls
		estimates store var`reg_counter'_r2_2 // storing results randomization lev 2 reg 2
		
		local reg_counter = `reg_counter' + 1
	}
	
	
	/*---
	Randomization 1st and 2nd level: Interaction of Option to take IAT
	and Option to receive feedback
	---*/
	
	local reg_counter = 1
	foreach y in $iat_outcomes{
		
		reg `y' iat_option_take_or_not iat_feedback_option_or_not iat_interaction, vce(cluster Course) // regression no controls
		estimates store var`reg_counter'_r12_1 // storing results randomization lev 1 & 2 reg 1
		
		reg `y' iat_option_take_or_not iat_feedback_option_or_not iat_interaction $controls, vce(cluster Course) // regression with controls
		estimates store var`reg_counter'_r12_2 // storing results randomization lev 1 & 2 reg 2
		
		local reg_counter = `reg_counter' + 1
	}
	
	
	/*---
	Plot generation for IAT Randomization 
	regressions
	---*/
	
	 set scheme plotplain // setting up scheme
	
	**1st and 2nd rand level plots (plotting only reg coeffs from regs with ctrls)
	coefplot var1_r1_2 var2_r1_2 var3_r1_2 var4_r1_2 var1_r2_2 var2_r2_2 , keep(iat_option_take_or_not iat_feedback_option_or_not) xline(0) title("IAT treatments and outcomes") xtitle("Point Estimates with 95% CIs (Standardized outcomes)") xlabel(-1.0(1)1.0) xscale(range(-1.0(1)1.0)) mlabel format(%9.3f) mlabposition(12) mlabgap(*1) level(95) ylabel(0.62 "Want Feedback (End)" 0.78 "Want Feedback - Level (End)" 0.96 "Score Change" 1.08 "Score (End)" 2.21 "Score Change (End)" 2.34 "Score (End)" 0 "Treatment: Option to Take" 1.5 "Treatment: Option to Receive Feedback") legend(off)
	graph display, ysize(1) xsize(2)

    **1st and 2nd rand level interaction plots
	coefplot var1_r12_2 var2_r12_2 var3_r12_2 var4_r12_2   , keep(iat_option_take_or_not iat_feedback_option_or_not iat_interaction) ///
 	xline(0) title("IAT treatments and outcomes - interaction effects") xtitle("Point Estimates with 95% CIs (Standardized outcomes)", size(small)) ///
 	xlabel(-1.0(1)1.0) xscale(range(-1.0(1)1.0)) mlabel format(%9.3f) mlabposition(12) mlabgap(*1) level(95) ///
 	ylabel(0.1 "Treatment: Option to Take" 0.62 "Want Feedback (End)" 0.84 "Want Feedback - Level (End)" 1.06 "Score Change" 1.28 "Score (End)" 1.5 "Treatment: Option to Receive Feedback"  2.05 "Score Change (End)" 2.27 "Score (End)"  2.5 "Treatment: IAT and Feedback Options" 3.05 "Score Change (End)" 3.27 "Score (End)", labsize(small) ) ///
 	legend(off) 
