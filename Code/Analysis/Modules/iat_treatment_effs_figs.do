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
	
	set scheme s1mono // setting up scheme
	
	**plotting only reg coeffs from regs with ctrls
	coefplot var1_r1_2 var2_r1_2 var3_r1_2 var4_r1_2 var1_r2_2 var2_r2_2 , keep(iat_option_take_or_not iat_feedback_option_or_not) xline(0) title("IATesteo sandungueo :v") xtitle("Point Estimates with 95% CIs (Metrics Assigned)") xlabel(-1.0(1)1.0) xscale(range(-1.0(1)1.0)) mlabel format(%9.3f) mlabposition(12) mlabgap(*1) level(95) legend(pos(4) col(1)) ylabel(0.62 "Want Feedback (End)" 0.78 "Want Feedback - Level (End)" 0.96 "Score Change" 1.08 "Score (End)" 2.21 "Score Change (End)" 2.34 "Score (End)")
	graph display, ysize(1) xsize(2)

	**Updating legend tags
	gr_edit legend.plotregion1.label[1].text = {}
	gr_edit legend.plotregion1.label[1].text.Arrpush Want Feedback vs Option to Take
	
	gr_edit legend.plotregion1.label[2].text = {}
	gr_edit legend.plotregion1.label[2].text.Arrpush Want Feedback - Level vs Option to Take
	
	gr_edit legend.plotregion1.label[3].text = {}
	gr_edit legend.plotregion1.label[3].text.Arrpush Score Change vs Option to Take
	
	gr_edit legend.plotregion1.label[4].text = {}
	gr_edit legend.plotregion1.label[4].text.Arrpush Score Change (End) vs Option to Take
	
	gr_edit legend.plotregion1.label[5].text = {}
	gr_edit legend.plotregion1.label[5].text.Arrpush Score Change vs Option to Receive Feedback
	
	gr_edit legend.plotregion1.label[6].text = {}
	gr_edit legend.plotregion1.label[6].text.Arrpush Score Change (End) vs Option to Receive Feedback
 
