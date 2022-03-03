cls
/***********
**Impact Analysis of Peru Amag project
with Socratic Analysis

Project: Peru-Amag
Programmer: Jose Maria Rodriguez
Editor: Marco Gutierrez
***********/

clear all 

/*--------------
Defining paths
--------------*/

global main "D:\Accesos directos\Trabajo\World Bank\Peru Amag\peru-amag-stats"
global data "$main\Data"
global output "$main\output"

global eval_analysis "$output\amag_satisfaction"
cap mkdir "$amag_satisfaction"
global tables "$eval_analysis\tables"
cap mkdir "$tables"
global graphs "$eval_analysis\graphs"
cap mkdir "$graphs"

// use "/Users/josemariarodriguezvaladez/Google Drive/JMRV_job/DIME/Clean_Full_Data12.dta"  
use "$data\Clean_Full_Data.dta"

// cd "/Users/josemariarodriguezvaladez/Google Drive/JMRV_job/DIME"

*****************************************************
*Defining controls for all regressions - later in subsections other controls are added
*****************************************************
	ren Cargo Position
	lab var Position Position
	ren Curso Course
	lab var Course Course
	ren Género Gender
	lab var Gender Gender

	encode Position, gen(en_Position)
	encode Course, gen(en_Course)
	encode Gender, gen(en_Gender)
	//shortening names
	ren bs_dictator_partner_gender bs_dictator_pgender
	ren en_dictator_partner_gender en_dictator_pgender
	ren bs_redistribute_partner_gender_a bs_redistribute_pgendera
	ren bs_redistribute_partner_gender_b bs_redistribute_pgenderb
	ren en_redistribute_partner_gender_a en_redistribute_pgendera
	ren en_redistribute_partner_gender_b en_redistribute_pgenderb

	lab def position 1 Assistant 2 Auxiliary 3 Prosecutor 4 Judge
	lab val en_Position position
	lab def courses 1 Convention_Constitution 2 Constitutional_Interpretation 3 Jurisprudence 4 Reasoning 5 Virtues_Principles 6 Ethics
	lab val en_Course courses 
	lab def gender 1 Female 2 Male
	lab val en_Gender gender
	foreach x in  bs_dictator_pgender en_dictator_pgender bs_redistribute_pgendera en_redistribute_pgendera en_redistribute_pgenderb {
		encode `x', gen(`x'_num)
		lab val `x'_num gender
	}

	tab Position, gen(position_)
	tab Course, gen(course_)
	tab Gender, gen(gender_)

	lab var course_1 Convention_Constitution
	lab var course_2 Constitional_Interpretation
	lab var course_3 Jurisprudence
	lab var course_4 Reasoning
	lab var course_5 Virtues_Principles
	lab var course_6 Ethics

	lab var position_1 Assistant
	lab var position_2 Auxiliary
	lab var position_3 Prosecutor
	lab var position_4 Judge

	lab var gender_1 Female
	lab var gender_2 Male


	merge m:1 DNI using sat_clean.dta
	drop _m

	merge m:1 DNI using grades_clean.dta
	drop _m
	//global controls1 i.en_Curso 
	global controls2 i.en_Course Age_rounded i.en_Gender i.en_Position




*****************************************************
**IMPACT EVALUATION OF COURSES  ON SATISFACTION
*****************************************************


	gen attrition=.
	replace attrition = 0 if bs_Estado_de_Cuestionario=="Completo"
	replace attrition = 1 if (regex(en_Estado_de_Cuestionario,"Comenzo") | regex(en_Estado_de_Cuestionario,"Falta")) & bs_Estado_de_Cuestionario=="Completo"
	tab attrition

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

	*confirmation bias 
	*-> whether clicked on both briefs (and order if can extract time stamps)
	//Note: currently also counting those who did not click ay brief as exhibiting confirmation bias
	foreach x in bs en {
		gen `x'_conf_bias=1 if  `x'_Estado_de_Cuestionario=="Completo" //& (`x'_motivated_click_arga!=. | `x'_motivated_click_argb!=. )
		replace `x'_conf_bias=0 if `x'_motivated_click_arga!=. & `x'_motivated_click_argb!=. & `x'_Estado_de_Cuestionario=="Completo"
		tab `x'_conf_bias
	} 

	gen iat_score_change = en_iat_score-bs_iat_score



	*creating a dummy for whether they saw their feedback at baseline
	gen bs_saw_iat_feedback=0 if bs_iat_score!=.
	replace bs_saw_iat_feedback=1 if bs_iat_feedback_descriptive!="" & regex(bs_iat_feedback_descriptive, "No fue")==0
	tab bs_saw_iat_feedback
	count if bs_iat_score!=. //problem is that there is no variable which demarcates if the person was shown or not shown their feedback as bs_iat_feedback_descriptive is there for all the people so not sure who was not shown their feedback
	//need to check with Chris

	ren en_dictator_player_decision en_dictator_decision
	ren en_redistribute_player_decision en_redistribute_decision
	ren bs_dictator_player_decision bs_dictator_decision
	ren bs_redistribute_player_decision bs_redistribute_decision

	foreach x in dictator_decision redistribute_decision {
		gen `x'_change = en_`x'-bs_`x'
	}

	***adding ingroup outgroup 
	//global controls_ingroup_altruism i.en_Course Age_rounded i.en_Gender#i.en_dictator_pgender_num i.en_Position 

	gen ingroup_altruism = .
	replace ingroup_altruism =0 if en_dictator_pgender_num!=en_Gender
	replace ingroup_altruism =1 if en_dictator_pgender_num==en_Gender //partner is ingroup

	**redistribution regs
	***Adding controls for in group versus outgroup bias 
	gen ingroup_redist = . if (en_Gender==1 & en_redistribute_pgendera_num==1 & en_redistribute_pgenderb_num==1) | (en_Gender==2 & en_redistribute_pgendera_num==2 & en_redistribute_pgenderb_num==2) //both matched participants same gender as the participant
	replace ingroup_redist = 0 if (en_Gender==1 & en_redistribute_pgendera_num==2 & en_redistribute_pgenderb_num==1) | (en_Gender==2 & en_redistribute_pgendera_num==1 & en_redistribute_pgenderb_num==2) //partner a is outgroup, partner b is ingroup
	replace ingroup_redist =1 if (en_Gender==1 & en_redistribute_pgendera_num==1 & en_redistribute_pgenderb_num==2) | (en_Gender==2 & en_redistribute_pgendera_num==2 & en_redistribute_pgenderb_num==1) //partner a is ingroup

	gen trolley_decision_change = en_trolley_decision -bs_trolley_decision
	gen trolley_version = bs_trolley_treatment
	replace trolley_version=en_trolley_treat if bs_trolley_treatment==""
	encode trolley_version, gen(en_trolley_version)
	***Adding controls for in group versus outgroup bias 
	gen ingroup_trolley = 0 if (en_Gender==1 & regexm(trolley_version, "_male")) | (en_Gender==2 & regexm(trolley_version, "female"))
	replace ingroup_trolley =1 if (en_Gender==1 & regexm(trolley_version, "female")) | (en_Gender==2 & regexm(trolley_version, "_male"))

	encode en_participant_book_choice, gen(en_book)
	lab def endbook 1 NA 2 Corruption 3 Feminist_Rights 4 Just_Decision 5 Proof_and_Rationality
	lab val en_book endbook
	tab en_book, gen(en_book_topic)





	**** REGS on satisfaction 


	reg meansat socratic $controls2 ,  cluster(Course)


	outreg2 using "$tables\satisfactionref.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label keep(socratic  i.en_Course) addnote(The table shows the impact of courses on satisfaction which is an scale that goes from 1 to 5 The regression controls for age, gender and position of the participant, second model motivated reasoner at bs and third interaction of motivated reasoner at endline . Standard errors are clustered at the course level.) bdec(3)

