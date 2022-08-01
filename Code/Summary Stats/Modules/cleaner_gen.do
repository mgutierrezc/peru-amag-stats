/***********
**Cleaning and variable
generation Module

Project: Peru-Amag
Programmer: Marco Gutierrez
***********/

/*=====
Defining controls for all regressions - later in 
subsections other controls are added
=====*/

	*Renaming vars
	ren Cargo Position
	lab var Position Position
	ren Curso Course
	lab var Course Course
	ren Género Gender
	lab var Gender Gender
	
	*encoding strings
	encode Position, gen(en_Position)
	encode Course, gen(en_Course)
	encode Gender, gen(en_Gender)
	
	*shortening names of game variables
	ren bs_dictator_partner_gender bs_dictator_pgender
	ren en_dictator_partner_gender en_dictator_pgender
	ren bs_redistribute_partner_gender_a bs_redistribute_pgendera
	ren bs_redistribute_partner_gender_b bs_redistribute_pgenderb
	ren en_redistribute_partner_gender_a en_redistribute_pgendera
	ren en_redistribute_partner_gender_b en_redistribute_pgenderb
	
	*defining value labels for main variables
	lab def position 1 Assistant 2 Auxiliary 3 Prosecutor 4 Judge
	lab val en_Position position
	lab def courses 1 Convention_Constitution 2 Constitutional_Interpretation 3 Jurisprudence 4 Reasoning 5 Virtues_Principles 6 Ethics
	lab val en_Course courses 
	lab def gender 1 Female 2 Male
	lab val en_Gender gender

	*encoding game variables
	foreach x in bs_dictator_pgender en_dictator_pgender bs_redistribute_pgendera en_redistribute_pgendera en_redistribute_pgenderb {
		encode `x', gen(`x'_num)
		lab val `x'_num gender
	}

	*creating dummies for main variables
	tab Position, gen(position_)
	tab Course, gen(course_)
	tab Gender, gen(gender_)
	
	*labeling course variables
	lab var course_1 Convention_Constitution
	lab var course_2 Constitional_Interpretation
	lab var course_3 Jurisprudence
	lab var course_4 Reasoning
	lab var course_5 Virtues_Principles
	lab var course_6 Ethics
	
	*labeling position variables
	lab var position_1 Assistant
	lab var position_2 Auxiliary
	lab var position_3 Prosecutor
	lab var position_4 Judge
	
	*labeling gender variables
	lab var gender_1 Female
	lab var gender_2 Male
	
	
	/*-----
	Merging datasets
	-----*/
	
	*merging with satisfaction clean data
	merge m:1 DNI using sat_clean.dta
	drop _m

	*merging with grades clean data
	merge m:1 DNI using grades_clean.dta
	drop _m
	
	
	/*-----
	Creating variables using merged datasets vars
	-----*/
	
	*renaming satisfaction variables
	rename sat3 sat_instructor
	rename sat5 sat_exp
	rename sat2 sat_course
	rename meansat sat_avg

	*attrition
	gen attrition=.
	replace attrition = 0 if bs_Estado_de_Cuestionario=="Completo"
	replace attrition = 1 if (regex(en_Estado_de_Cuestionario,"Comenzo") | regex(en_Estado_de_Cuestionario,"Falta")) & bs_Estado_de_Cuestionario=="Completo"
	tab attrition
	
	*rename dictator and redistribution variables (baseline and endline)
	ren en_dictator_player_decision en_dictator_decision
	ren en_redistribute_player_decision en_redistribute_decision
	ren bs_dictator_player_decision bs_dictator_decision
	ren bs_redistribute_player_decision bs_redistribute_decision
	
	*generating changes on main variables between endline and baseline
	foreach x in dictator_decision redistribute_decision {
		gen `x'_change = en_`x'-bs_`x'
	}
	
	*generating trolley variables
	gen trolley_decision_change = en_trolley_decision -bs_trolley_decision
	gen trolley_version = bs_trolley_treatment

	replace trolley_version=en_trolley_treat if bs_trolley_treatment==""
	encode trolley_version, gen(en_trolley_version)
	
	*generating book prize related variables
	encode en_participant_book_choice, gen(en_book)

	lab def endbook 1 NA 2 Corruption 3 Feminist_Rights 4 Just_Decision 5 Proof_and_Rationality
	lab val en_book endbook

	tab en_book, gen(en_book_topic)
	
	*generating socratic variables
	gen saw_video = . 
	replace saw_video=1 if bs_participant_index_in_pages>16 & bs_participant_index_in_pages!=.
	replace saw_video=0 if bs_participant_index_in_pages>0 & bs_participant_index_in_pages<=16 & bs_participant_index_in_pages!=.

	gen socratic_actual = 0 if saw_video==0 
	replace socratic_actual=1 if saw_video==1 & socratic_treated==1
	
	*generating squared age
	gen age2 = Age_rounded^2
	label var age2 "Age Squared"
	
	
	/*-----
	Creating Motivated Reasoning Variables
	
	---
	Note: The way the question was asked the values 
	capture the chance it was true news
	-----*/
	
	*creating motivated reasoning variables for baseline and endline
	foreach x in bs en {
		*motivated reasoner dummy
		tab `x'_motivated_fakenews if `x'_participant_merge==3, m 
		gen `x'_motivated_reasoner=0 if `x'_motivated_fakenews==5 & `x'_participant_merge==3 
		replace `x'_motivated_reasoner =1 if `x'_motivated_fakenews!=. & `x'_motivated_fakenews!=5 & `x'_participant_merge==3
		tab `x'_motivated_reasoner
		
		*extent of motivated reasoning
		gen `x'_motivated_intensity =abs(5-`x'_motivated_fakenews) if `x'_motivated_fakenews!=. & `x'_participant_merge==3
		tab `x'_motivated_intensity
	}
	
	
	/*-----
	Confirmation Bias
	
	---
	Note 1: Conf. Bias is evaluated as whether clicked on both 
	briefs (and order if can extract time stamps)
	Note 2: Currently also counting those who did 
	not click ay brief as exhibiting confirmation bias
	-----*/
	
	foreach x in bs en {
		gen `x'_conf_bias=1 if  `x'_Estado_de_Cuestionario=="Completo" //& (`x'_motivated_click_arga!=. | `x'_motivated_click_argb!=. )
		replace `x'_conf_bias=0 if `x'_motivated_click_arga!=. & `x'_motivated_click_argb!=. & `x'_Estado_de_Cuestionario=="Completo"
		tab `x'_conf_bias
	} 
	
	gen iat_score_change = en_iat_score-bs_iat_score
	
	
	/*-----
	Generate standarized Dependent variables for models
	-----*/
	
	*generating dependent variables
	foreach var of varlist en_iat_score  bs_iat_score iat_score_change en_iat_feedback_level en_motivated_reasoner en_motivated_intensity en_conf_bias en_motivated_info en_trolley_decision trolley_decision_change en_dictator_decision dictator_decision_change  en_redistribute_decision redistribute_decision_change en_iat_player_skipped   en_book_topic1 - en_book_topic4  sat_instructor sat_exp sat_course sat_avg grade pass {
		qui sum `var'
		gen z_`var' = (`var' - `r(min)') / (`r(max)'-`r(min)')
	}
	
	*labeling variables
	lab var z_en_iat_score "IAT score endline"
	lab var z_bs_iat_score "IAT score baseline"
	lab var z_iat_score_change "IAT score change"
	lab var z_en_motivated_reasoner "Motivated Reasoner"
	lab var z_en_motivated_intensity "Motivated Reasoner (intensity)"
	lab var z_en_conf_bias "Confirmation Bias"
	lab var z_en_motivated_info "Curiosity"
	lab var z_en_trolley_decision "Trolley Decision"
	lab var z_trolley_decision_change "Trolley Decision Change"
	lab var z_en_dictator_decision "Dictator Decision"
	lab var z_dictator_decision_change "Dictator Decision  Change"
	lab var z_en_redistribute_decision "Redistribute Decision"
	lab var z_redistribute_decision_change "Redistribute Decision Change"
	lab var z_en_iat_player_skipped "skipped IAT"
	lab var z_en_book_topic1 "Book choice: Corruption"
	lab var z_en_book_topic2 "Book choice: Feminist Rights"
	lab var z_en_book_topic3 "Book choice: Just Decision"
	lab var z_en_book_topic4 "Book choice: Proof and Rationality"
	lab var z_sat_instructor "Satisfaction: Instructor"
	lab var z_sat_exp "Satisfaction: Learning experience"
	lab var z_sat_course "Satisfaction: course"
	lab var z_sat_avg "Satisfaction: average"
	lab var z_grade "Course Grade "
	lab var z_pass "Pass Course"
	lab var en_iat_want_feedback "Player wants feedback"
	lab var z_en_iat_feedback_level "Player's feedback level"
	lab var iat_option_take_or_not "Option to Take IAT"
	lab var iat_feedback_option_or_not "Option to Receive Feedback"
	label var bs_iat_score "IAT Score (Baseline)"
	label var en_iat_score "IAT Score (Endline)"
	label var iat_score_change "IAT Score Change"
	
	*Selection on observables for feedback
	gen en_ignore_feedback = 0 if en_iat_want_feedback!=.
	replace en_ignore_feedback =1 if en_iat_want_feedback==0 | en_iat_feedback_level==0 
	
	*Analyze choice of receiving feedback depending on whether forced to take the IAT or opted in 
	gen iat_interaction = iat_feedback_option_or_not * iat_option_take_or_not
	lab var iat_interaction "IAT and Feedback options"
	
	*Creating squared bs iat score for analysis of non linear relations
	gen z_bs_iat_score2 = z_bs_iat_score^2
	