*****************************************************
*Motivated Reasoning
*****************************************************
	//Note: The way the question was asked the values capture the chance it was true news
	global controls3 i.en_Course Age_rounded i.en_Gender i.en_Position bs_motivated_reasoner 
	global controls4 i.en_Course Age_rounded i.en_Gender i.en_Position en_motivated_newsh#bs_motivated_reasoner ///direction of motivated reasoning on average 
	 
	 
	 
	reg meansat socratic $controls3 ,  cluster(Course)  
			outreg2 using "$tables\satisfactionref.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label keep(socratic i.en_Course) bdec(3)

	reg meansat  socratic $controls4 ,  cluster(Course)  
			outreg2 using "$tables\satisfactionref.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label keep(socratic i.en_Course) bdec(3)




	***** REGS on grades

	local i = 1
	foreach y of varlist grade pass  { 
	qui sum `y', d
	local mean = round(`r(mean)', 0.001) 
	reg `y' socratic $controls2 ,  cluster(Course)


	**** REGS on satisfaction 


	global controls2 i.en_Course Age_rounded i.en_Gender i.en_Position
	global controls3 i.en_Course Age_rounded i.en_Gender i.en_Position bs_motivated_reasoner 
	global controls4 i.en_Course Age_rounded i.en_Gender i.en_Position en_motivated_newsh#bs_motivated_reasoner ///direction of motivated reasoning on average 




	gen saw_video = . 
	replace saw_video=1 if bs_participant_index_in_pages>16 & bs_participant_index_in_pages!=.
	replace saw_video=0 if bs_participant_index_in_pages>0 & bs_participant_index_in_pages<=16 & bs_participant_index_in_pages!=.
	gen socratic_actual = 0 if saw_video==0 
	replace socratic_actual=1 if saw_video==1 & socratic_treated==1 
	 
	lab var attendance "attendance"
	 qui sum grade, d
		local mean = round(`r(mean)', 0.001) 
	reg grade socratic_treated $controls2 ,  cluster(Course)
	outreg2 using "$tables\grades.xls", replace stats(coef pval ) level(95) addtext(mean, `mean') label keep(socratic_treated socratic_actual  attendance i.en_Course) addnote(The table shows the impact of courses on grade which is variable that ranges from 0 to 20. The regression controls for age, gender and position of the participant, second model motivated reasoner at bs and third interaction of motivated reasoner at endline . Standard errors are clustered at the course level.) bdec(3)
	  

	reg grade socratic_actual   $controls2 ,  cluster(Course)
	outreg2 using "$tables\grades.xls", append stats(coef pval ) level(95) addtext(mean, `mean') label keep(socratic_treated socratic_actual attendance i.en_Course) addnote(The table shows the impact of courses on grade which is variable that ranges from 0 to 20. The regression controls for age, gender and position of the participant, second model motivated reasoner at bs and third interaction of motivated reasoner at endline . Standard errors are clustered at the course level.) bdec(3)

	reg grade socratic_treated attendance $controls2 ,  cluster(Course)
	outreg2 using "$tables\grades.xls", append stats(coef pval ) level(95) addtext(mean, `mean') label keep(socratic_treated socratic_actual attendance i.en_Course) addnote(The table shows the impact of courses on grade which is variable that ranges from 0 to 20. The regression controls for age, gender and position of the participant, second model motivated reasoner at bs and third interaction of motivated reasoner at endline . Standard errors are clustered at the course level.) bdec(3)




	reg grade socratic_treated  attendance  $controls3 ,  cluster(Course)
	outreg2 using "$tables\grades.xls", append stats(coef pval ) level(95) addtext(mean, `mean') label keep(socratic_treated socratic_actual attendance i.en_Course) addnote(The table shows the impact of courses on grade which is variable that ranges from 0 to 20. The regression controls for age, gender and position of the participant, second model motivated reasoner at bs and third interaction of motivated reasoner at endline . Standard errors are clustered at the course level.) bdec(3)
	  
	 
	 
	reg grade attendance  socratic_treated $controls3 ,  cluster(Course)  
			outreg2 using "$tables\grades.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label keep(socratic_treated attendance  i.en_Course) bdec(3)

	reg grade attendance socratic_treated $controls4 ,  cluster(Course)  
			outreg2 using "$tables\grades.xls", append stats(coef pval ) level(95)  addtext(mean, `mean') label keep(socratic_treated attendance i.en_Course) bdec(3)




	reg grade (socratic_actual=socratic_treated)
